#!/bin/bash
flameshot gui -s -p "/home/lh/Pictures/tmp/screenshot.png"
RUST=$(tesseract "/home/lh/Pictures/tmp/screenshot.png" stdout --oem 1 --psm 6 -l eng)
echo -n "$RUST" | wl-copy
# goldendict "$RUST" && goldendict "$RUST"
rm "/home/lh/Pictures/tmp/screenshot.png"
