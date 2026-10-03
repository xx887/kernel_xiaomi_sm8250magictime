#!/bin/bash
# MagicTime Kernel Build Settings
export VERSION="MagicTime"
export PREFIX=""
export BUILD="GitHub-Action"
export LEVEL=1
export DROIDSPACES_VERSION="1.0"
export DROIDSPACES_PATCH_BASE="patches/droidspaces"
export DROIDSPACES_CGROUP_SHA256=""

# 新增编译必须变量
export DEVICE="thyme"
export TYPE="test"
export ONLY="thyme"
export SHAK=""
export LAST=$(git log -1 --format=%H)
export TGTOKEN=""
