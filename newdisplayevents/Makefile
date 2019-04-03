export ARCHS=arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NewDisplayEvents
NewDisplayEvents_FILES = Event.xm
NewDisplayEvents_EXTRA_FRAMEWORKS += KBAppList
NewDisplayEvents_LIBRARIES = activator

NewDisplayEvents_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += newdisplayeventsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
