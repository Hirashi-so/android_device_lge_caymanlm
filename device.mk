#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/lge/caymanlm
DEVICE_NAME := caymanlm

# Inherit from the common device configuration
$(call inherit-product, device/lge/sm7250-common/sm7250-common.mk)

# Audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_platform_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info.xml \
    $(LOCAL_PATH)/audio/audio_platform_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_info_intcodec.xml \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/audio/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.3-service.lge \
    sensors.lge

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sensors/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

$(call soong_config_set,LGE_FINGERPRINT_HAL,TARGET_HAS_EGISTEC_UDFPS,true)

# Include custom open-source dummy libfpsph to unblock fingerprint HAL
PRODUCT_PACKAGES += \
    libfpsph

# Add Fingerprint Algorithm Libraries to Product Packages
PRODUCT_PACKAGES += \
    libswregistrationalgo \
    com.qti.node.swregistration

# Overlays
PRODUCT_PACKAGES += \
    ApertureOverlayCaymanlm \
    FrameworksResOverlayCaymanlm \
    SettingsOverlayCaymanlm \
    SystemUIOverlayCaymanlm

# Soong namespace
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit from vendor makefiles
$(call inherit-product, vendor/lge/caymanlm/caymanlm-vendor.mk)

# Add ServiceManager for recovery AIDL HALs
PRODUCT_PACKAGES += \
    servicemanager.recovery

# Boot animation resolution
TARGET_SCREEN_HEIGHT := 2460
TARGET_SCREEN_WIDTH := 1080

# Set Display density to 414 to achieve exactly 417dp smallest width
PRODUCT_PRODUCT_PROPERTIES += \
    ro.sf.lcd_density=414

# Partitions configuration
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_VIRTUAL_AB_COMPRESSION := false

# A/B OTA Updater configuration
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# Copy recovery VINTF manifest to ramdisk
PRODUCT_COPY_FILES += \
    device/lge/caymanlm/recovery_manifest.xml:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/vintf/manifest.xml

# Allow Soong to access the QTI Boot HAL directory
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/bootctrl

# Add ServiceManager and QTI Boot HAL for recovery AIDL HALs
PRODUCT_PACKAGES += \
    servicemanager.recovery \
    android.hardware.boot-service.qti.recovery

# Override default system properties for early ADB debugging
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.adb.secure=0 \
    persist.sys.usb.config=adb

# Enable modern eBPF pipeline by declaring 5.10-equivalent support
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bpf.kver_override=5.10.239

# Include native LGE AIDL Lights HAL service for custom panel compatibility
PRODUCT_PACKAGES += \
    android.hardware.light-service.lge

# Copy standard Qualcomm display QDCM and color configurations to prevent libdpps.so crash
PRODUCT_COPY_FILES += \
    hardware/qcom-caf/sm8350/display/config/qdcm_calib_data_default.xml:$(TARGET_COPY_OUT_VENDOR)/etc/display/qdcm_calib_data_default.xml \
    hardware/qcom-caf/sm8350/display/config/snapdragon_color_libs_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/display/snapdragon_color_libs_config.xml \
    hardware/qcom-caf/sm8350/display/config/smomo_setting.xml:$(TARGET_COPY_OUT_VENDOR)/etc/display/smomo_setting.xml

# Copy LG Velvet specific display calibration and SurfaceFlinger offset XMLs
# This resolves the libdpps.so null pointer dereference on the SW43103 panel
PRODUCT_COPY_FILES += \
    device/lge/caymanlm/configs/display/qdcm_calib_data_SW43103_cmd_mode_dsc_dsi_panel.xml:$(TARGET_COPY_OUT_VENDOR)/etc/qdcm_calib_data_SW43103_cmd_mode_dsc_dsi_panel.xml \
    device/lge/caymanlm/configs/display/advanced_sf_offsets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/display/advanced_sf_offsets.xml

# Force include Google Mobile Services (GApps)
WITH_GAPPS := true
WITH_GMS := true
TARGET_INCLUDE_GAPPS := true
$(call inherit-product-if-exists, vendor/google/gms/config.mk)

# Ensure LiveDisplay service is forcefully included in the build
PRODUCT_PACKAGES += \
    vendor.lineage.livedisplay-service.lge

# Inherit Sony Dolby Atmos hardware configurations and vendor blobs
$(call inherit-product-if-exists, hardware/dolby/dolby.mk)
