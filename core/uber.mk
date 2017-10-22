# Copyright (C) 2014-2017 UBER
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

####################################################
####################################################
## * * * PureFusionOS [Updated: 09/28/2017] * * * ##
####################################################
####################################################

# Set Bluetooth Modules
BLUETOOTH := libbluetooth_jni bluetooth.mapsapi bluetooth.default bluetooth.mapsapi libbt-brcm_stack audio.a2dp.default libbt-brcm_gki libbt-utils libbt-qcom_sbc_decoder \
                libbt-brcm_bta libbt-brcm_stack libbt-vendor libbtprofile libbtdevice libbtcore bdt bdtest libbt-hci libosi ositests libbluetooth_jni net_test_osi net_test_device \
                net_test_btcore net_bdtool net_hci bdAddrLoader

# PureFusionOS module disable
DISABLE_FUSION_arm :=
DISABLE_FUSION_arm64 := libm libdng_sdk libdng% libjni_filtershow_filters busybox libfdlibm libhistory% sensorservice libwfds libsensorservice  \
                        libv8base libhevcdec libjni_eglfence% libjni_jpegstream% libjni_gallery_filters% libLLVMAArch64CodeGen libLLVMAnalysis \
                        librsjni libblasV8 libF77blasV8 libF77blas libRSSupport% libclcore libLLVMCodeGen libbnnmlowpV8 libLLVMARMCodeGen libLLVM% \
                        libplatformprotos

# Set DISABLE_FUSION based on arch
DISABLE_FUSION := \
  $(DISABLE_FUSION_$(TARGET_ARCH)) \
  $(LOCAL_DISABLE_FUSION)

# Enable PureFusionOS on GCC modules.
#   Split up by arch.
ENABLE_FUSION_arm :=
ENABLE_FUSION_arm64 :=

# Set ENABLE_DTC based on arch
ENABLE_FUSION := \
  $(ENABLE_FUSION_$(TARGET_ARCH)) \
  $(LOCAL_ENABLE_FUSION)

# Enable PureFusionOS on current module if requested.
ifeq (1,$(words $(filter $(ENABLE_FUSION),$(LOCAL_MODULE))))
  my_cc := $(CLANG)
  my_cxx := $(CLANG_CXX)
  my_clang := true
endif

# Disable PureFusionOS on current module.
ifeq ($(my_clang),true)
  ifeq (1,$(words $(filter $(DISABLE_FUSION),$(LOCAL_MODULE))))
    my_cc := $(AOSP_CLANG)
    my_cxx := $(AOSP_CLANG_CXX)
    CLANG_CONFIG_arm_EXTRA_CFLAGS += -mcpu=cortex-a15
  else
    CLANG_CONFIG_arm_EXTRA_CFLAGS += -mcpu=cortex-a15
  endif
endif

###################
# Strict Aliasing #
###################
LOCAL_DISABLE_STRICT := \
        libc% \
	libpdfiumfpdfapi \
	mdnsd

STRICT_ALIASING_FLAGS := \
        -fstrict-aliasing -O3 \
	-Werror=strict-aliasing

STRICT_GCC_LEVEL := \
	-Wstrict-aliasing=3

STRICT_CLANG_LEVEL := \
	-Wstrict-aliasing=2

############
# GRAPHITE #
############

LOCAL_DISABLE_GRAPHITE := \
	libfec_rs \
	libfec_rs_host \

GRAPHITE_FLAGS := \
	-fgraphite \
	-fgraphite-identity \
	-floop-flatten \
	-floop-parallelize-all \
	-ftree-loop-linear \
	-floop-interchange \
	-floop-strip-mine \
	-floop-block

# We just don't want these flags
my_cflags := $(filter-out -Wall -Werror -g -Wextra -Weverything,$(my_cflags))
my_cppflags := $(filter-out -Wall -Werror -g -Wextra -Weverything,$(my_cppflags))
my_conlyflags := $(filter-out -Wall -Werror -g -Wextra -Weverything,$(my_conlyflags))

# Remove previous Optimization flags, we'll set O3 there
my_cflags := $(filter-out -O3 -O2 -Os -O1 -O0 -Og -Oz,$(my_cflags)) -O3 -g0 -DNDEBUG
my_conlyflags := $(filter-out -O3 -O2 -Os -O1 -O0 -Og -Oz,$(my_conlyflags)) -O3 -g0 -DNDEBUG
my_cppflags := $(filter-out -O3 -O2 -Os -O1 -O0 -Og -Oz,$(my_cppflags)) -O3 -g0 -DNDEBUG

# IPA
ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    my_cflags += -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
  else
    my_cflags += -analyze -analyzer-purge
  endif
endif

ifeq ($(STRICT_ALIASING),true)
  # Remove the no-strict-aliasing flags
  my_cflags := $(filter-out -fno-strict-aliasing,$(my_cflags))
  ifneq (1,$(words $(filter $(LOCAL_DISABLE_STRICT),$(LOCAL_MODULE))))
    ifneq ($(LOCAL_CLANG),false)
      my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GLANG_LEVEL)
    else
      my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GCC_LEVEL)
    endif
  endif
endif

ifeq ($(GRAPHITE_OPTS),true)
  # Enable graphite only on GCC
  ifneq ($(LOCAL_CLANG),false)
    my_cflags += $(GRAPHITE_FLAGS)
  endif
endif

#####################################
# UBER-ify PureFusion Optimizations #
#####################################

CUSTOM_FLAGS := -O3 -g0 -DNDEBUG
ifneq ($(LOCAL_SDCLANG_LTO),true)
  ifeq ($(my_clang),true)
    ifndef LOCAL_IS_HOST_MODULE
      CUSTOM_FLAGS += -fuse-ld=gold
    else
      CUSTOM_FLAGS += -fuse-ld=gold
    endif
  else
    CUSTOM_FLAGS += -fuse-ld=gold
  endif
else
  CUSTOM_FLAGS := -O3 -g0 -DNDEBUG
endif

O_FLAGS := -O3 -O2 -Os -O1 -O0 -Og -Oz

# Remove all flags we don't want use high level of optimization
my_cflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_cflags)) $(CUSTOM_FLAGS)
my_cppflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_cppflags)) $(CUSTOM_FLAGS)
my_conlyflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_conlyflags)) $(CUSTOM_FLAGS)

#######
# IPA #
#######

ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    my_cflags += -fipa-pta
  else
    my_cflags += -analyze -analyzer-purge
  endif
endif

##########
# OpenMP #
##########

LOCAL_DISABLE_OPENMP := \
	bluetooth.default \
	bluetooth.mapsapi \
	libbluetooth_jni \
	libbluetooth_jni_32 \
	libF77blas \
	libF77blasV8 \
	libjni_latinime \
	libyuv_static \
	mdnsd

ifndef LOCAL_IS_HOST_MODULE
  ifneq (1,$(words $(filter $(LOCAL_DISABLE_OPENMP),$(LOCAL_MODULE))))
    my_cflags += -lgomp -lgcc -fopenmp
    my_ldflags += -fopenmp
  endif
endif

#################
##  P O L L Y  ##
#################

# Polly flags for use with Clang
 POLLY := -O3 -mllvm -polly \
#  -mllvm -polly-parallel -lgomp \
  -mllvm -polly-ast-use-context \
  -mllvm -polly-vectorizer=stripmine \
  -mllvm -polly-opt-fusion=max \
  -mllvm -polly-opt-maximize-bands=yes \
  -mllvm -polly-run-dce \
  -mllvm -polly-position=after-loopopt \
  -mllvm -polly-run-inliner \
  -mllvm -polly-detect-keep-going \
  -mllvm -polly-opt-simplify-deps=no \
  -mllvm -polly-dependences-computeout=0 \
  -mllvm -polly-tiling=true \
  -mllvm -polly-prevect-width=16 \
  -mllvm -polly-vectorizer=polly \
  -mllvm -polly-rtc-max-arrays-per-group=40


#### UnUsed POLLY Options ####


# Disable modules that dont work with Polly. Split up by arch.
DISABLE_POLLY_arm := \
        libicuuc \
	libjni_imageutil \
	libjni_snapcammosaic \
	libjni_filtershow_filters \
	libandroid \
	libcrypto \
        libcrypto_static \
	libFraunhoferAAC \
	libjpeg_static \
	libLLVM% \
	libopus \
	libpdfium% \
	libskia_static \
	libstagefright%

DISABLE_POLLY_arm64 := \
        $(DISABLE_POLLY_arm) \
	  libjpeg_static \
	  libicuuc \
	  libwebp-decode \
	  libwebp-encode \
	  libpdfiumfxge \
	  libskia_static \
	  libaudioutils \
	  libpdfium% \
	  libLLVMSupport \
	  libsvoxpico \
	  libRS_internal \
	  libvpx \
	  libopus \
	  libv8 \
	  libsonic \
	  libaudioflinger \
	  libstagefright% \
	  libart \
	  libFFTEm \
	  libRSCpuRef \
	  libbnnmlowp \
	  libmedia_jni \
	  libFraunhoferAAC \
	  libavcdec \
	  libavcenc \
	  libmpeg2dec \
	  libwebrtc% \
	  libmusicbundle \
	  libreverb \
	  libscrypt_static \
	  libmpeg2dec \
	  libcrypto_static \
	  libcrypto \
	  libyuv% \
	  libjni_gallery_filters% \
	  libjni_gallery_filters_32 \
	  libLLVMSelectionDAG

# Set DISABLE_POLLY based on arch
DISABLE_POLLY := \
  $(DISABLE_POLLY_$(TARGET_ARCH)) \
        $(DISABLE_FUSION) \
  $(LOCAL_DISABLE_POLLY)

# Set POLLY based on DISABLE_POLLY
ifeq (1,$(words $(filter $(DISABLE_POLLY),$(LOCAL_MODULE))))
  POLLY := -O3
endif

# Set POLLY based on BLUETOOTH
ifeq (1,$(words $(filter $(BLUETOOTH),$(LOCAL_MODULE))))
  POLLY := -Os
endif

# Set POLLY based on DISABLE_POLLY
ifeq ($(my_32_64_bit_suffix),32)
  ifeq (1,$(words $(filter $(DISABLE_POLLY_arm64_32),$(LOCAL_MODULE))))
    POLLY := -O3
  endif
endif

ifeq ($(my_clang),true)
  ifndef LOCAL_IS_HOST_MODULE
    # Possible conflicting flags will be filtered out to reduce argument
    # size and to prevent issues with locally set optimizations.
    my_cflags := $(filter-out -Wall -Werror -g -O3 -O2 -Os -O1 -O0 -Og -Oz -Wextra -Weverything,$(my_cflags))
    # Enable -O3 and Polly if not blacklisted, otherwise use -Os.
    my_cflags += $(POLLY) -Qunused-arguments -Wno-unknown-warning-option -w -fuse-ld=gold
    my_ldflags += -fuse-ld=gold
  endif
endif

ifneq (1,$(words $(filter $(DISABLE_POLLY_O3),$(LOCAL_MODULE))))
  # Remove all other "O" flags to set O3
  my_cflags := $(filter-out -O3 -O2 -Os -O1 -O0 -Og -Oz,$(my_cflags))
  my_cflags += -O3
else
  my_cflags += -O2
endif

ifeq ($(my_sdclang), true)
  # Do not enable POLLY on libraries
  ifndef LOCAL_IS_HOST_MODULE
    # Enable POLLY if not blacklisted
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_POLLY),$(LOCAL_MODULE))))
      # Enable POLLY only on clang
      ifneq ($(LOCAL_CLANG),false)
        my_cflags += $(POLLY)
        my_cflags += -Qunused-arguments
      endif
    endif
  endif
endif

ifeq ($(LOCAL_CLANG),false)
  my_cflags += -Wno-unknown-warning
endif

#############
##  L T O  ##
#############

# Disable modules that don't work with Link Time Optimizations. Split up by arch.
DISABLE_LTO_arm := libLLVMScalarOpts libjni_latinime_common_static libjni_latinime adbd nit libnetd_client libblas
DISABLE_THINLTO_arm := libart libart-compiler libsigchain
DISABLE_LTO_arm64 :=
DISABLE_THINLTO_arm64 :=


# Set DISABLE_LTO and DISABLE_THINLTO based on arch
DISABLE_LTO := \
  $(DISABLE_LTO_$(TARGET_ARCH)) \
  $(DISABLE_DTC) \
  $(LOCAL_DISABLE_LTO)
DISABLE_THINLTO := \
  $(DISABLE_THINLTO_$(TARGET_ARCH)) \
  $(LOCAL_DISABLE_THINLTO)

# Enable LTO (currently disabled due to issues in linking, enable at your own risk)
ifeq ($(ENABLE_DTC_LTO),true)
  ifeq ($(my_clang),true)
    ifndef LOCAL_IS_HOST_MODULE
      ifneq ($(LOCAL_MODULE_CLASS),STATIC_LIBRARIES)
        ifneq (1,$(words $(filter $(DISABLE_LTO),$(LOCAL_MODULE))))
          ifneq (1,$(words $(filter $(DISABLE_THINLTO),$(LOCAL_MODULE))))
            my_cflags += -flto=thin -fuse-ld=gold
            my_ldflags += -flto=thin -fuse-ld=gold
          else
            my_cflags += -flto -fuse-ld=gold
            my_ldflags += -flto -fuse-ld=gold
          endif
        else
          my_cflags += -fno-lto -fuse-ld=gold
          my_ldflags += -fno-lto -fuse-ld=gold
        endif
      endif
    endif
  endif
endif
