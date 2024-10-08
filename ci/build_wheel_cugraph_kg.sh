#!/bin/bash
# Copyright (c) 2023-2024, NVIDIA CORPORATION.

set -euo pipefail

RAPIDS_PY_CUDA_SUFFIX="$(rapids-wheel-ctk-name-gen ${RAPIDS_CUDA_VERSION})"

# Download the pylibcugraph wheel built in the previous step and make it
# available for pip to find.
#
# ensure 'cugraph' wheel builds always use the 'pylibcugraph' just built in the same CI run
#
# using env variable PIP_CONSTRAINT is necessary to ensure the constraints
# are used when creating the isolated build environment
RAPIDS_PY_WHEEL_NAME=pylibcugraph_${RAPIDS_PY_CUDA_SUFFIX} rapids-download-wheels-from-s3 ./local-pylibcugraph
echo "pylibcugraph-${RAPIDS_PY_CUDA_SUFFIX} @ file://$(echo ${PWD}/local-pylibcugraph/pylibcugraph_*.whl)" > ./constraints.txt
export PIP_CONSTRAINT="${PWD}/constraints.txt"

export SKBUILD_CMAKE_ARGS="-DDETECT_CONDA_ENV=OFF;-DFIND_CUGRAPH_CPP=OFF;-DCPM_cugraph-ops_SOURCE=${GITHUB_WORKSPACE}/cugraph-ops/"

./ci/build_wheel.sh cugraph python/cugraph
