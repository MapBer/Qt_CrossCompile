# Qt CrossCompile

A hands-on project for building Qt 6/QML applications on Ubuntu and cross
compiling them for a Raspberry Pi 4B running 64-bit Raspberry Pi OS (ARM64).
The applications use QML interfaces, C++17, and the CMake build system.

## Applications

| Directory | Description | Guide |
|---|---|---|
| `hello  world/` | A basic Qt Quick application displaying “hello world!” for learning how to build, cross compile, and deploy to the Pi. | [Hello World](hello%20%20world/README.md) |
| `automotive_dashboard/` | A simulated automotive instrument cluster using MVC, with speed, RPM, fuel level, telltales, and an automatic driving mode. | [Automotive Dashboard](automotive_dashboard/README.md) |

The directory name `hello  world` contains **two spaces**. Enclose its path in
quotes when running shell commands.

## Requirements

- CMake 3.16 or newer and a compiler supporting C++17.
- Qt 6.2 or newer with Qt Quick/QML. The dashboard also requires Qt Quick
  Controls 2 and the Controls, Layouts, and Templates QML runtime modules.
- For cross compilation: an `aarch64-linux-gnu` compiler, a Pi sysroot, and
  Qt host tools matching the Qt version on the target device.
- A Raspberry Pi 4B running a 64-bit operating system to deploy and run ARM64
  applications.

Each application has its own `CMakeLists.txt`. The repository root does not
provide a shared build configuration.

## Quick start on the development machine

Run the following commands from the repository root, with Qt configured so
that CMake can find it.

**Hello World:**

```bash
cmake -S "./hello  world" -B "./hello  world/build" -DCMAKE_BUILD_TYPE=Release
cmake --build "./hello  world/build" --parallel
"./hello  world/build/hello_world"
```

**Automotive Dashboard:**

```bash
cmake -S ./automotive_dashboard -B ./automotive_dashboard/build/local -DBUILD_TESTING=ON
cmake --build ./automotive_dashboard/build/local --parallel
ctest --test-dir ./automotive_dashboard/build/local --output-on-failure
./automotive_dashboard/build/local/dashboard
```

If CMake cannot find Qt, add `-DCMAKE_PREFIX_PATH="<Qt-host-directory>"` to the
configure command, replacing `<Qt-host-directory>` with your local Qt path.

## Cross compilation and deployment

The workflow involves preparing Qt on the Pi, synchronizing its sysroot to
Ubuntu, configuring CMake with an ARM64 toolchain, building, and copying the
executable to the Pi over SSH/SCP. Applications can run in a desktop window
or directly over HDMI using EGLFS.

See the [Hello World](hello%20%20world/README.md) and
[Automotive Dashboard](automotive_dashboard/README.md) guides for installation,
toolchain setup, deployment, startup services, and troubleshooting.

Project paths in the README files are relative. Adjust Qt and sysroot paths
and the Pi SSH address to match your environment.
