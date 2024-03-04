# Password Manager Script

This is a simple Bash script for managing passwords using the `pass` password manager tool. The script provides a user-friendly menu interface to add, show, edit, and delete passwords stored in the `pass` password store.

## Dependencies

Before using the script, ensure you have the following dependencies installed:

- `pass`: The password manager used to store and retrieve passwords securely.
- `fzf`: A command-line fuzzy finder used for interactive selection.
- `jq`: A lightweight and flexible command-line JSON processor.
- `xclip`: A command-line utility for interacting with the X11 clipboard.

### Installing Dependencies

#### Debian/Ubuntu:

```bash
sudo apt install pass fzf jq xclip
```

#### Fedora:

```bash
sudo dnf install pass fzf jq xclip
```

#### Arch Linux:

```bash
sudo pacman -Sy pass fzf jq xclip
```

## GPG Key Setup

To use `pass`, you need to have a GPG keypair generated. Here's how to set up GPG keys:

1. **Generate GPG Keys**:
   
   ```bash
   gpg --full-gen-key
   ```
   
   Follow the prompts to generate your GPG key pair.
- **List GPG Keys**:
  
  ```bash
  gpg -k --keyid-format long
  ```
  
  Identify your GPG key ID (e.g., `3AA5C34371567BD2`).

- **Export GPG Keys**:
  
  ```bash
  gpg --export --armor YOUR_GPG_KEY_ID > public_key.asc
  ```
  
  ```bash
  gpg --export-secret-keys --armor YOUR_GPG_KEY_ID > private_key.asc
  ```

- **Import GPG Keys**:
  
  ```bash
  gpg --import public_key.asc
  ```
  
  ```bash
    gpg --import private_key.asc
  ```

## Menu Options

1. **Add Password**: Allows you to add a new password to the password store. You can either generate a random password or enter a password manually.

2. **Show Password**: Displays a list of saved passwords. You can select a password to view its details and copy it to the clipboard.

3. **Edit Password**: Allows you to edit an existing password. You can generate a new random password or enter a new password manually.

4. **Delete Password**: Deletes a password from the password store.

5. **Exit**: Exits the password manager script.

## Usage

To use the password manager script, simply run the script in your terminal:

bash

`./password_manager.sh`

Follow the on-screen instructions to navigate through the menu options and manage your passwords efficiently.

## License

This script is licensed under the GNU General Public License version 3.0 (GPLv3). Feel free to modify and distribute it according to the terms of the license.
