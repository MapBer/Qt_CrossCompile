# Qt/QML Hello World

A Qt 6 application that opens a 640 × 480 window and displays **hello world!** in the center.
QML is embedded in the executable using Qt Resources.

## Install Qt on Ubuntu

Install the build tools, Qt 6 development packages, and QML runtime modules:

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    qt6-base-dev \
    qt6-declarative-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtqml-workerscript
```

Check the installed versions:

```bash
cmake --version
qmake6 -query QT_VERSION
```

These packages install Qt for the Ubuntu development machine. Cross compilation
requires a separate Qt installation built for the target device.

## Build and run on the development machine

Project paths are relative to the `QT_Crosscompile` root directory. Start each
Ubuntu command block containing `cd` from that root. If already in the
project directory, skip that `cd` command. Qt host, sysroot, and Pi paths
refer to separate installations or the target machine.

Requires CMake >= 3.16, a C++17 compiler, and Qt >= 6.2 with Qt Quick/QML
(including the QtQuick and QtQuick.Window QML modules).

```bash
cd "./hello  world"
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
./build/hello_world
```

If CMake cannot find Qt, add `-DCMAKE_PREFIX_PATH=/path/to/Qt/6.x/gcc_64`.

## Cross compile for Raspberry Pi 4B (64-bit OS)

The application was successfully run on the Pi over HDMI using EGLFS.
The commands below use:

- Ubuntu project: `./hello  world` (two spaces between `hello` and `world`)
- Raspberry Pi SSH address: `pi@192.168.1.253`
- ARM64 sysroot: `/home/mapber/rpi-sysroot`
- Ubuntu x86-64 Qt host: `/home/mapber/Qt/6.8.2/gcc_64`
- Target Qt version found in the sysroot: **6.8.2**

Adjust the paths and SSH address if your setup changes. Run each section on
its specified machine.

### 1. Prepare the Raspberry Pi

On the **Pi**, install development packages for the sysroot and runtime modules
for the application:

```bash
sudo apt update
sudo apt install -y \
    rsync \
    build-essential \
    qt6-base-dev \
    qt6-declarative-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtqml-workerscript

uname -m
qmake6 -query QT_VERSION
```

The architecture must be `aarch64`. Use Qt host tools matching the target Qt
version. If the Pi has a different Qt version, update the host installation
and paths below accordingly.

### 2. Prepare the Ubuntu build machine

On **Ubuntu**:

```bash
sudo apt update
sudo apt install -y \
    build-essential cmake rsync file \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

ssh pi@192.168.1.253
```

Use `exit` to return to Ubuntu after checking the SSH connection.

Install the Qt 6.8.2 Desktop gcc_64 kit for Linux x86-64 using the
[Qt Online Installer](https://www.qt.io/download-qt-installer-oss).
The existing build configuration uses the installation at the path below:

```bash
export QT_HOST_PATH=/home/mapber/Qt/6.8.2/gcc_64
"$QT_HOST_PATH/bin/qmake" -query QT_VERSION
```

This should report `6.8.2`. The Ubuntu system Qt at `/usr` was 6.4.2 and is
separate from this host installation. ARM64 tools inside the sysroot cannot
run directly on Ubuntu x86-64.

### 3. Copy the sysroot from the Pi

A sysroot is a local copy of the target headers, libraries, and package
configuration files. On **Ubuntu**:

```bash
mkdir -p /home/mapber/rpi-sysroot/usr

rsync -avz --copy-unsafe-links \
    pi@192.168.1.253:/usr/include/ \
    /home/mapber/rpi-sysroot/usr/include/

rsync -avz --copy-unsafe-links \
    pi@192.168.1.253:/usr/lib/ \
    /home/mapber/rpi-sysroot/usr/lib/

rsync -avz --copy-unsafe-links \
    pi@192.168.1.253:/lib/ \
    /home/mapber/rpi-sysroot/lib/

```

`--copy-unsafe-links` copies the targets of links pointing outside the copied
tree, including absolute links. Copying `/usr/share` may take some time.

Check the copied Qt installation:

```bash
file /home/mapber/rpi-sysroot/usr/lib/aarch64-linux-gnu/libQt6Core.so.6
ls /home/mapber/rpi-sysroot/usr/lib/aarch64-linux-gnu/cmake/Qt6/Qt6Config.cmake
ls /home/mapber/rpi-sysroot/usr/include/aarch64-linux-gnu/qt6
```

The library should be identified as ARM aarch64. The current sysroot already
exists; skip copying if it still matches the Pi. Repeat synchronization after
changing target development libraries. Use a fresh sysroot after a major OS
upgrade to avoid mixing old and new libraries.

### 4. Check the CMake toolchain

The project includes `cmake_raspberry/raspberrypi-aarch64.cmake`:

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER /usr/bin/aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/aarch64-linux-gnu-g++)

set(CMAKE_SYSROOT /home/mapber/rpi-sysroot)
set(CMAKE_FIND_ROOT_PATH /home/mapber/rpi-sysroot)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
```

This selects the ARM64 compiler and target libraries while allowing build
programs to run on Ubuntu. Update the sysroot paths if you move the directory.

### 5. Configure and build on Ubuntu

```bash
cd "./hello  world"
export QT_HOST_PATH=/home/mapber/Qt/6.8.2/gcc_64

cmake -S . -B build-rpi \
    -DCMAKE_TOOLCHAIN_FILE="$PWD/cmake_raspberry/raspberrypi-aarch64.cmake" \
    -DCMAKE_PREFIX_PATH=/home/mapber/rpi-sysroot/usr \
    -DQT_HOST_PATH="$QT_HOST_PATH" \
    -DCMAKE_BUILD_TYPE=Release

cmake --build build-rpi --parallel
file build-rpi/hello_world
```

If `build-rpi` was moved from the previous project location, remove its old
CMake cache by deleting that build directory once before configuring:

```bash
cd "./hello  world"
rm -rf -- build-rpi
```

Then rerun the configure and build commands above.

The output must contain `ARM aarch64`. Use a new build directory if switching
between host and target compilers or changing the toolchain.

### 6. Deploy from Ubuntu

Exit any running copy of the application on the Pi before replacing it.

```bash
scp build-rpi/hello_world pi@192.168.1.253:/home/pi/
```

The Pi needs Qt runtime libraries compatible with those in the sysroot.
Check missing shared libraries on the **Pi**:

```bash
ldd /home/pi/hello_world | grep 'not found'
```

No output means that no shared libraries were reported missing by this check.

### 7. Run on the Pi over HDMI with EGLFS

Connect and power on the HDMI display. On the **Pi**, add the user to the
graphics groups once:

```bash
sudo usermod -aG video,render pi
```

Log out and log back in for group membership to take effect (or reboot).
Then stop the desktop before starting EGLFS; this turns off the desktop and
releases its graphics devices:

```bash
sudo systemctl stop display-manager
cd /home/pi
QT_QPA_PLATFORM=eglfs ./hello_world
```

If no display manager is installed, skip the stop command. EGLFS takes over
the display and can be launched through SSH when graphics access is available.
Stop the application with `Ctrl+C`. To restore the desktop:

```bash
sudo systemctl start display-manager
```

Alternatively, to run in a desktop window, open a terminal **on the Pi desktop**:

```bash
cd /home/pi
./hello_world
```

### 8. Rebuild after source changes

On **Ubuntu**:

```bash
cd "./hello  world"
cmake --build build-rpi --parallel
scp build-rpi/hello_world pi@192.168.1.253:/home/pi/
```

Stop the previous application before copying, then run it again on the Pi.
QML is embedded in the executable, so QML edits also require rebuilding.

### 9. Start Hello World automatically after reboot

Run these commands on the **Raspberry Pi**. This setup runs the application
directly over HDMI with EGLFS, without a desktop login.

First confirm that `/home/pi/hello_world` runs manually with EGLFS as described
in step 7. Stop the manual instance before starting the service.

```bash
chmod +x /home/pi/hello_world
sudo usermod -aG video,render pi
```

Identify the installed display manager:

```bash
systemctl list-unit-files | grep -E 'lightdm|gdm|sddm'
```

The commands below assume `lightdm.service`. Replace that name if your system
uses a different display manager. If no desktop is installed, skip the display
manager commands and omit the `Conflicts` and `After` entries for LightDM below.

Create the service file:

```bash
sudo tee /etc/systemd/system/hello-world.service > /dev/null <<'EOF'
[Unit]
Description=Qt Hello World on HDMI
After=systemd-user-sessions.service lightdm.service
Conflicts=lightdm.service

[Service]
Type=simple
User=pi
SupplementaryGroups=video render
WorkingDirectory=/home/pi
Environment=QT_QPA_PLATFORM=eglfs
ExecStart=/home/pi/hello_world
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

`ExecStart` selects the executable, `Environment` selects EGLFS, and
`SupplementaryGroups` grants the process membership in the graphics groups.
`Restart=on-failure` retries after an application failure. `WantedBy` allows
the service to be enabled for boot. The LightDM conflict and ordering prevent
the desktop and EGLFS from taking control of the display at the same time.

Stop and disable the desktop, then load and enable the application service:

```bash
sudo systemctl disable --now lightdm.service
sudo systemctl daemon-reload
sudo systemctl enable --now hello-world.service
systemctl status hello-world.service --no-pager
```

`daemon-reload` reads the service definition. `enable` schedules it for future
boots, and `--now` also starts it immediately. Test automatic startup:

```bash
sudo reboot
```

After reconnecting through SSH, inspect the service and its logs:

```bash
systemctl is-enabled hello-world.service
systemctl is-active hello-world.service
journalctl -u hello-world.service -b --no-pager -n 50
```

Expected states are `enabled` and `active`.

#### Update the executable while using the service

Stop the service on the **Pi** before replacing the executable:

```bash
sudo systemctl stop hello-world.service
```

Build and copy from **Ubuntu** using step 8, then start it on the **Pi**:

```bash
sudo systemctl start hello-world.service
```

To restart the currently installed application:

```bash
sudo systemctl restart hello-world.service
```

#### Restore the desktop after reboot

On the **Pi**:

```bash
sudo systemctl disable --now hello-world.service
sudo systemctl enable --now lightdm.service
sudo systemctl set-default graphical.target
```

The desktop starts immediately and is enabled for subsequent boots.
Reboot if you want to verify the change:

```bash
sudo reboot
```

#### Switch back to Hello World

```bash
sudo systemctl disable --now lightdm.service
sudo systemctl enable --now hello-world.service
```

Use the actual display manager name instead of the `display-manager.service`
alias in these enable/disable commands. Disabling a display manager can remove
that alias, causing later commands to report `Unit display-manager.service
does not exist`. Re-enable the actual service, such as `lightdm.service`, to
restore the desktop.

### Troubleshooting

| Error | Action on the Pi |
|---|---|
| `libQt6Qml.so.6: cannot open shared object file` | Install `libqt6qml6` and `libqt6quick6`; use `ldd` to check other missing libraries. |
| `module "QtQuick" is not installed` | Install `qml6-module-qtquick`. |
| `module "QtQuick.Window" is not installed` | Install `qml6-module-qtquick-window`. |
| `module "QtQml.WorkerScript" is not installed` | Install `qml6-module-qtqml-workerscript`. |
| `could not connect to display` with XCB | Launch from a terminal on the Pi desktop, or use EGLFS with the desktop stopped. |
| XCB reports missing cursor support | Install `libxcb-cursor0`. |
| EGLFS reports DRM `Permission denied` | Stop the display manager, check `id` and permissions with `ls -l /dev/dri/`, and confirm the new groups are active. |
| HDMI reports `disconnected` | Check display power/input and cable; try HDMI0, the micro-HDMI port nearest USB-C power. |
| `Qt_6.x not found` | Align the Pi runtime with the Qt libraries used in the sysroot, then rebuild if necessary. |

Reference: [Qt Wiki: Cross-Compile Qt 6 for Raspberry Pi](https://wiki.qt.io/Cross-Compile_Qt_6_for_Raspberry_Pi).
