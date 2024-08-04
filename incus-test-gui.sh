#!/bin/bash

# Function to check if a command exists
function command_exists {
    command -v "$1" >/dev/null 2>&1
}

# Check if dialog is installed
if ! command_exists dialog; then
    echo "Error: dialog is not installed. Please install dialog and try again."
    exit 1
fi

# Check if incus is installed
if ! command_exists incus; then
    echo "Error: incus is not installed. Please install incus and try again."
    exit 1
fi

# Check if jq is installed
if ! command_exists jq; then
    echo "Error: jq is not installed. Please install jq and try again."
    exit 1
fi

function create_container {
    dialog --inputbox "Enter container name:" 8 40 2>name.txt
    NAME=$(cat name.txt)
    rm name.txt
    incus launch images:ubuntu/20.04 $NAME
    dialog --msgbox "Container '$NAME' created successfully!" 6 40
}

function list_containers {
    CONTAINERS=$(incus list --format=json | jq -r '.[].name')
    dialog --msgbox "Containers:\n$CONTAINERS" 20 60
}

function stop_container {
    dialog --inputbox "Enter container name to stop:" 8 40 2>name.txt
    NAME=$(cat name.txt)
    rm name.txt
    incus stop $NAME
    dialog --msgbox "Container '$NAME' stopped successfully!" 6 40
}

function container_statistics {
    RUNNING_CONTAINERS=$(incus list --format=json | jq '[.[] | select(.status=="Running")] | length')
    STOPPED_CONTAINERS=$(incus list --format=json | jq '[.[] | select(.status=="Stopped")] | length')
    dialog --msgbox "Running Containers: $RUNNING_CONTAINERS\nStopped Containers: $STOPPED_CONTAINERS" 10 50
}

while true; do
    dialog --menu "Incus CLI" 15 50 5 \
    1 "Create Container" \
    2 "List Containers" \
    3 "Stop Container" \
    4 "Container Statistics" \
    5 "Exit" 2>menu.txt

    MENU_CHOICE=$(cat menu.txt)
    rm menu.txt

    case $MENU_CHOICE in
        1)
            create_container
            ;;
        2)
            list_containers
            ;;
        3)
            stop_container
            ;;
        4)
            container_statistics
            ;;
        5)
            break
            ;;
        *)
            dialog --msgbox "Invalid choice." 6 40
            ;;
    esac
done

dialog --msgbox "Goodbye!" 6 40
clear
