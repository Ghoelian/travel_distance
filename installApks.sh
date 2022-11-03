#!/bin/sh

# TODO: Ask where apks is located, and what device id to install to
adb -s LB07219S30183 install ./build/app/outputs/apk/release/app-arm64-v8a-release.apk
