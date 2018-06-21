#/*
# Copyright (c) 2017 Redpine Signals Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 	1. Redistributions of source code must retain the above copyright
# 	   notice, this list of conditions and the following disclaimer.
#
# 	2. Redistributions in binary form must reproduce the above copyright
# 	   notice, this list of conditions and the following disclaimer in the
# 	   documentation and/or other materials provided with the distribution.
#
# 	3. Neither the name of the copyright holder nor the names of its
# 	   contributors may be used to endorse or promote products derived from
# 	   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#*/

SUPP_DIR=$(PWD)/supplicant
KERNELRELEASE=$(shell uname -r)
KERNELDIR=/lib/modules/$(KERNELRELEASE)/build

# uncomment below line for Caracalla board
#CONFIG_CARACALLA_BOARD=y

# uncomment below line to enable hardware scan support
CONFIG_HW_SCAN_OFFLOAD=y

# Uncomment below line for sdio inetrrupt polling 
#CONFIG_SDIO_INTR_POLL=y

# Uncomment below line for BT alone (Classic/LE/Dual) mode 
#CONFIG_RSI_BT_ALONE=y

# Uncomment below line for Wi-Fi BT coex mode
CONFIG_RSI_COEX=y

# Uncomment below line for WLAN + Zigbee coex mode
#CONFIG_RSI_ZIGB=y

# Uncomment below line for using WoWLAN
#CONFIG_RSI_WOW=y

# Uncomment below line for using P2P support
#CONFIG_RSI_P2P=y

# Uncomment below line for platforms with no SDIO multiblock support 
#CONFIG_RSI_NO_SDIO_MULTIBLOCK=y

# Uncomment below line for enabling RRM feature
#CONFIG_RSI_11K=y

# Uncomment below line for debugging RRM through debugs
#RSI_DEBUG_RRM=y

EXTRA_CFLAGS += -DLINUX -Wimplicit -Wstrict-prototypes -Wall -Werror
EXTRA_CFLAGS += -I$(PWD)/include
EXTRA_CFLAGS += -DCONFIG_RSI_DEBUGFS

COMMON_SDIO_OBJS += rsi_91x_sdio_ops.o rsi_91x_sdio.o 
COMMON_USB_OBJS += rsi_91x_usb_ops.o rsi_91x_usb.o

RSI_91X_OBJS := rsi_91x_hal.o \
  	        rsi_91x_main.o \
	        rsi_91x_mac80211.o \
	        rsi_91x_mgmt.o \
  	        rsi_91x_core.o \
		rsi_91x_ps.o \
 	        rsi_91x_debugfs.o

ifeq ($(CONFIG_CARACALLA_BOARD), y)
EXTRA_CFLAGS += -DCONFIG_CARACALLA_BOARD
#EXTRA_CFLAGS += -DCONFIG_SDIO_INTR_POLL
endif

ifeq ($(CONFIG_HW_SCAN_OFFLOAD), y)
EXTRA_CFLAGS += -DCONFIG_HW_SCAN_OFFLOAD
else
EXTRA_CFLAGS += -DPLATFORM_X86
endif

ifeq ($(CONFIG_SDIO_INTR_POLL), y)
EXTRA_CFLAGS += -DCONFIG_SDIO_INTR_POLL
endif

ifeq ($(CONFIG_RSI_BT_ALONE), y)
EXTRA_CFLAGS += -DCONFIG_RSI_BT_ALONE
RSI_91X_OBJS += rsi_91x_hci.o
endif

ifeq ($(CONFIG_RSI_COEX), y)
EXTRA_CFLAGS += -DCONFIG_RSI_COEX
RSI_91X_OBJS += rsi_91x_hci.o
RSI_91X_OBJS += rsi_91x_coex.o
endif

ifeq ($(CONFIG_RSI_ZIGB), y)
EXTRA_CFLAGS += -DCONFIG_RSI_ZIGB
RSI_91X_OBJS += rsi_91x_zigb.o
endif

ifeq ($(CONFIG_RSI_WOW), y)
EXTRA_CFLAGS += -DCONFIG_RSI_WOW
EXTRA_CFLAGS += -DRSI_HW_CONN_MONITOR
endif

ifeq ($(CONFIG_RSI_P2P), y)
EXTRA_CFLAGS += -DCONFIG_RSI_P2P
endif

ifeq ($(CONFIG_RSI_11K), y)
EXTRA_CFLAGS += -DCONFIG_RSI_11K
RSI_91X_OBJS += rsi_91x_rrm.o
endif

ifeq ($(RSI_DEBUG_RRM), y)
ifeq ($(CONFIG_RSI_11K), y)
EXTRA_CFLAGS += -DRSI_DEBUG_RRM
endif
endif

ifeq ($(CONFIG_RSI_NO_SDIO_MULTIBLOCK), y)
EXTRA_CFLAGS += -DCONFIG_RSI_NO_SDIO_MULTIBLOCK
endif

obj-m := rsi_sdio.o rsi_usb.o rsi_91x.o
rsi_sdio-objs := $(COMMON_SDIO_OBJS)
rsi_usb-objs := $(COMMON_USB_OBJS)
rsi_91x-objs := $(RSI_91X_OBJS)

all:
	@echo -e "\033[32mCompiling RSI drivers...\033[0m"
	make -C$(KERNELDIR)/ SUBDIRS=$(PWD) modules

clean:
	make -C$(KERNELDIR)/ SUBDIRS=$(PWD) clean 
