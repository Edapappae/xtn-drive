#!/bin/bash

VERSION="1.1"

# Determine the project directory
PROJECT_DIR="$(pwd)/christians-wardrive"
LOG_FILE="$PROJECT_DIR/wardrive_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - $1" | tee -a "$LOG_FILE"
}

# Print script version
mkdir -p "$PROJECT_DIR"
log_message "Starting Christian's Wardrive Script - Version $VERSION"

# Function to check for Python and install if necessary
check_python() {
    log_message "Checking for Python..."
    if ! command -v python3 &> /dev/null; then
        log_message "Python3 not found, installing Python3..."
        apt-get update
        apt-get install -y python3
    else
        log_message "Python3 is already installed."
    fi
}

# Function to check for pip and install if necessary
check_pip() {
    log_message "Checking for pip..."
    if ! command -v pip3 &> /dev/null; then
        log_message "pip not found, installing pip..."
        apt-get install -y python3-pip
    else
        log_message "pip is already installed."
    fi
}

# Function to check and install Flask
check_flask() {
    log_message "Checking for Flask..."
    if ! python3 -c "import flask" &> /dev/null; then
        log_message "Flask not found, installing Flask..."
        pip3 install flask
    else
        log_message "Flask is already installed."
    fi
}

# Function to create backend files
create_backend_files() {
    log_message "Creating backend files..."

    cat <<EOF > "$PROJECT_DIR/backend.py"
from flask import Flask, jsonify, request
import subprocess
import signal
import os

app = Flask(__name__)
scan_process = None

@app.route('/start', methods=['POST'])
def start_scan():
    global scan_process
    if scan_process is None:
        command = [
            'airodump-ng',
            '--write', 'data/capture',
            '--output-format', 'csv',
            'wlan0'  # Adjust with the selected interface
        ]
        scan_process = subprocess.Popen(command)
        return jsonify({"status": "Scanning started"}), 200
    else:
        return jsonify({"error": "Scan already in progress"}), 400

@app.route('/stop', methods=['POST'])
def stop_scan():
    global scan_process
    if scan_process is not None:
        os.kill(scan_process.pid, signal.SIGTERM)
        scan_process = None
        return jsonify({"status": "Scanning stopped"}), 200
    else:
        return jsonify({"error": "No scan in progress"}), 400

if __name__ == '__main__':
    app.run(port=5000)
EOF
}

# Function to start the backend server
start_backend() {
    log_message "Starting backend server..."
    (cd "$PROJECT_DIR" && python3 backend.py) &
    backend_pid=$!
    log_message "Backend server started with PID: $backend_pid"
}

# Function to check and install NVM
install_nvm() {
    log_message "Checking for NVM..."
    if ! command -v nvm &> /dev/null; then
        log_message "NVM not found, installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    else
        log_message "NVM is already installed."
    fi
}

# Function to install Node.js using NVM
install_node() {
    log_message "Installing Node.js..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
}

# Function to check and install npm
check_npm() {
    log_message "Checking for npm..."
    if ! command -v npm &> /dev/null; then
        log_message "npm not found, please check Node.js installation."
        exit 1
    else
        log_message "npm is already installed."
        log_message "Updating npm to the latest version..."
        npm install -g npm
    fi
}

# Function to install serve
install_serve() {
    log_message "Installing serve..."
    npm install -g serve
}

# Function to prepare frontend
prepare_frontend() {
    log_message "Preparing frontend..."

    mkdir -p "$PROJECT_DIR"
    mkdir -p "$PROJECT_DIR/data"

    cat <<EOF > "$PROJECT_DIR/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Christian's Wardrive</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <style>
        button {
            width: 100%;
            padding: 1rem;
        }
    </style>
</head>
<body class="bg-gray-900 text-white min-h-screen flex flex-col justify-center items-center">

    <pre class="text-green-400 mb-8">
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS@@@@@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS@@@@@@?;;;;???????@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS@@@@@@@@@@@@;::.:;;;:;;????@@@@@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSS@@@@@@@@@@@@@@@@@@@@?;;;?@@@@@@@??@@@@@@@@@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSS@@?@@?@@@@@@@@@@@@@@@@@@@@@??@@@@@@@@@@@@@@@@@??@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSS@???@@@@?@@@@@@@@@@@@@@@@@@???@@@@@@@@@@@@@@@@@@???SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSS@?????????????@@@@@@@@@@@@@@@@@??@@@@@@@@@@@@@@@@@????;@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSS?;::;???????;?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?????@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSS@::..;?;:;;?;;?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@??@@???@@@@@?;;@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSS?.,,,:?:::;?;;?@@@@@?@@@@@@@@@@@@@@@@@@@@@@@@@@@????@@???@@@@?:.@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSS?++.,:::::;??;;?@@@??@@@@@@@@@@@@@@@@@@@@@@@@@@@@?????@@@??@@@@?.,;SSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSS@,+,,,:..:;????@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?;??@@@?;?@@?:..;@SSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSS:,,++..,,:;??@@@@@@@???@@@?@@@@@@@@@@@@@@@@@@@@@@@@@?:;;;?;??.:@@;;::@SSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@:.,,+..,,.;?@@@@@@????@???@@@@@@@@@@@@@@@@@@@@@@@@@??:,;;;?:;?,:??@;.:SSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@:..,.:.,,;@@@@@@@?@@@@@@???@@@@@@@@@@@@@@@@@@@?????@?;..??:;:::.;:;?;.;@SSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS;.;.:;,+,;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?;?????;::??;:;:.:?;??;:;@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSS?:;;:;.+,;@@@@@?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@??@@???@????::;;:.:..:?;;?;;@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSS?;:?;?:.:?@@@@??@@@@@@@@@@@@@@@@@@@@@@@@@@@@@????????@@@@??;::??;..:;:?:;?:?SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSS;;;??;;;??@@;??@@@@@@???@@@@@@@@@@@?@@@@????????@?;?@@@@@@;;;??;;:.:???;??;SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSS@?;???;????;?@@@@@@@@???@@@@@???@@@@@???????;;;??@@??@@@??@??;;?;::.:;??;??@SSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS??@?;;@?:;@@@@@@@@@???@@@@??;;@@@@@@@?;;??????@@@@@@@?@@:?@?;;??;;:;:;???@@SSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS?@?;;??;:;;;??@@@@@?@?@?????;;@@@??????;?@@@@@@@@@@@@@@@;:?@?;;@@:::;;???@@SSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@@@;;?:::::???@@@@@@???;;:;@@??????;;???@@@@@@@@@@@@@@@???;@??;?@?::;;;;??SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@@@:.;;:.;@@@@@@@@@@@?;;...;@@?;????????@@@@@@@@@@@@@@@@?@??@???@@@?;?????SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@@;:;??;?@@@@@@@@@@@@?;:..,.@@@??@???@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?????@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@@????@@@@@@??@@@@@@@;;:,,.,;@@@?@@@?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@??@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSS@@@??@@@@@?;?@@@@@@@@;;:.,.,:??@??@@;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@??@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSS@@@?@@@@@@@@@@@@@@@?;;:,,.,,;;??;?@@:;??@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSS@@@@@@@@@@@@@@@@@@@?;;.,+.+,..:;;;?@:.;??@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?@SSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSS@@@@@@@@@@@@@@@@@@@?;:.,,,++++,:;:;@;+.:;??@@@@@@@@@@@@@@@@?;?@@@@@@@@@@SSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSS@@@@@@@@@@@@@@@@@@?;:.,,,+**+,:;.;@?,+.,;?;@??@@@@@@@@@@@?;:;?@@@@@@@@@SSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSS@@@@@@@@@@@@@@@@@@@@?:.,,++*++,,.:?;,+,,:;:;??@@@@@@@@??;::::;@@@@@@@@SSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSS@@@@@@@@@@@@@@@@@@@@@??;;;:.,++,,.,+*+.::????????;::::......:;@@@@@@SSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSS@@@@@@@@@?;;?;;;;;;??;;????:.,,+++++,.:;;??@?;@??;;;:..,,+,.?@@@@@SSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSS@@@@@@?;:::;;;???@@@?@????;.,,+++,,.:;??;?????:??;.,,,++,.;?@??SSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSS@@?@@?;:...;;??;;????::;;;:.,,,+,..:;:.+.:::..::...+++,+:?@??SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSS???;;:,..::;;:.,.,++,...;.::**.:.:,,.,,+++,..:.+,,,:++:;;@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSS;;?::;;;..:::..,,,,,++,;.,+*%*+.;+++,,,....,,,,,,+,++::@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSS@.:.,,..:.,,...,,,++++,:,,+*%*++.,**++++++++*+,:++++,;;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSS@;:,,,,::,++++++++*+,:,+++*%*+++..+********+,,,,,,+.@?SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSS@.+...,..,,++++,.:.++,++*%**+++,::.,,+,,..,,,,,,+;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSS?+,...........,,++,,,++*%%*+++++++,,,,,,,,,++,,,@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSS.,.,,,,,,++***+++,,,+**%%*++++,+******+++,,,,+.SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSS@,,.,,,,+++++++++,+++**%%**++++***++++++,,,,,+?SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSS;,...,,,,+++++**,,,,+***+,..:.**++++++,,,,,,.SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSS:,...,,,,+++++*,;??;..,.:;;:,++++++,,,,..,.@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS......,,,,,,++++,.:;;;;:,+*+++,,,,,,,...,.?SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS:.::........,,++++,,.,++,,.::.,+++,...,,:,,SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS?,:::..,,,..::::::.....::::.,++++,.:...,:+#:SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS.+:::;:.,,,,,.....,,,,,....,,,,,,...::::,%#*@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS++.:::::........::::::...,+++,,,..:;;;:,*%# .SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSS,%+,.;;;::..,,,+++++++******++,,,.;??;.+*%## #?SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSSSSSSSS:#%*,.:;??;;:.,++***********++,,.;??;.,+*%#####+@SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSS@@@@@@,#%%*,::;;???;:,,++++++++++++,.;??:.,+*%####    .@@SS@@@@@@@SSSSSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSSS@@@@@?,*%%%*+,..::;;??;:..,,,....:;??;:.,*%#########  +;@@@@@@@@@@@@@SSSSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSSSS@@@@@@@.+%**%%%*+,..:::;?????????@@?;;:.+%#         ##*+?@@@@@@@@@@@@@@@SSSSSSSSSSSSSSSS
SSSSSSSSSSSSSSSSSSSS@@@@@@@@@?,*%**%%##%%+.:;;;;;;;;::::;;:.+%#          ##%,;S@@@@@@@@@@@@@@@@SSSSSSSSSSSSSSS
SSSSSSSSSSSSS@@@@@@@@@@@@@@@@@:+%%%%%%####%*,.;@??@@@@@@@@.#           ###%,@@@@@@@@@@@@@@@@@@@@@SSSSSSSSSSSSS
SSSSSSSSSSS@@@@@@@@@@@@@@@@@@@@,*####%%######,?@@@?;::;:::;:%         #%##+?@@@@@@@@@@@@@@@@@@@@@@@SSSSSSSSSSS
SSSSSSSSSS@@@@@@@@@@@@@@@@@@@@S;+%######### +;@@@???;.,...:?:%     ##%%##*?@@@@@@@@@@@@@@@@@@@@@@@@@@SSSSSSSSS
                                             
    </pre>

    <div class="mb-8">
        <h1 class="text-3xl font-bold mb-4 text-center">Christian's Wardrive</h1>
        <p class="mb-6 text-center">Simplifying the capture of nearby wireless networks and devices.</p>
        
        <p>Selected Interface: <span id="selected-interface"></span></p>
        
        <div class="flex space-x-4">
            <button id="start-button" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded">
                Start Survey
            </button>
            <button id="stop-button" class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded">
                Stop Survey
            </button>
        </div>
    </div>

    <div id="results" class="w-full max-w-2xl bg-gray-800 p-4 rounded shadow-md">
        <h2 class="text-xl font-semibold mb-4">Detected Networks</h2>
        <ul id="network-list" class="list-disc list-inside space-y-2">
            <!-- Dynamic content will be injected here -->
        </ul>
    </div>

    <script>
        const startButton = document.getElementById('start-button');
        const stopButton = document.getElementById('stop-button');
        const networkList = document.getElementById('network-list');
        const selectedInterface = document.getElementById('selected-interface');

        selectedInterface.innerText = '$selected_interface';

        startButton.addEventListener('click', () => {
            fetch('http://localhost:5000/start', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    console.log(data);
                })
                .catch(error => console.error('Error:', error));
        });

        stopButton.addEventListener('click', () => {
            fetch('http://localhost:5000/stop', { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    console.log(data);
                })
                .catch(error => console.error('Error:', error));
        });
    </script>

</body>
</html>
EOF
}

# Function to start the frontend server
start_frontend() {
    log_message "Starting frontend server..."
    serve -s "$PROJECT_DIR" -l 3000 &
    serve_pid=$!
    sleep 2

    log_message "Opening the application in the default web browser..."
    if command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:3000
    elif command -v gnome-open &> /dev/null; then
        gnome-open http://localhost:3000
    elif command -v open &> /dev/null; then
        open http://localhost:3000
    else
        log_message "Could not detect the web browser opener command."
    fi
}

# Function to clean up unused packages
cleanup_unused_packages() {
    log_message "Cleaning up unused packages..."
    apt autoremove -y
}

# Function to final package and dependency checks
final_package_check() {
    log_message "Performing final package and dependency checks..."
    if ! command -v serve &> /dev/null; then
        log_message "Serve is not installed, attempting to install again..."
        install_serve
    fi
}

# Function to detect and select network interface
select_network_interface() {
    log_message "Selecting network interface..."
    interfaces=$(ip link show | awk -F: '$0 !~ "lo|vir|wlx|vmnet|docker|veth|br-|tap|tun|^[^0-9]"{print $2}')
    echo "Available network interfaces:" | tee -a "$LOG_FILE"
    echo "$interfaces" | tee -a "$LOG_FILE"
    for iface in $interfaces; do
        if [[ $iface == wl* || $iface == wlan* ]]; then
            selected_interface=$iface
            break
        fi
    done

    if [ -z "$selected_interface" ]; then
        log_message "No suitable wireless interface found, using default."
        selected_interface=$(ip link show | awk -F: '$0 !~ "lo|vir|vmnet|docker|veth|br-|tap|tun|^[^0-9]"{print $2}' | head -n 1)
    fi

    log_message "Selected interface: $selected_interface"
}

# Function to set network interface in monitor mode
set_monitor_mode() {
    log_message "Checking monitor mode support for $selected_interface..."
    if aireplay-ng --test $selected_interface | grep -q "no such device"; then
        log_message "Interface $selected_interface does not support monitor mode."
        exit 1
    else
        log_message "Interface $selected_interface supports monitor mode."
    fi

    log_message "Setting interface $selected_interface to monitor mode..."
    kill_interfering_processes

    ifconfig $selected_interface down
    iwconfig $selected_interface mode monitor
    ifconfig $selected_interface up
    log_message "Interface $selected_interface is now in monitor mode."
}

# Function to selectively kill interfering processes
kill_interfering_processes() {
    log_message "Killing interfering processes..."
    interfering_processes=("wpa_supplicant" "dhclient" "NetworkManager")
    for process in "${interfering_processes[@]}"; do
        pids=$(pgrep -f $process)
        if [[ ! -z "$pids" ]]; then
            log_message "Killing process $process with PIDs: $pids"
            kill -9 $pids
        fi
    done
}

# Function to handle cleanup on exit
cleanup_on_exit() {
    log_message "Cleaning up on exit..."
    kill $serve_pid
    kill $backend_pid
    log_message "Frontend and backend servers stopped."
    cleanup_unused_packages
    log_message "Restarting network services..."
    systemctl start NetworkManager.service

    if ping -c 1 8.8.8.8 &> /dev/null; then
        log_message "Internet connectivity restored."
    else
        log_message "Failed to restore internet connectivity. Please check your network settings."
    fi
}

# Main script logic
main() {
    trap cleanup_on_exit EXIT
    check_python
    check_pip
    check_flask
    create_backend_files
    install_nvm
    source ~/.nvm/nvm.sh
    install_node
    check_npm
    install_serve
    prepare_frontend
    select_network_interface
    set_monitor_mode
    final_package_check
    start_backend
    start_frontend

    while true; do
        sleep 1
    done
}

main
