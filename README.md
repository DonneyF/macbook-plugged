# Macbook Plugged

On modern MacBooks it is possible to disable charging of the internal battery when plugged in to a power source, such as USB-C or MagSafe. This tool will disable charging when the MacBook is plugged into one or more of the ports. This will allow the MacBook to operate solely on the plugged in power source, when sufficiently powered.


By default this script disables charging on the MagSafe and right-side USB-C port on a 14" 2021 MacBook Pro. **This script has not been tested on other MacBook models.**

## How does it work?

MacBooks have a System Management Controller (SMC) and one of its jobs is to handle charging. It is possible to communicate with the SMC to get information about the charging status and to command the controller. For us, we are interested in retrieving information about which port a MacBook is charging from and being able to shut off charging of the battery. We use launchd to drive this functionality on events, so that there are no background processes. The general outline of this tool is:

1. launchd watches `/private/var/root/Library/Preferences/com.apple.powerd.bdc.plist`, which is modified when the power status of the macbook is changed (i.e. plugged in, disconnected, etc.)
2. We interface with the SMC to read the port that "wins" (note that when multiple power sources are introduced to a MacBook only one will be active and delivering power).
3. If we don't want charging on that particular port, we shut off charging. If there is no active plug or some other port is plugged in we re-enable charging.

## AC-W

The SMC key `AC-W` returns a hex value of the port that is currently plugged in for the MacBook. These are the value it returns for a **14" 2021 MacBook Pro**

| Port | AC-W value |
| --- | --- |
| MagSafe | `0x04` |
| Left-side USB-C, closest to MagSafe | `0x01` |
| Left-side USB-C, farthest from MagSafe | `0x02` |
| Right-side USB-C | `0x03` |
| Unplugged | `0xFF` |

## Installation

First we need to download and compile the `smc` tool from [hholtmann/smcFanControl](https://github.com/hholtmann/smcFanControl)

1. `git clone https://github.com/hholtmann/smcFanControl.git`
2. `cd smc-command`
3. `make`
4. `sudo mv smc /usr/local/bin` (or any other location for binaries)

Run the `smc` tool to make sure you want to disable charging on the proper ports. Unplug everything, then run `smc -r -k AC-W`. Plug in power to one of the ports and re-run the command. You should try plugging in to every port and making a table similar to above if you have a different MacBook.

Then we clone this repository and install the LaunchAgent

5. `git clone https://github.com/DonneyF/macbook-plugged.git`
6. `cd macbook-plugged`
7. `sudo mv disable-charging.sh /Library/LaunchAgents`
8. `sudo mv com.disable-charging.plist /Library/LaunchAgents`

Make changes to the script so you disable charging on the ports you want.

9. `sudo nano /Library/LaunchAgents/disable-charging.sh`

Once done, register the launch agent

10. `sudo launchctl load /Library/LaunchAgents/com.disable-charging.plist`

Then you can delete `smcFanControl` and `macbook-plugged` folders, and test the functionality.

## Further Customization

An experienced scripter could adjust this to disable charging when the battery hits a certain threshold. There are other [SMC keys](https://github.com/Bk-Kacprzak/kStats/blob/dev/model/Utils/knownSMCKeys.txt) you could be interested in.