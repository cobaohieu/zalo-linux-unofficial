#!/bin/bash
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Define temporary directory variables with timestamp for uniqueness
UPDATER_TEMP_DIR="/tmp/zalo-updater-$(date +%s)"
CLONE_TEMP_DIR="/tmp/zalo-update-$(date +%s)"

# Check for required commands
for cmd in curl wget git unzip sed; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' is not installed." >&2
        exit 1
    fi
done

# Get language preference
LANGUAGE=$(cat "$HOME/.local/share/Zalo/lang.txt" 2>/dev/null)
if [[ "$LANGUAGE" != "EN" && "$LANGUAGE" != "VI" ]]; then
    LANGUAGE="EN"
fi

check_version() {
    local current_version
    local latest_version
    local version_file="$HOME/.local/share/Zalo/version.txt"
    local version_url="https://raw.githubusercontent.com/cobaohieu/zalo-linux-unofficial/main/version.txt"

    # Check current version
    if [[ -f "$version_file" && -r "$version_file" ]]; then
        current_version=$(cat "$version_file")
    else
        current_version="0.0.0"  # Default if version file doesn't exist
    fi

    # Get latest version with error handling
    if ! latest_version=$(curl -sf "$version_url"); then
        if [[ "$LANGUAGE" == "EN" ]]; then
            echo "Error: Failed to check latest version. Please check your internet connection." >&2
        else
            echo "Lỗi: Không thể kiểm tra phiên bản mới nhất. Vui lòng kiểm tra kết nối mạng." >&2
        fi
        exit 1
    fi

    # Validate version format (basic check)
    if [[ ! "$latest_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if [[ "$LANGUAGE" == "EN" ]]; then
            echo "Error: Invalid version format received from server." >&2
        else
            echo "Lỗi: Định dạng phiên bản từ máy chủ không hợp lệ." >&2
        fi
        exit 1
    fi

    # Compare versions
    if [[ "$current_version" == "$latest_version" ]]; then
        if [[ "$LANGUAGE" == "EN" ]]; then
            echo "You already have the latest version ($current_version)."
        else
            echo "Bạn đã có phiên bản mới nhất ($current_version)."
        fi
        exit 0
    fi

    if [[ "$LANGUAGE" == "EN" ]]; then
        echo "Updating from $current_version to $latest_version..."
    else
        echo "Đang cập nhật từ $current_version lên $latest_version..."
    fi
}

update_zalo() {
    # Clean up any existing temp directory
    if [[ -d "$UPDATER_TEMP_DIR" ]]; then
        rm -rf "$UPDATER_TEMP_DIR"
    fi

    if [[ "$LANGUAGE" == "EN" ]]; then
        echo "Updating Zalo..."
    else
        echo "Đang cập nhật Zalo..."
    fi

    # Clean up and clone repository
    if [[ -d "$CLONE_TEMP_DIR" ]]; then
        rm -rf "$CLONE_TEMP_DIR"
    fi

    if ! mkdir -p "$CLONE_TEMP_DIR"; then
        echo "Error: Failed to create temporary directory $CLONE_TEMP_DIR" >&2
        exit 1
    fi

    if ! git clone https://github.com/cobaohieu/zalo-linux-unofficial "$CLONE_TEMP_DIR"; then
        echo "Error: Failed to clone repository" >&2
        exit 1
    fi

    cd "$CLONE_TEMP_DIR" || {
        echo "Error: Failed to enter directory $CLONE_TEMP_DIR" >&2
        exit 1
    }

    mkdir -p "$HOME/.local/share/" || {
        echo "Error: Failed to create local share directory" >&2
        exit 1
    }

    if [[ "$LANGUAGE" == "EN" ]]; then
        echo "Updating Electron v22.3.27..."
    else
        echo "Đang cập nhật Electron v22.3.27..."
    fi

    rm -rf ~/.local/share/Zalo
    rm -f "$HOME/.local/share/applications/Zalo.desktop"
    rm -f "$HOME/Desktop/Zalo.desktop"

    # Create and use the new temp directory
    if ! mkdir -p "$UPDATER_TEMP_DIR"; then
        echo "Error: Failed to create updater directory $UPDATER_TEMP_DIR" >&2
        exit 1
    fi

    # Copy necessary files
    for dir in languages shortcut Zalo; do
        if [[ ! -d "./$dir" ]]; then
            echo "Error: Required directory $dir not found in repository" >&2
            exit 1
        fi
        cp -r "./$dir" "$UPDATER_TEMP_DIR/" || {
            echo "Error: Failed to copy $dir" >&2
            exit 1
        }
    done

    for file in version.txt update.sh; do
        if [[ ! -f "./$file" ]]; then
            echo "Error: Required file $file not found in repository" >&2
            exit 1
        fi
        cp -r "./$file" "$UPDATER_TEMP_DIR/" || {
            echo "Error: Failed to copy $file" >&2
            exit 1
        }
    done

    # Download and extract Electron
    if ! wget -q https://github.com/electron/electron/releases/download/v22.3.27/electron-v22.3.27-linux-x64.zip -P "$UPDATER_TEMP_DIR/Zalo"; then
        echo "Error: Failed to download Electron" >&2
        exit 1
    fi

    if ! unzip -q "$UPDATER_TEMP_DIR/Zalo/electron-v22.3.27-linux-x64.zip" -d "$UPDATER_TEMP_DIR/Zalo/electron-v22.3.27-linux-x64"; then
        echo "Error: Failed to extract Electron" >&2
        exit 1
    fi
    rm -f "$UPDATER_TEMP_DIR/Zalo/electron-v22.3.27-linux-x64.zip"

    if [[ "$LANGUAGE" == "EN" ]]; then
        echo "Updated Electron v22.3.27!"
    else
        echo "Đã cập nhật Electron v22.3.27!"
    fi

    # Copy language-specific main.py
    lang_dir="$UPDATER_TEMP_DIR/languages"
    if [[ "$LANGUAGE" == "EN" ]]; then
        cp "$lang_dir/en/main.py" "$UPDATER_TEMP_DIR/Zalo/" || {
            echo "Error: Failed to copy English main.py" >&2
            exit 1
        }
    else
        cp "$lang_dir/vn/main.py" "$UPDATER_TEMP_DIR/Zalo/" || {
            echo "Error: Failed to copy Vietnamese main.py" >&2
            exit 1
        }
    fi

    # Install Zalo files
    cp -r "$UPDATER_TEMP_DIR/Zalo" "$HOME/.local/share/" || {
        echo "Error: Failed to copy Zalo files" >&2
        exit 1
    }

    # Process and install desktop files
    sed -i "s|\$HOME|$HOME|g" "$UPDATER_TEMP_DIR/shortcut/Zalo.desktop"

    if [[ "$LANGUAGE" == "EN" ]]; then
        sed -i "s|\$HOME|$HOME|g" "$UPDATER_TEMP_DIR/shortcut/Update Zalo.desktop"
        cp -f "$UPDATER_TEMP_DIR/shortcut/Update Zalo.desktop" "$HOME/.local/share/applications/" || {
            echo "Error: Failed to copy Update Zalo.desktop" >&2
            exit 1
        }
    else
        sed -i "s|\$HOME|$HOME|g" "$UPDATER_TEMP_DIR/shortcut/Cập Nhật Zalo.desktop"
        cp -f "$UPDATER_TEMP_DIR/shortcut/Cập Nhật Zalo.desktop" "$HOME/.local/share/applications/" || {
            echo "Error: Failed to copy Cập Nhật Zalo.desktop" >&2
            exit 1
        }
    fi

    cp -f "$UPDATER_TEMP_DIR/shortcut/Zalo.desktop" "$HOME/.local/share/applications/" || {
        echo "Error: Failed to copy Zalo.desktop to applications" >&2
        exit 1
    }

    cp -f "$UPDATER_TEMP_DIR/shortcut/Zalo.desktop" "$HOME/Desktop/" || {
        echo "Error: Failed to copy Zalo.desktop to Desktop" >&2
        exit 1
    }

    cp -f "$UPDATER_TEMP_DIR/update.sh" "$HOME/.local/share/Zalo/" || {
        echo "Error: Failed to copy update.sh" >&2
        exit 1
    }

    cp -f "$UPDATER_TEMP_DIR/version.txt" "$HOME/.local/share/Zalo/version.txt" || {
        echo "Error: Failed to copy version.txt" >&2
        exit 1
    }

    # Clean up temp directories
    rm -rf "$UPDATER_TEMP_DIR"
    rm -rf "$CLONE_TEMP_DIR"
    
    echo "$LANGUAGE" > "$HOME/.local/share/Zalo/lang.txt" || {
        echo "Error: Failed to write language file" >&2
        exit 1
    }
    
    if [[ "$LANGUAGE" == "EN" ]]; then
        echo "Successfully updated Zalo!"
    else
        echo "Đã cập nhật Zalo thành công!"
    fi
    exit 0
}

check_version
update_zalo