# kOS Guided Missile System

## File Structure

The code for the guided missile system has two parts:

* `MISSILE_SYSTEM.ks` : This file is to be run on the plane's processor. It sets up the GUI, identifies the attached missiles, and transmits the target coordinates to the missile processors when firing.
* `GUIDED_MISSILE.ks` : This file is to be run on each missile's processor. It waits to recieve the target coordinates, decouples itself from the plane, and navigates to the target.

In addition, the "Fire" button uses three custom images `FIRE.png`, `FIRE_SELECTED.png`, and `FIRE_PRESSED.png`, which all are stored in the `IMAGES` folder.

Lastly, if logging is enabled, log files for each missile will be stored in the `LOGS` folder.

## Using the GUI

![GUI Example](/GUI_Example.png)

The GUI has two main control sections:

### Targeting

The targeting section allows you to show or hide the target by toggling the "Visibility" options. 

You can also have the target move with your plane by setting "Locking" to "Free", or have the target stay fixed on a certain coordinate position by setting "Locking" to "Locked".

Lastly, you can adjust a locked target using the direction buttons and the slider on the right (the slider adjusts the step size of the buttons).

### Missiles

The missiles section allows you to select one of the attached missiles to view its details on the right panel, or to fire by pressing the "Fire" button at the bottom.

## Creating Missiles/Planes

The plane itself needs only to have a processor running `MISSILE_SYSTEM.ks` and to be able to fly. The missiles need a processor running `GUIDED_MISSILE.ks` and to be attached to the plane using a single decoupler/separator.

While the code will run on any configuration of plane/missile, it is only tuned to the example missiles accessible in the `MISSILE PLANE.craft` file.

## Logging/Plotting

To accomodate tuning of the targeting system, each missile can log various properties of its flight. Logging can be turned on by setting the global `LOGGING` variable in `GUIDED_MISSILE.ks` to true.

The log files generated are readable as csv files, and can be quickly plotted using `graph_logs.py`.