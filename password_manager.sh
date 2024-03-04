#!/bin/bash

# Check if pass has been initialized
if ! pass show >/dev/null 2>&1; then
    echo "Error: Password store is not initialized. Please run 'pass init' to initialize pass." >&2
    exit 1
fi

# Function to list sites and usernames
list_passwords() {
    clear
    pass_list=$(tree -J $HOME/.password-store | jq -r '.[] | .contents[]? | .name as $site | .contents[]? | "\($site)/\(.name | rtrimstr(".gpg"))"')
}

# Function to add a password
add_password() {
    clear
    read -p "Enter the name of the site: " site
    read -p "Enter the username: " user
    SUBMENU_ADD=("Generate random password" "Enter password")

    choice=$(printf "%s\n" "${SUBMENU_ADD[@]}" | fzf --reverse)
    case $choice in
        "Generate random password")
            pass generate "$site/$user" 30 # You can specify the length of the password as needed
            ;;
        "Enter password")
            read -p "Enter your password: " password 
            echo -e "$password\n$password" | pass insert "$site/$user" --
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac
    read -n 1 -s -r -p "Password added successfully! Press any key to continue..."
}

# Function to show a password
show_password() {
    list_passwords
    selected_pass=$(echo "$pass_list" | fzf --reverse)
    site=$(echo "$selected_pass" | awk -F '/' '{print $1}')
    username=$(echo "$selected_pass" | awk -F '/' '{print $2}')
    echo -e "$site\n$username"
    pass show "$selected_pass"
    pass show "$selected_pass" | tr -d '\n' |xclip -selection clipboard
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to edit a password
edit_password() {
    list_passwords
    selected_pass=$(echo "$pass_list" | fzf --reverse)
    SUBMENU_EDIT=("Generate random password" "Enter password")
    choice=$(printf "%s\n" "${SUBMENU_EDIT[@]}" | fzf --reverse)
    case $choice in
        "Generate random password")
            pass generate "$selected_pass" 30 # You can specify the length of the password as needed
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        "Enter password")
            read -p "Enter your password: " password 
            if [ -n "$password" ]; then
                read -p "Are you sure you want to edit the password? (y/n): " confirm
                if [ "$confirm" == "y" ]; then
                    echo -e "$password\n$password" | pass insert "$selected_pass" --
                    read -n 1 -s -r -p "Press any key to continue..."
                else
                    echo "Password edit canceled."
                fi
            else
                echo "Password cannot be empty. Password edit canceled."
            fi
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac
}

# Function to delete a password
delete_password() {
    list_passwords
    selected_pass=$(echo "$pass_list" | fzf --reverse)
    pass rm "$selected_pass"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Menu
MENU=(
    "Add Password"
    "Show Password"
    "Edit Password"
    "Delete Password"
    "Exit"
)
# Main function
main() {
    while true; do
        choice=$(printf "%s\n" "${MENU[@]}" | fzf --reverse)
        case $choice in
            "Add Password") add_password ;;
            "Show Password") show_password ;;
            "Edit Password") edit_password ;;
            "Delete Password") delete_password ;;
            "Exit") exit ;;
            *) echo "Invalid option! Press any key to try again..." && read -n 1 -s -r ;;
        esac
    done
}

main
