#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)
from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
)

import extract_utils.tools

namespace_imports = [
    'vendor/lge/sm7250-common',
    'vendor/qcom/opensource/display',
]


blob_fixups: blob_fixups_user_type = {
    'vendor/lib64/liblgdnnsnpe.so': blob_fixup()
        .replace_needed('libstdc++.so', 'libstdc++_vendor.so'),
}  # fmt: skip


module = ExtractUtilsModule(
    'caymanlm',
    'lge',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(
        module, 'sm7250-common', module.vendor
    )
    utils.run()
