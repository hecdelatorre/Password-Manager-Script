#!/bin/bash

# Function to display the menu
display_menu() {
    clear
    echo "Password Manager Menu"
    echo "---------------------"
    echo "1. Add Password"
    echo "2. Show Password"
    echo "3. Edit Password"
    echo "4. Delete Password"
    echo "5. Exit"
    echo
    echo -n "Enter your choice: "
}

# Function to list sites and usernames
list_passwords() {
    pass_list=$(tree -J $HOME/.password-store | jq -r '.[] | .contents[]? | .name as $site | .contents[]? | "\($site)/\(.name | rtrimstr(".gpg"))"')
}

# Function to add a password
add_password() {
    read -p "Enter the name of the site: " site
    read -p "Enter the username: " user
    pass insert "$site/$user"
    read -n 1 -s -r -p "Password added successfully! Press any key to continue..."
}

# Function to show a password
show_password() {
    list_passwords
    echo "$pass_list" | awk '{print NR, $0}'
    read -p "Enter the number of the password to show: " num
    selected_pass=$(echo "$pass_list" | awk -v num="$num" 'NR==num {print $0}')
    pass show "$selected_pass"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to edit a password
edit_password() {
    list_passwords
    echo "$pass_list" | awk '{print NR, $0}'
    read -p "Enter the number of the password to edit: " num
    selected_pass=$(echo "$pass_list" | awk -v num="$num" 'NR==num {print $0}')
    pass edit "$selected_pass"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to delete a password
delete_password() {
    list_passwords
    echo "$pass_list" | awk '{print NR, $0}'
    read -p "Enter the number of the password to delete: " num
    selected_pass=$(echo "$pass_list" | awk -v num="$num" 'NR==num {print $0}')
    pass rm "$selected_pass"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Main function
main() {
    while true; do
        display_menu
        read choice
        case $choice in
            1) add_password ;;
            2) show_password ;;
            3) edit_password ;;
            4) delete_password ;;
            5) exit ;;
            *) echo "Invalid option! Press any key to try again..." && read -n 1 -s -r ;;
        esac
    done
}

main
