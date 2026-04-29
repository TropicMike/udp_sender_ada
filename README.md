# UDP Sender

A cross-platform GUI application for sending UDP strings, written in Ada using the [Gnoga](https://github.com/Blady-Com/gnoga) web GUI framework and GNAT.Sockets.

![Ada](https://img.shields.io/badge/Ada-2012-blue)
![License](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-green)
![Build](https://github.com/TropicMike/udp-sender-ada/actions/workflows/build.yml/badge.svg)

## Features

- Editable destination IP address and port
- Multi-line message input
- Send button transmits the message as a UDP datagram
- Log area displays send confirmations and errors
- Works on macOS and Windows via a browser-based GUI

## Prerequisites

- [Alire](https://alire.ada.dev/) (Ada package manager)
- GNAT compiler (installed automatically by Alire)

The project file auto-detects the platform using the `OS` environment variable and only includes the macOS SDK linker path on non-Windows systems. If your macOS SDK is in a non-default location, update the `Linker` package in `udp_sender.gpr`.

## Build

```sh
alr build
```

## Run

```sh
alr run
```

Or run the binary directly:

```sh
./bin/udp_sender
```

The application starts an HTTP server on port 8080 and opens a GUI in your default browser at `http://localhost:8080`. Enter a destination IP, port, and message, then click **Send** to transmit a UDP datagram.

Click **Quit** or close the browser tab to stop the application.

## Project Structure

```
udp_sender/
  src/
    udp_sender.adb    -- Main application (GUI + UDP logic)
  html/
    boot.html          -- Gnoga bootstrap HTML
  js/
    boot.js            -- Gnoga bootstrap JavaScript
    jquery.min.js      -- jQuery (required by Gnoga)
  udp_sender.gpr       -- GPR project file
  alire.toml            -- Alire manifest
```

## CI

GitHub Actions builds the project on both macOS and Windows on every push and pull request to `main`. Build artifacts (the compiled binary) are available for download from each workflow run.

## License

MIT OR Apache-2.0 WITH LLVM-exception
