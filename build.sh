#!/bin/bash
export PATH="$HOME/zyc-clang/bin:$PATH"
set -eo pipefail
source ./settings.sh

MAIN=$PWD
KERNEL=$PWD
OUT=out

build() {
    START=$(date +%s)
    BRANCH=$(git branch --show-current)
    MAGICTIME="${MAIN}/MagicTime-${DEVICE}"

    mkdir -p "${MAGICTIME}"
    if [ ! -d "${MAGICTIME}/AnyKernel3" ];then
        git clone https://github.com/osm0sis/AnyKernel3 "${MAGICTIME}/AnyKernel3"
    fi
    
    rm -rf "${OUT}"
    
    make ARCH=arm64 O="${OUT}" "${DEVICE}_defconfig"
    
    make ARCH=arm64 LLVM=1 -j$(nproc) \
    O="${OUT}" \
    CC="ccache clang" \
    HOSTCC="ccache gcc"

    cp "${OUT}/arch/arm64/boot/Image" "${MAGICTIME}/Image"
    find "${OUT}/arch/arm64/boot/dts" -name '*.dtb' -exec cat {} + > "${MAGICTIME}/dtb"

    END=$(date +%s)
    ELAPSED=$((END - START))
    CHANGELOG="../changelog.txt"

    echo "Общее время выполнения: $ELAPSED секунд"
    cd "${MAGICTIME}"
    7z a -mx9 "MagicTime-${DEVICE}.zip" * -x!*.zip
    cd "${KERNEL}"
}

# ========== 编译配置列表 ==========
CONFIGS=(
    "thyme:magictime-new:ksu:Mi10S MIUI KSU"
    "thyme:magictime-new:no_ksu:Mi10S MIUI nonKSU"
)

# 按ONLY过滤机型
if [ -n "$ONLY" ]; then
    TARGET_CONFIGS=()
    for cfg in "${CONFIGS[@]}"; do
        if [[ "$cfg" == *"$ONLY"* ]]; then
            TARGET_CONFIGS+=("$cfg")
        fi
    done
    CONFIGS=("${TARGET_CONFIGS[@]}")
fi

# 循环编译
for cfg in "${CONFIGS[@]}"; do
    IFS=':' read -r DEVICE BRANCH MOD_KSU DESC <<< "$cfg"
    echo "===== 开始编译：$DESC ====="

    git checkout "$BRANCH"
    git reset --hard "origin/$BRANCH"

    # 如果是no_ksu，打补丁
    if [ "$MOD_KSU" = "no_ksu" ] && [ -n "$SHAK" ]; then
        git cherry-pick "$SHAK" || { git cherry-pick --abort; exit 1; }
    fi

    build
done
