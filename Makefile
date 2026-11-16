TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES := Aweme

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := AudioAssistant
AudioAssistant_FILES := Tweak.xm
AudioAssistant_FRAMEWORKS := UIKit
AudioAssistant_CFLAGS := -fobjc-arc
AudioAssistant_LDFLAGS := 
include $(THEOS_MAKE_PATH)/tweak.mk
