#!/bin/bash
/**
 * @author Daniel Thornburg
 * @date: 2024-12-01
 * @file: setup.sh
 * @desc: Installation script for Barkeep project
 */

set -e

echo "Updating package lists..."
sudo apt-get update -y && sudo apt-get upgrade -y;

echo "Installing SQLite3 and dependencies..."
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa \
 sqlite3 libsqlite3-dev \
 clang cmake \
 ninja-build pkg-config \
 libgtk-3-dev liblzma-dev \
 libstdc++-12-dev



echo "Checking if Flutter is already installed..."
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter..."
    mkdir -p ~/development
    cd ~/development
    curl -LO https://storage.goolgeapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.1-stable.tar.xz
    tar -xf ~/Downloads/flutter_linux_3.29.1-stable.tar.xz -C ~/development/

    echo "export PATH=\$HOME/development/flutter/bin:\$PATH" >> ~/.bashrc
    export Path=$HOME/development/flutter/bin:$PATH
    echo "Flutter installed successfully!"
else
    echo "Flutter is already installed. Skipping Installation."
fi

echo "Verifying Flutter installation..."
flutter doctor

echo "Installing Flutter dependencies..."
flutter pub get

echo "Setup complete. Restart your terminal or run 'source ~/.bashrc' to apply changes."