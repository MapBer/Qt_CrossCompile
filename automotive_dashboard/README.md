# IGNITION automotive dashboard

A Qt Quick instrument cluster inspired by the supplied dashboard reference.
The entire view is created in `.qml` files: layouts, gauges, needles, telltales,
buttons, and sliders. The model and controller are C++17. Requires Qt Quick and
Qt Quick Controls 2 (Qt 6.2 or newer).

## Build and run

Project paths are relative to the `QT_Crosscompile` root directory. Start each
Ubuntu command block containing `cd` from that root. If already in the
project directory, skip that `cd` command. Qt host, sysroot, and Pi paths
refer to separate installations or the target machine.

Open `CMakeLists.txt` in Qt Creator, select a Qt desktop kit, and build
and run the `dashboard` target. Or, with Qt and a compiler on your PATH:

```sh
cd ./automotive_dashboard
cmake -S . -B build/local -DCMAKE_PREFIX_PATH=/home/mapber/Qt/6.8.2/gcc_64 -DBUILD_TESTING=ON
cmake --build build/local
ctest --test-dir build/local --output-on-failure
```

Start the engine, then move **Target** to accelerate or brake. **Auto drive**
starts the engine and varies speed automatically; changing Target returns to
manual control. High beam, hazards, and left/right indicators work independently.
Click the selected turn again to cancel it. Adjust Fuel to explore the low-fuel
warning and fuel exhaustion. Reset trip clears Trip A while preserving odometer.
Turning the engine off decelerates the vehicle to a stop.

This is a simulated cluster. Battery, oil, and engine telltales illuminate when
ignition is on but the engine is stopped; the brake telltale indicates stationary
status. ABS is an inactive reference telltale. State is in memory for the session.

## MVC structure

- `model/dashboardmodel.*`: vehicle state, range validation, and read-only
  `Q_PROPERTY` values with change notifications for QML bindings.
- `view/qml/Dashboard.qml`: application window, responsive layout, instrument
  cluster, and controls. Reads `vehicleModel` and calls `dashboardController`
  slots for user actions; never writes model properties.
- `view/qml/Gauge.qml`, `Telltale.qml`, `TurnArrow.qml`, `DashboardButton.qml`,
  `DashboardSlider.qml`: reusable presentation components. Drawing uses QML
  Canvas, Text, and Rectangle items; there is no QWidget or QPainter view.
- `controller/dashboardcontroller.*`: commands, timed acceleration/braking,
  RPM, consumption, distance, warmup, and indicator blinking.
- `app.cpp`: composition root. Creates the model/controller and exposes them to
  `QQmlApplicationEngine` before loading `Dashboard.qml`.
- `qml.qrc`: embeds all QML components in the executable.

Simulation uses elapsed time, a 16 ms update timer, and a capped time step to
avoid large jumps after pauses. QObject ownership handles component lifetimes.
Tests cover validation, ignition, driving, empty fuel, indicators, trip reset,
QML loading without runtime warnings, QML control commands, and model-to-view
bindings without requiring Qt Test.

For repeatable visual inspection:

```sh
dashboard --demo --snapshot preview.png
dashboard --compact --snapshot compact.png
```

CTest sets `QT_QPA_PLATFORM=offscreen` and `QT_QUICK_BACKEND=software` for headless
tests. On Windows, use the native platform (the default) for snapshots so system
fonts render correctly. If a graphics driver is unavailable, set
`QT_QUICK_BACKEND=software` to use the Qt Quick software renderer.

## Cross compile for Raspberry Pi 4B (64-bit Raspberry Pi OS)

### Project-specific requirements

The executable is named `dashboard`. The application uses C++17, Qt Quick,
Qt Quick Controls 2, and Qt Quick Layouts. Unlike the Hello World example,
it requires the Controls and Layouts QML runtime modules. `app.cpp` selects
Qt Quick Controls' **Basic** style.

`CMAKE_AUTOMOC` processes the model/controller `Q_OBJECT` declarations, and
`CMAKE_AUTORCC` embeds the QML files from `qml.qrc`. Both require Qt tools that
run on Ubuntu; the linked Qt libraries must be ARM64 libraries from the Pi.
The desktop window opens maximized. Gauges, text, and controls scale together
from a 1280 × 840 design to fit the available area; smaller screens reduce
text and control sizes. `--compact` keeps a 960 × 700 window for inspection. The vehicle data is simulated; no
CAN bus or external vehicle hardware is required.

This guide uses Qt 6 and the following paths:

| Component | Value |
|---|---|
| Ubuntu source directory | `./automotive_dashboard` |
| Raspberry Pi SSH | `pi@192.168.1.253` |
| ARM64 sysroot | `/home/mapber/rpi-sysroot` |
| Ubuntu Qt host | `/home/mapber/Qt/6.8.2/gcc_64` |
| Toolchain in this project | `cmake/toolchains/raspberry-pi-aarch64.cmake` |
| ARM64 build output | `build/rpi-aarch64/dashboard` |
| Deployed executable | `/home/pi/dashboard` |

The existing sysroot contains target Qt 6.8.2. Use matching host Qt tools and
a sysroot compatible with the OS and runtime on the Pi. This guide documents
the dashboard deployment; the previous successful Hello World run does not
by itself verify the dashboard on the Pi.

### 1. Prepare the Raspberry Pi

On the **Pi**:

```bash
sudo apt update
sudo apt install -y \
    rsync build-essential \
    qt6-base-dev qt6-declarative-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtqml-workerscript \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-templates

uname -m
qmake6 -query QT_VERSION
```

Expect `aarch64` and, for the paths in this guide, Qt `6.8.2`. If the target Qt
version differs, use the corresponding host Qt version and synchronize the
sysroot again. The development packages supply headers and CMake packages;
the QML packages supply components loaded when the application runs.

### 2. Prepare Ubuntu and Qt host tools

On **Ubuntu**:

```bash
sudo apt update
sudo apt install -y \
    build-essential cmake file pkg-config rsync \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

cmake --version
aarch64-linux-gnu-g++ --version
ssh pi@192.168.1.253
```

Run `exit` to return to Ubuntu after checking SSH.

Use the installed Qt 6.8.2 Desktop gcc_64 kit for Ubuntu x86-64. If setting up
a new machine, install that kit using the
[Qt Online Installer](https://www.qt.io/download-qt-installer-oss).

```bash
export QT_HOST_PATH=/home/mapber/Qt/6.8.2/gcc_64
"$QT_HOST_PATH/bin/qmake" -query QT_VERSION
```

Expect `6.8.2`. Do not use `/usr` if the Ubuntu system Qt has a different
version. Qt executables copied from the Pi are ARM64 and cannot run directly
on Ubuntu x86-64.

### 3. Obtain or update the sysroot

If the Hello World sysroot already matches the Pi and contains the development
packages above, reuse it. Otherwise, copy these directories from **Ubuntu**:

```bash
export RPI_SYSROOT=/home/mapber/rpi-sysroot
mkdir -p "$RPI_SYSROOT/usr"

rsync -avz --copy-unsafe-links \
    pi@192.168.1.253:/usr/include/ "$RPI_SYSROOT/usr/include/"

rsync -avz --copy-unsafe-links \
    pi@192.168.1.253:/usr/lib/ "$RPI_SYSROOT/usr/lib/"

rsync -avz --copy-unsafe-links \
    pi@192.168.1.253:/lib/ "$RPI_SYSROOT/lib/"
```

These commands preserve the target directory layout and copy the targets of
links that point outside each copied tree. A full copy of `/usr/bin` or
`/usr/share` is not required for this application. If dependency discovery
reports a specific missing data/configuration file under `/usr/share`, copy
that component separately. Create a fresh sysroot when changing OS releases.

Verify the dashboard's additional Qt dependency:

```bash
file "$RPI_SYSROOT/usr/lib/aarch64-linux-gnu/libQt6Quick.so.6"
ls "$RPI_SYSROOT/usr/lib/aarch64-linux-gnu/cmake/Qt6QuickControls2/Qt6QuickControls2Config.cmake"
ls "$RPI_SYSROOT/usr/lib/aarch64-linux-gnu/qt6/qml/QtQuick/Controls/qmldir"
ls "$RPI_SYSROOT/usr/lib/aarch64-linux-gnu/qt6/qml/QtQuick/Layouts/qmldir"
```

The library must be ARM aarch64. If a file is missing, check the corresponding
Pi development/runtime package and repeat synchronization.

### 4. Configure and cross compile on Ubuntu

The supplied toolchain reads `RPI_SYSROOT` from a CMake variable or environment
variable. It selects `aarch64-linux-gnu-g++`, sets the sysroot, confines target
header/library/package discovery to it, and sets target `pkg-config` paths.
Build programs are found on the host.

Keep `RPI_SYSROOT` exported so that CMake compiler checks also see it:

```bash
cd ./automotive_dashboard
export RPI_SYSROOT=/home/mapber/rpi-sysroot
export QT_HOST_PATH=/home/mapber/Qt/6.8.2/gcc_64

cmake -S . -B build/rpi-aarch64 \
    -DCMAKE_TOOLCHAIN_FILE="$PWD/cmake/toolchains/raspberry-pi-aarch64.cmake" \
    -DRPI_SYSROOT="$RPI_SYSROOT" \
    -DCMAKE_PREFIX_PATH="$RPI_SYSROOT/usr" \
    -DQT_HOST_PATH="$QT_HOST_PATH" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF

cmake --build build/rpi-aarch64 --target dashboard --parallel
file build/rpi-aarch64/dashboard
```

The result must contain `ARM aarch64`. Tests are disabled for this deployment
build because ARM64 test executables cannot run directly on Ubuntu x86-64.
Use a separate desktop build for local CTest, or build the tests for the Pi
and run them on the Pi.

Use a fresh build directory after changing the source location, sysroot,
compiler, or Qt version. `CMakeLists.txt.user` is Qt Creator's local IDE
configuration; the command-line build uses `CMakeLists.txt` and this toolchain.

### 5. Deploy and run on the Pi

Stop any running dashboard instance before replacing the executable. If using
the service from step 6, run on the **Pi**:

```bash
sudo systemctl stop dashboard.service
```

Skip that command if the service has not been created. Copy from **Ubuntu**:

```bash
scp build/rpi-aarch64/dashboard pi@192.168.1.253:/home/pi/dashboard
```

On the **Pi**:

```bash
chmod +x /home/pi/dashboard
ldd /home/pi/dashboard | grep 'not found'
```

No output from the library check means it reported no missing shared libraries;
QML modules and platform plugins are checked when Qt starts.

For a desktop window, open a terminal **on the Pi desktop**:

```bash
cd /home/pi
./dashboard
```

For direct HDMI output through EGLFS, grant graphics access once:

```bash
sudo usermod -aG video,render pi
```

Log out and back in (or reboot) after changing groups. Identify the installed
display manager:

```bash
systemctl list-unit-files | grep -E 'lightdm|gdm|sddm'
```

The following commands assume LightDM. Replace `lightdm.service` if needed,
or skip display manager commands if no desktop is installed. Stop the Hello
World service if you previously enabled it, and stop any manually running
EGLFS application. Only one application should control the display.

```bash
# Only if the Hello World service exists:
sudo systemctl disable --now hello-world.service

sudo systemctl stop lightdm.service
cd /home/pi
QT_QPA_PLATFORM=eglfs ./dashboard
```

To start the simulation automatically, use:

```bash
QT_QPA_PLATFORM=eglfs ./dashboard --demo
```

Press `Ctrl+C` to stop the manual instance. Restore the desktop with:

```bash
sudo systemctl start lightdm.service
```

### 6. Optional: start the dashboard after reboot

On the **Pi**, stop the manual dashboard instance and create its service:

```bash
sudo tee /etc/systemd/system/dashboard.service > /dev/null <<'EOF'
[Unit]
Description=Automotive Qt Dashboard on HDMI
After=systemd-user-sessions.service lightdm.service
Conflicts=lightdm.service hello-world.service

[Service]
Type=simple
User=pi
SupplementaryGroups=video render
WorkingDirectory=/home/pi
Environment=QT_QPA_PLATFORM=eglfs
Environment=QT_QPA_EGLFS_HIDECURSOR=1
ExecStart=/home/pi/dashboard
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

Replace LightDM references if using another desktop manager. If no desktop
manager is installed, omit its `After` and `Conflicts` entries. To launch in
demo mode, change `ExecStart` to `/home/pi/dashboard --demo`.

Disable the Hello World service first if it exists, then enable the dashboard:

```bash
# Only if the Hello World service exists:
sudo systemctl disable --now hello-world.service

sudo systemctl disable --now lightdm.service
sudo systemctl daemon-reload
sudo systemctl enable --now dashboard.service
systemctl status dashboard.service --no-pager
```

Verify automatic startup with `sudo reboot`. After reconnecting:

```bash
systemctl is-enabled dashboard.service
systemctl is-active dashboard.service
journalctl -u dashboard.service -b --no-pager -n 50
```

Expected service states are `enabled` and `active`. To restore desktop startup:

```bash
sudo systemctl disable --now dashboard.service
sudo systemctl enable --now lightdm.service
sudo systemctl set-default graphical.target
```

Use the actual display manager service name. The `display-manager.service`
alias may disappear when disabled, so enabling that alias can fail.

### 7. Rebuild after changes

On the **Pi**, stop the application (or `sudo systemctl stop dashboard.service`).
On **Ubuntu**:

```bash
cd ./automotive_dashboard
cmake --build build/rpi-aarch64 --target dashboard --parallel
scp build/rpi-aarch64/dashboard pi@192.168.1.253:/home/pi/dashboard
```

Restart on the **Pi**:

```bash
sudo systemctl start dashboard.service
```

If not using the service, repeat the manual launch from step 5 instead. QML is
embedded in the executable, so QML changes also require rebuilding. Editing
only the executable does not require `daemon-reload`; changing the service
file does, followed by a service restart.

### Troubleshooting

| Error | Action |
|---|---|
| `Set RPI_SYSROOT ...` | Export `RPI_SYSROOT` before configuring and use the supplied toolchain. |
| Missing `Qt6QuickControls2Config.cmake` | Install target `qt6-declarative-dev` and synchronize the sysroot. |
| Missing `QtQuick.Controls`, `QtQuick.Layouts`, or `QtQuick.Templates` | Install the matching `qml6-module-qtquick-controls`, `qml6-module-qtquick-layouts`, or `qml6-module-qtquick-templates` on the Pi. |
| Missing `QtQml.WorkerScript` | Install `qml6-module-qtqml-workerscript` on the Pi. |
| Missing shared library | Inspect `ldd /home/pi/dashboard`; install the matching Qt runtime/dependency on the Pi. |
| Qt version mismatch | Align host tools, target development libraries, and the Pi runtime. |
| XCB cannot connect to display | Use a terminal on the Pi desktop, or stop the desktop and use EGLFS. |
| XCB cursor dependency missing | Install `libxcb-cursor0` on the Pi. |
| EGLFS DRM permission denied | Stop desktop/other EGLFS applications, check `id` and `ls -l /dev/dri/`. |
| Dashboard clipped | The UI scales to the available area; use a higher resolution if text or controls are too small. |
| Service fails at boot | Inspect `journalctl -u dashboard.service -b`; verify executable, Qt modules, groups, and display ownership. |

Reference: [Hello World guide](../hello%20%20world/README.md).
