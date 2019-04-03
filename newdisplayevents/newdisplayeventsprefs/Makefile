include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NewDisplayEventsPrefs
NewDisplayEventsPrefs_FILES = NDERootListController.m
NewDisplayEventsPrefs_INSTALL_PATH = /Library/PreferenceBundles
NewDisplayEventsPrefs_FRAMEWORKS = UIKit
NewDisplayEventsPrefs_PRIVATE_FRAMEWORKS = Preferences
NewDisplayEventsPrefs_EXTRA_FRAMEWORKS += KBAppList KBPreferences
NewDisplayEventsPrefs_LIBRARIES = activator
NewDisplayEventsPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NewDisplayEventsPrefs.plist$(ECHO_END)
