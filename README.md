# XTN's Wardrive

## Overview

XTN's Wardrive is a tool designed to simplify the capture of nearby wireless networks and devices using a web-based interface. It leverages common network tools available on Kali Linux to enable wireless network scanning and management.

## Features

- **Network Interface Selection**: Automatically selects the best available wireless network interface for scanning.
- **Monitor Mode Setup**: Configures the selected wireless interface to monitor mode.
- **Web-based Interface**: Provides a user-friendly web interface to start and stop network surveys.
- **Logging**: All operations and debug information are logged to a file for easy troubleshooting.
- **Automatic Cleanup**: Restores network settings and stops the server on exit.

## Prerequisites

Ensure the following packages and dependencies are installed:

- **Kali Linux**: The script is designed to run on Kali Linux.
- **aircrack-ng**
- **wireshark**
- **macchanger**
- **Node.js** and **npm** (installed via NVM)
- **serve**: A simple static file server for Node.js.
- **xsel**: A command-line tool to access the X selection (clipboard).

## Code Overview

The script includes the following key components:

- **Interface Selection**: Automatically picks a wireless interface for scanning.
- **Monitor Mode Configuration**: Sets the wireless interface to monitor mode if supported.
- **Web Interface**: A frontend HTML page served using `serve`.
- **Logging**: Logs all actions to a timestamped log file in the project directory.
- **Process Management**: Handles starting and stopping of necessary processes and services.

## Known Issues

- The script assumes the availability of a wireless interface that supports monitor mode.
- The TP Link WN722N V2 requires specific driver setup, which is included in the script.
- The frontend currently relies on backend functionality to handle `/start` and `/stop` POST requests, which must be implemented separately.

## How to Run

1. Clone the repository and navigate to the script directory.
2. Make the script executable: `chmod +x setup.sh`.
3. Run the script as root: `sudo ./setup.sh`.

## Expected Behavior

- The script will install necessary dependencies and set up the environment.
- It will select an appropriate network interface and configure it for monitor mode.
- A web server will start, serving a page where you can start and stop network scans.
- All actions will be logged to a log file in the project directory.

## Future Improvements

- **PCAP Capture**: Integrate functionality to capture network traffic into PCAP files for further analysis.
- **Backend Integration**: Implement the backend functionality to handle network scan requests and return results.
- **Error Handling**: Improve error handling and user feedback in the web interface.

## Notes

- Ensure the wireless interface supports monitor mode and is compatible with the installed drivers.
- The POST requests to `/start` and `/stop` are placeholders; you need to implement the backend logic to handle these requests and manage the scanning process.
