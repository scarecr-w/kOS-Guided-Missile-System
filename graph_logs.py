import pandas as pd
import matplotlib.pyplot as plt

# Edit this with the log filename you want to plot
log_filename = "LOGS\MISSILE_4287286416_1.LOG"

data = pd.read_csv(log_filename, skipinitialspace=True)

fig, axs = plt.subplots(3, sharex=True)
axs[0].set_title("Altitude")
axs[0].plot(data['CURRENT ALTITUDE'])
axs[0].plot(data['GOAL ALTITUDE'])
axs[0].set_ylim(ymin=0)
axs[0].legend(["Current", "Goal"])
axs[1].set_title("Pitch")
axs[1].plot(data['CURRENT PITCH'])
axs[1].plot(data['GOAL PITCH'])
axs[1].set_ylim(ymin=-30, ymax=35)
axs[1].legend(["Current", "Goal"])
axs[2].set_title("Vertical Speed")
axs[2].plot(data['CURRENT VSPEED'])
axs[2].plot(data['GOAL VSPEED'])
axs[2].legend(["Current", "Goal"])
fig.tight_layout()
plt.show()