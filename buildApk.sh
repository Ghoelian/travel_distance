#!/bin/sh

flutter build apk --obfuscate --split-debug-info=debug-symbols/ --split-per-abi
