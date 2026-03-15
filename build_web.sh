#!/bin/bash
set -e  # Exit on error

echo "Installing Flutter SDK..."

# Download and extract Flutter (use stable channel)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor --android-licenses --accept-all || true
flutter doctor

echo "Flutter version:"
flutter --version

echo "Installing dependencies..."
flutter pub get

echo "Building web release..."
flutter build web --release

echo "Build completed!"