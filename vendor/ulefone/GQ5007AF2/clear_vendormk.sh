#!/bin/bash

# Shellskript zum Bereinigen einer Vendor-Makefile (*.mk)
# durch Entfernen von PRODUCT_COPY_FILES-Einträgen für Dateien,
# die typischerweise vom AOSP/LineageOS Framework bereitgestellt werden
# und "overriding commands"-Fehler verursachen können.

# Funktion zur Anzeige der Hilfe
usage() {
    echo "Usage: $0 <path/to/vendor-makefile.mk>"
    echo "Removes likely conflicting PRODUCT_COPY_FILES entries directly"
    echo "from the specified makefile based on common patterns."
    echo "BACKUP YOUR MAKEFILE FIRST!"
    exit 1
}

# --- Hauptlogik ---

# Prüfen, ob genau ein Parameter übergeben wurde
if [ "$#" -ne 1 ]; then
    usage
fi

VENDOR_MAKEFILE="$1"

# Prüfen, ob die Makefile existiert und schreibbar ist
if [ ! -f "$VENDOR_MAKEFILE" ] || [ ! -w "$VENDOR_MAKEFILE" ]; then
    echo "Error: Vendor makefile '$VENDOR_MAKEFILE' not found or not writable."
    exit 1
fi

echo "Processing Makefile: '$VENDOR_MAKEFILE'"
echo "This will REMOVE lines matching common conflicting patterns."
read -p "ARE YOU SURE? Have you backed up the file? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo "---"
echo "Removing entries copied to standard permission directories..."
# Using | as separator for sed to avoid escaping /
sed -i '\|:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/|d' "$VENDOR_MAKEFILE"
sed -i '\|:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/platform\.xml|d' "$VENDOR_MAKEFILE" # platform.xml is often system

echo "Removing entries copied to standard sysconfig directories..."
sed -i '\|:$(TARGET_COPY_OUT_VENDOR)/etc/sysconfig/|d' "$VENDOR_MAKEFILE"
sed -i '\|:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/|d' "$VENDOR_MAKEFILE" # Check system too

echo "Removing entries for standard HAL VINTF manifests..."
# Match android.hardware.*.xml but try not to match manifest_*.xml
sed -i '\|:$(TARGET_COPY_OUT_VENDOR)/etc/vintf/manifest/android\.hardware\..*\.xml|d' "$VENDOR_MAKEFILE"
# Also remove the explicitly named DRM/Health ones copied earlier if they exist by path pattern
sed -i '\|manifest_android\.hardware\.drm.*\.xml|d' "$VENDOR_MAKEFILE"
sed -i '\|android\.hardware\.health.*\.xml|d' "$VENDOR_MAKEFILE"
# Remove base manifest if copied
sed -i '\|manifest\.xml:$(TARGET_COPY_OUT_VENDOR)/etc/vintf/manifest\.xml|d' "$VENDOR_MAKEFILE"


echo "Removing entries for specific standard config files..."
sed -i '\|/apns-conf\.xml:|d' "$VENDOR_MAKEFILE"
sed -i '\|/ecc_list\.xml:|d' "$VENDOR_MAKEFILE"

echo "Removing entries for specific standard service RC files (Health, DRM)..."
# Match the specific names derived from previous analysis
sed -i '\|/android\.hardware\.health.*\.rc:|d' "$VENDOR_MAKEFILE"
sed -i '\|/android\.hardware\.drm.*\.rc:|d' "$VENDOR_MAKEFILE"


# Optional: Remove specific known problematic prebuilts if Android.bp is preferred
# This section is commented out as it's better handled by the user ensuring
# the Android.bp is correct and *then* running this script for XML/RC cleanup.
# echo "Removing PRODUCT_COPY_FILES entries for common prebuilts handled by Soong (Example: libtrusty)..."
# sed -i '\|/libtrusty\.so:|d' "$VENDOR_MAKEFILE"
# sed -i '\|/libkeymaster.*\.so:|d' "$VENDOR_MAKEFILE"


echo "---"
echo "Finished processing '$VENDOR_MAKEFILE'."
echo "Please review the file for correctness."

exit 0
