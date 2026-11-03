#!/bin/bash
set -e

echo "=== Installing Flutter SDK ==="
if [ ! -d "flutter-sdk" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
fi

export PATH="$PATH:$(pwd)/flutter-sdk/bin"

echo "=== Checking Flutter version ==="
flutter --version

echo "=== Resolving dependencies ==="
flutter pub get

echo "=== Building Flutter Web release ==="
flutter build web --release

echo "=== Build finished successfully ==="
