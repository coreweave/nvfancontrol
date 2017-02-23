nvfancontrol
============

About
-----

**Nvfancontrol** provides dynamic fan control for NVidia graphic cards on Linux
and Windows.

Sometimes it is desirable to control the fan speed of the graphics card using a
custom response curve instead of the automatic setting that is built into the
card's BIOS. Especially in newer GPUs the fan does not kick in below 60°C or a
certain level of GPU utilization. This is a small toy project in Rust to
achieve a more elaborate control over this using either XNVCtrl in Linux or
NVAPI in Windows. It is a work in progress so proceed with caution!

The minimum supported driver version is **352.09**. The program currently
supports single GPU configurations.

HowTo
-----

### Building

Pre-built binaries for the latest release are provided however if you want to
build the project from source read along.

#### Prerequisites for Linux

You will need:

* the Rust compiler toolchain, stable >=1.1 or nightly (build)
* XNVCtrl; static (build only)
* Xlib (build and runtime)
* Xext (build and runtime)

Since XNVCtrl supports FreeBSD in addition to Linux these instructions should
also work for FreeBSD without further modifications. However nvfancontrol is
completely untested on FreeBSD (bug reports are welcome).

#### Prerequisites for Windows

You will need:

* the Rust compiler toolchain, stable >=1.10 or nightly. Be adviced that you
need the **MSVC ABI** version of the toolchain not GNU. In order to target the
MSVC ABI for Rust you will also need the [Visual C++ build
tools](http://landinghub.visualstudio.com/visual-cpp-build-tools) package. If
you are using [rustup](https://www.rustup.rs/) (which you should) you will be
warned about this (build only)
* the [NVAPI libraries](https://developer.nvidia.com/nvapi). Depending
on which version you are building (x86, x64 or both) place `nvapi.lib`,
`nvapi64.lib` or both in the root of the repository. As `nvapi` is linked
statically there are no runtime dependencies apart from the NVidia driver
(build only)

For both platforms run `cargo build --release`. Upon successful compilation the
executable can be found in `target/release/nvfancontrol`. On Linux the build
tool expects the libraries installed in `/usr/lib` or `/usr/local/lib`. In case
you have libraries installed in different locations export them using the
`LIBRARY_PATH` environment variable.

### Enable Coolbits (Linux only)

For Linux ensure that Coolbits is enabled from your X11 server settings. To
do so create a file named `20-nvidia.conf` within `/etc/X11/xorg.conf.d/`
containing the following

    Section "Device"
        Identifier "Device 0"
        Driver     "nvidia"
        VendorName "NVIDIA Corporation"
        BoardName  "IDENTIFIER FOR YOUR GPU"
        Option     "Coolbits" "4"
    EndSection

The important bit is the `Coolbits` option. Valid Coolbits values for dynamic
fan control are `4`, `5` and `12`. A sample configuration file is provided.

### Use and configure

To run the program just execute the `nvfancontrol` binary. Add the `-d` or
`--debug` argument for more output. To add a custom curve you can provide a
custom configuration file. On Linux create a file named `nvfancontrol.conf`
under the XDG configuration directory (`~/.config` or `/etc/xdg` for per-user
and system-wide basis respectively). On Windows create the file in
``C:\Users\[USERNAME]\``. The configuration file should contain pairs of
whitespace delimited parameters (Temperature degrees Celsius, Fan Speed %).
For example

    30    20
    40    30
    50    40
    60    50
    70    60
    80    80

Lines starting with `#` are ignored. You need at least **two** pairs of values.

Bear in mind that for most GPUs the fan speed can't be below 20% or above 80%
when in manual control, even if you use greater values. However, since these
limits are arbitrary and vary among different VGA BIOS you can override it
using the `-l`, or `--limits` option. For example to change the limits to 10%
and 90% pass `-l 10,90`. To disable the limits effectively enabling the whole
range just pass `-l 0`. In addition note that the program by default will not
use the custom curve if the fan is already spinning in automatic control. This
is the most conservative configuration for GPUs that turn their fans off below
a certain temperature threshold. If you want to always use the custom curve
pass the additional `-f` or `--force` argument. To terminate nvfancontrol send
a SIGINT or SIGTERM on Linux or hit Ctrl-C in the console window on Windows.

Bugs
----
Although nvfancontrol should work with most newer NVidia cards it has only been
tested with only a handful of GPUs. So it is quite possible that bugs or
unexpected behaviour might surface. In that case please open an issue in the
bug tracker including the complete program output (use the `--debug` option).

License
-------
This project is licensed under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) or any newer.
