#!/bin/bash
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# Define temporary directory variable
current_dir=$(pwd)
echo "Current directory is: $current_dir"

INSTALLER_TEMP_DIR="/tmp/zalo-installer-$(date +%s)"

choose_language() {
    echo "Select language / Chọn ngôn ngữ:"
    echo "1) English"
    echo "2) Tiếng Việt"
    read -p "Enter your choice / Nhập lựa chọn của bạn (1 or 2): " lang_choice

    case $lang_choice in
        1)
            LANGUAGE="EN"
            ;;
        2)
            LANGUAGE="VI"
            ;;
        *)
            echo "Invalid choice. Please select 1 or 2."
            echo "Lựa chọn không hợp lệ. Vui lòng chọn 1 hoặc 2."
            choose_language
            ;;
    esac
}
choose_language

install_zalo() {
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Installing Zalo..."
    else
        echo "Đang cài đặt Zalo..."
    fi

    # Define the folder path
    folder_path="$HOME/.local/share/"

    # Check if the folder already exists
    if [ -d "$folder_path" ]; then
        echo "Folder already exists: $folder_path"
        rm -rf "$HOME/.local/share/Zalo"
    else
        # Create the folder (and parent directories if needed)
        mkdir -p "$folder_path"
        echo "Folder created: $folder_path"
    fi
    
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Installing Electron v22.3.27..."
    else
        echo "Đang cài đặt Electron v22.3.27..."
    fi

    # Create and use the new temp directory
    cp -r "./src" $INSTALLER_TEMP_DIR

    wget https://github.com/electron/electron/releases/download/v22.3.27/electron-v22.3.27-linux-x64.zip -P "$INSTALLER_TEMP_DIR/Zalo"
    unzip "$INSTALLER_TEMP_DIR/Zalo/electron-v22.3.27-linux-x64.zip" -d "$INSTALLER_TEMP_DIR/Zalo/electron-v22.3.27-linux-x64"
    rm "$INSTALLER_TEMP_DIR/Zalo/electron-v22.3.27-linux-x64.zip"

    cd $INSTALLER_TEMP_DIR
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Installed Electron v22.3.27!"
    else
        echo "Đã cài đặt thành công Electron v22.3.27!"
    fi

    if [ "$LANGUAGE" == "EN" ]; then
        cp "$INSTALLER_TEMP_DIR/languages/en/main.py" "$INSTALLER_TEMP_DIR/Zalo"
    else
        cp "$INSTALLER_TEMP_DIR/languages/vn/main.py" "$INSTALLER_TEMP_DIR/Zalo"
    fi

    cp -r "$INSTALLER_TEMP_DIR/Zalo" "$HOME/.local/share/"
    sed -i "s|\$HOME|$HOME|g" "$INSTALLER_TEMP_DIR/shortcuts/Zalo.desktop"

    if [ "$LANGUAGE" == "EN" ]; then
        sed -i "s|\$HOME|$HOME|g" "$INSTALLER_TEMP_DIR/shortcuts/Update Zalo.desktop"
        cp -r "$INSTALLER_TEMP_DIR/shortcuts/Update Zalo.desktop" "$HOME/.local/share/applications"
    else
        sed -i "s|\$HOME|$HOME|g" "$INSTALLER_TEMP_DIR/shortcuts/Cập Nhật Zalo.desktop"
        cp -r "$INSTALLER_TEMP_DIR/shortcuts/Cập Nhật Zalo.desktop" "$HOME/.local/share/applications"
    fi

    cp -r "$INSTALLER_TEMP_DIR/shortcuts/Zalo.desktop" "$HOME/.local/share/applications"
    cp -r "$INSTALLER_TEMP_DIR/shortcuts/Zalo.desktop" "$HOME/Desktop"


    cp -r "$INSTALLER_TEMP_DIR/update.sh" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/app-update.yml" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/assets" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/bootstrap.js" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/icon.icns" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/libs" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/main-dist" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/native" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/package.json" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/pc-dist" "$HOME/.local/share/Zalo"
    cp -r "$INSTALLER_TEMP_DIR/start.sh" "$HOME/.local/share/Zalo"
    cp "$INSTALLER_TEMP_DIR/version.txt" "$HOME/.local/share/Zalo/version.txt"
    
    # Clean up temp directory
    rm -rf "$INSTALLER_TEMP_DIR"
    
    echo "$LANGUAGE" > "$HOME/.local/share/Zalo/lang.txt"
    
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Successful installed Zalo!"
    else
        echo "Đã cài đặt thành công Zalo!"
    fi
    sleep 1
    exit 0
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_dependencies() {
    if [ "$LANGUAGE" == "EN" ]; then
        echo 'Installing dependencies...'
    else
        echo 'Đang cài đặt các gói module cần thiết...'
    fi
    if command_exists pip ; then
        pip install -U pystray pillow
    else
        pip3 install -U pystray pillow
    fi
    if [ "$LANGUAGE" == "EN" ]; then
        echo 'Installed dependencies!'
    else
        echo 'Đã cài đặt các gói module cần thiết!'
    fi
}

if ! command_exists python && ! command_exists python3; then
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Python is not installed. Do you want to install now? (y/n):"
    else
        echo "Python chưa được cài đặt. Bạn có muốn cài đặt bây giờ không? (y/n):"
    fi
    read -r response

    if [ "$response" = "y" ]; then
        if [ "$LANGUAGE" == "EN" ]; then
            echo "Proceeding with the installation..."
        else
            echo "Đang tiếp tục cài đặt..."
        fi
    else
        if [ "$LANGUAGE" == "EN" ]; then
            echo "Installation aborted."
        else
            echo "Đã hủy cài đặt."
        fi
        exit 1
    fi
else
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Python is installed."
    else
        echo "Python đã được cài đặt."
    fi
    install_dependencies
fi

install_python_debian_ubuntu() {
    if [ "$LANGUAGE" == "EN" ]; then
        echo '*** Installing Python on Debian/Ubuntu...'
    else
        echo '*** Đang cài đặt Python trên Debian/Ubuntu...'
    fi
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip git
}

install_python_fedora() {
    if [ "$LANGUAGE" == "EN" ]; then
        echo '*** Installing Python on Fedora...'
    else
        echo '*** Đang cài đặt Python trên Fedora...'
    fi
    sudo dnf install -y python3 python3-pip git
}

install_python_centos() {
    if [ "$LANGUAGE" == "EN" ]; then
        echo '*** Installing Python on CentOS/RHEL/RedHat-based...'
    else
        echo '*** Đang cài đặt Python trên CentOS/RHEL/RedHat-based...'
    fi
    sudo yum install -y python3 python3-pip git
}

if [ ! -f /etc/os-release ]; then
    if [ "$LANGUAGE" == "EN" ]; then
        echo '*** Cannot detect Linux distribution! Aborting.'
    else
        echo '*** Không thể phát hiện bản phân phối Linux! Hủy bỏ.'
    fi
    exit 1
fi

source /etc/os-release

if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
    install_python_debian_ubuntu
elif [ "$ID" == "fedora" ]; then
    install_python_fedora
elif [ "$ID" == "centos" ] || [ "$ID" == "rhel" ] || [ "$ID" == "rocky" ] || [ "$ID" == "almalinux" ] || [ "$ID" == "nobara" ]; then
    install_python_centos
else
    if [ "$LANGUAGE" == "EN" ]; then
        echo "Unsupported distribution $ID"
    else
        echo "Bản phân phối không được hỗ trợ $ID"
    fi
    exit 1
fi

if [ "$LANGUAGE" == "EN" ]; then
    echo
    echo '*** Python installation complete!'
else
    echo
    echo '*** Cài đặt Python hoàn tất!'
fi

install_dependencies
install_zalo