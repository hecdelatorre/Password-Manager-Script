#!/bin/bash

# Check if pass has been initialized
check_pass_initialized() {
    if ! pass show >/dev/null 2>&1; then
        echo "Error: Password store is not initialized. Please run 'pass init' to initialize pass." >&2
        exit 1
    fi
}

# Function to list sites and usernames
list_passwords() {
    clear
    pass_list=$(tree -J $HOME/.password-store | jq -r '.[] | .contents[]? | .name as $site | .contents[]? | "\($site)/\(.name | rtrimstr(".gpg"))"')
}

# Function to add a password
add_password() {
    clear
    read -p "Enter the name of the site: " site
    read -p "Enter the username or email: " user
    SUBMENU_ADD=("Generate random password" "Enter password")

    choice=$(printf "%s\n" "${SUBMENU_ADD[@]}" | fzf --reverse --border rounded --info inline --header "Add password")
    case $choice in
        "Generate random password")
            generate_and_copy_password "$site/$user"
            ;;
        "Enter password")
            read -p "Enter your password: " password 
            echo -e "$password\n$password" | pass insert "$site/$user" --
            password=$(pass show "$site/$user")
            echo -e "\033[1m\033[33m$password\033[0m"
            echo -n "$password" | tr -d '\n' | xclip -selection clipboard
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac
    read -n 1 -s -r -p "Password added successfully! Press any key to continue..."
}

# Function to generate and copy a password
generate_and_copy_password() {
    OPTIONS=("20" "30" "50" "80" "100")
    choice=$(printf "%s\n" "${OPTIONS[@]}" | fzf --reverse --border rounded --info inline --header "Select the number of password characters to generate")
    num=0
    case $choice in
        "20") num=20 ;;
        "30") num=30 ;;
        "50") num=50 ;;
        "80") num=80 ;;
        "100") num=100 ;;
        *) echo "Invalid choice. Please enter a valid option." ;;
    esac

    if [ $num -ne 0 ]; then
        pass generate "$1" $num # You can specify the length of the password as needed
        password=$(pass show "$1")
        echo -n "$password" | tr -d '\n' | xclip -selection clipboard
        echo "Password generated and copied to clipboard."
    fi
}

# Function to show a password
show_password() {
    list_passwords
    selected_pass=$(echo "$pass_list" | fzf --reverse --border rounded --info inline --header "Passwords")
    site=$(echo "$selected_pass" | awk -F '/' '{print $1}')
    username=$(echo "$selected_pass" | awk -F '/' '{print $2}')
    password=$(pass show "$selected_pass")

    echo -e "\033[1mPassword in clipboard\033[0m\n$site\n$username"
    echo -e "\033[1m\033[33m$password\033[0m"
    echo -n "$password" | tr -d '\n' | xclip -selection clipboard
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to edit a password
edit_password() {
    list_passwords
    selected_pass=$(echo "$pass_list" | fzf --reverse --border rounded --info inline --header "Select password to edit")
    SUBMENU_EDIT=("Generate random password" "Enter password")
    choice=$(printf "%s\n" "${SUBMENU_EDIT[@]}" | fzf --reverse --border rounded --info inline --header "Edit password")
    case $choice in
        "Generate random password")
            generate_and_copy_password "$selected_pass"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        "Enter password")
            read -p "Enter your password: " password 
            if [ -n "$password" ]; then
                read -p "Are you sure you want to edit the password? (y/n): " confirm
                if [ "$confirm" == "y" ]; then
                    echo -e "$password\n$password" | pass insert "$selected_pass" --
                    password=$(pass show "$selected_pass")
                    echo -e "\033[1m\033[33m$password\033[0m"
                    echo -n "$password" | tr -d '\n' | xclip -selection clipboard
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
    selected_pass=$(echo "$pass_list" | fzf --reverse --border rounded --info inline --header "Delete password")
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
    check_pass_initialized

    while true; do
        choice=$(printf "%s\n" "${MENU[@]}" | fzf --reverse --border rounded --info inline --header "Password Manager Script")
        case $choice in
            "Add Password") add_password ;;
            "Show Password") show_password ;;
            "Edit Password") edit_password ;;
            "Delete Password") delete_password ;;
            "Exit") echo -n | xclip -selection clipboard && clear && exit ;;
            *) echo "Invalid option! Press any key to try again..." && read -n 1 -s -r ;;
        esac
    done
}

main
