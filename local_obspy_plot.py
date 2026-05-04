"""Local SAC record-section plotting script.

This script is designed for a local Python environment with ObsPy installed.
Edit data_dir and event_time before running.
"""

from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from obspy import read, UTCDateTime
from obspy.geodetics import locations2degrees

# ===== Edit these values =====
event_time = UTCDateTime(2026, 5, 1, 12, 39, 55)
data_dir = Path(r"c:\Users\kyle0\Desktop\seismoiogy_ch3\20260501123955_CWASN")
file_pattern = str(data_dir / "*Z.D*.SAC")
output_path = data_dir.parent / "record_section.png"
amp_scale = 8.0
freqmin, freqmax = 0.5, 5.0
# =============================

print("Reading SAC files...", flush=True)
st = read(file_pattern)
print("Total Z-component traces loaded:", len(st), flush=True)

# Keep the best Z component per station: HHZ > EHZ > HLZ/HNZ > others
station_dict = {}
for tr in st:
    sta = tr.stats.station
    chan = tr.stats.channel
    priority = 0
    if chan.endswith("Z"):
        if chan.startswith("HH"):
            priority = 3
        elif chan.startswith("EH"):
            priority = 2
        elif chan.startswith(("HL", "HN")):
            priority = 1
    if sta not in station_dict or priority > station_dict[sta][1]:
        station_dict[sta] = (tr, priority)

traces = [item[0] for item in station_dict.values()]
print("Unique stations selected:", len(traces), flush=True)

start_trim = event_time - 10
end_trim = event_time + 120
valid = []
for tr in traces:
    tr = tr.copy()
    tr.trim(start_trim, end_trim)
    if tr.stats.npts < 10 or len(tr.data) == 0:
        continue
    tr.detrend("demean")
    tr.filter("bandpass", freqmin=freqmin, freqmax=freqmax)
    if tr.stats.sampling_rate > 20.0:
        factor = int(tr.stats.sampling_rate / 10.0)
        if factor > 1:
            tr.decimate(factor=factor, no_filter=True)
    valid.append(tr)

print("Traces after trim/filter:", len(valid), flush=True)

plot_data = []
for tr in valid:
    dist_km = None
    if hasattr(tr.stats, "sac"):
        sac = tr.stats.sac
        if hasattr(sac, "dist") and sac.dist != -12345.0:
            dist_km = sac.dist
        elif hasattr(sac, "gcarc") and sac.gcarc != -12345.0:
            dist_km = sac.gcarc * 111.19
        elif (
            hasattr(sac, "stla") and hasattr(sac, "evla") and
            sac.stla != -12345.0 and sac.evla != -12345.0
        ):
            deg = locations2degrees(sac.evla, sac.evlo, sac.stla, sac.stlo)
            dist_km = deg * 111.19

    if dist_km is None or len(tr.data) == 0:
        continue
    max_amp = max(abs(tr.data.max()), abs(tr.data.min()))
    if max_amp <= 0:
        continue
    norm_data = tr.data / max_amp
    time_offset = tr.stats.starttime - event_time
    times = tr.times() + time_offset
    plot_data.append((dist_km, norm_data, times, tr.stats.station))

plot_data.sort(key=lambda row: row[0])
print("Valid traces to plot:", len(plot_data), flush=True)

colors = [
    "#CC0000", "#FF8C00", "#006400", "#4169E1", "#8B008B",
    "#000000", "#B22222", "#87CEEB", "#228B22", "#FF4500",
]
fig, ax = plt.subplots(figsize=(14, 9))
ax.set_title(str(event_time) + " (UTC)", fontsize=16, fontweight="bold", pad=30)
ax.set_xlabel("Distance (km)", fontsize=13)
ax.set_ylabel("Time after origin (s)", fontsize=13)

for i, (dist_km, norm_data, times, sta_name) in enumerate(plot_data):
    color = colors[i % len(colors)]
    x = dist_km + norm_data * amp_scale
    ax.plot(x, times, color=color, linewidth=0.5)
    ax.text(dist_km, -2, sta_name, fontsize=5, color=color,
            ha="center", va="bottom", rotation=90, fontweight="bold")

ax.set_xlim(0, 400)
ax.set_ylim(0, 115)
ax.grid(True, linestyle="-", alpha=0.3, color="gray")
ax.set_yticks(range(0, 120, 10))
fig.patch.set_facecolor("white")
ax.set_facecolor("white")
for spine in ax.spines.values():
    spine.set_edgecolor("black")
    spine.set_linewidth(0.8)

fig.savefig(output_path, dpi=200, bbox_inches="tight", facecolor="white")
plt.close(fig)
print("Done. Image saved to:", output_path, flush=True)

