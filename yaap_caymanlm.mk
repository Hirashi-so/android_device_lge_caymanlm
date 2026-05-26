#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Indicate the first API level the device has been commercially launched on
PRODUCT_SHIPPING_API_LEVEL := 29

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/yaap/config/common_full_phone.mk)

# Inherit from device makefiles
$(call inherit-product, $(LOCAL_PATH)/device.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := yaap_caymanlm
PRODUCT_DEVICE := caymanlm
PRODUCT_MANUFACTURER := LGE
PRODUCT_BRAND := LGE
PRODUCT_MODEL := LM-G900N

PRODUCT_GMS_CLIENTID_BASE := android-lge

#PRODUCT_BUILD_PROP_OVERRIDES += \
#    DeviceProduct=caymanlm \
#    BuildDesc="caymanlm-user 13 TKQ1.220829.002 231811419f557 release-keys" \
#    BuildFingerprint="lge/caymanlm/caymanlm:13/TKQ1.220829.002/231811419f557:user/release-keys"
