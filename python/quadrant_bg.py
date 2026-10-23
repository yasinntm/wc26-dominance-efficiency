import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from pathlib import Path

#Tableau axis bounds
X_MIN = -2.648396238
X_MAX =  1.982194043
Y_MIN = -1.226598395
Y_MAX =  1.166188468

x_span = X_MAX - X_MIN
y_span = Y_MAX - Y_MIN
aspect = x_span / y_span   # ≈ 1.935

#Figure size
HEIGHT = 6
WIDTH = HEIGHT * aspect
fig = plt.figure(figsize=(WIDTH, HEIGHT), dpi=200)
ax = fig.add_axes([0, 0, 1, 1])   # full bleed
ALPHA = 0.35
colors = {
    'HH': '#009E73',
    'HL': '#56B4E9',
    'LH': '#E69F00',
    'LL': '#D55E00',
}



ax.add_patch(Rectangle((0, 0),         X_MAX,  Y_MAX,   color=colors['HH'], alpha=ALPHA))
ax.add_patch(Rectangle((0, Y_MIN),     X_MAX, -Y_MIN,   color=colors['HL'], alpha=ALPHA))
ax.add_patch(Rectangle((X_MIN, 0),    -X_MIN,  Y_MAX,   color=colors['LH'], alpha=ALPHA))
ax.add_patch(Rectangle((X_MIN, Y_MIN), -X_MIN, -Y_MIN,  color=colors['LL'], alpha=ALPHA))

ax.set_xlim(X_MIN, X_MAX)
ax.set_ylim(Y_MIN, Y_MAX)
ax.axis('off')

#Transparent bg
fig.patch.set_alpha(0.0)
ax.patch.set_alpha(0.0)

OUTPUT = Path("figures")/"quadrant_background.png"
plt.savefig(OUTPUT, dpi=200, transparent=True, pad_inches=0)
plt.close()

x_pct = (0 - X_MIN) / x_span * 100
y_pct = (0 - Y_MIN) / y_span * 100
print(f"Image size:  {WIDTH:.2f} x {HEIGHT} inches  (aspect {aspect:.3f})")
print(f"Zero line at:  X = {x_pct:.2f}%  from left   |   Y = {y_pct:.2f}%  from bottom")
print(f"Saved (transparent): {OUTPUT}")