#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/lge/caymanlm

DEVICE_NAME := caymanlm

# Inherit from the common device configuration.
$(call inherit-product, device/lge/sm7250-common/sm7250-common.mk)

# Overlays
PRODUCT_PACKAGES += \
    ApertureOverlayCaymanlm

# Soong namespace
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit from vendor makefiles.
$(call inherit-product, vendor/lge/caymanlm/caymanlm-vendor.mk)
