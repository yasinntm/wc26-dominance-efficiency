import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"

# Load and merge (same as PCA script)
dom = pd.read_csv(DATA_DIR / "dominance_z_scores.csv")
eff = pd.read_csv(DATA_DIR / "efficiency_z_scores.csv")
df = dom.merge(eff, on="team")

metric_cols = [
    "z_possession_pct",
    "z_build_up_opposed_pct",
    "z_progression_pct",
    "z_final_third_pct",
    "z_pass_completion",
    "z_completed_line_breaks",
    "z_xg_per_attempt",
    "z_goals_per_xg",
    "z_attempts_per_100_passes",
    "z_xg_per_possession",
]

corr = df[metric_cols].corr()

#Heatmap
fig, ax = plt.subplots(figsize=(11, 9))
im = ax.imshow(corr, cmap="RdBu_r", vmin=-1, vmax=1)

#Ticks and labels
short_labels = [c.replace("z_", "") for c in metric_cols]
ax.set_xticks(range(len(metric_cols)))
ax.set_yticks(range(len(metric_cols)))
ax.set_xticklabels(short_labels, rotation=45, ha="right", fontsize=9)
ax.set_yticklabels(short_labels, fontsize=9)

#Annotations
for i in range(len(metric_cols)):
    for j in range(len(metric_cols)):
        val = corr.iloc[i, j]
        color = "white" if abs(val) > 0.6 else "black"
        ax.text(j, i, f"{val:.2f}", ha="center", va="center", fontsize=7.5, color=color)

fig.colorbar(im, ax=ax, label="Pearson correlation", shrink=0.8)
ax.set_title("Correlation Matrix — Ten Adjusted Z-Scores\n2026 FIFA World Cup", fontsize=13, fontweight="bold")
plt.tight_layout()
plt.savefig(BASE_DIR / "figures" / "correlation_matrix.png", dpi=200, bbox_inches="tight")
plt.close()