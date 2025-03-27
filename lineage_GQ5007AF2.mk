#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from GQ5007AF2 device
$(call inherit-product, device/ulefone/GQ5007AF2/device.mk)

PRODUCT_DEVICE := GQ5007AF2
PRODUCT_NAME := lineage_GQ5007AF2
PRODUCT_BRAND := Ulefone
PRODUCT_MODEL := Armor 25T Pro
PRODUCT_MANUFACTURER := ulefone

PRODUCT_GMS_CLIENTID_BASE := android-gotron

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="sys_mssi_64_ww_armv82-user 14 UP1A.231005.007 p1rck6989v164P11 release-keys"

BUILD_FINGERPRINT := Ulefone/GQ5007AF2_EEA/GQ5007AF2:14/UP1A.231005.007/1726391794:user/release-keys
