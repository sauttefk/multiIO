#!/bin/bash

# Build script for all device variants
# Creates multiIO.device0xYY.hex files in hexfiles/ directory

set -e  # Exit on error

# Extract device IDs dynamically from src/parameter.asm
echo "Extracting device IDs from src/parameter.asm..."
if [ ! -f "src/parameter.asm" ]; then
    echo "Error: src/parameter.asm not found!"
    exit 1
fi

DEVICES=($(grep -o 'if device == 0x[0-9a-fA-F]*' src/parameter.asm | sed 's/if device == 0x//' | sort -u))

if [ ${#DEVICES[@]} -eq 0 ]; then
    echo "Error: No device IDs found in src/parameter.asm!"
    exit 1
fi

echo "Found ${#DEVICES[@]} device IDs: ${DEVICES[@]}"

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir -p build
fi

echo "Building multiIO firmware for all device variants..."
echo "=================================================="

# Clean any existing files first
make clean

# Re-create build directory after clean
mkdir -p build

for device in "${DEVICES[@]}"; do
    echo -n "Building device 0x${device}... "
    
    # Build the firmware with device ID passed to gpasm
    if gpasm -p 16F946 -w 2 -D device=0x${device} -I inc -I src -o build/multiIO src/main.asm > /dev/null 2>&1; then
        # Copy hex file to build directory with device-specific name
        cp build/multiIO.hex "build/multiIO.device0x${device}.hex"
        echo "✓"
    else
        echo "✗ FAILED"
    fi
    
    # Clean up for next build
    rm -f build/multiIO.hex build/multiIO.cod build/multiIO.lst
done

echo "=================================================="
echo "Build complete! Generated files:"
ls -la build/multiIO.device0x*.hex