# Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := my_native_py
LOCAL_SRC_FILES := my_native_py.cpp
LOCAL_SHARED_LIBRARIES := boost_python3_shared
LOCAL_CFLAGS := -I/home/payload/Code/android/android-platform-ndk/sources/python/3.5/include/python 
LOCAL_ALLOW_UNDEFINED_SYMBOLS := true
#LOCAL_LDFLAGS += -pie
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE 	:= test
LOCAL_SRC_FILES := test.cpp
LOCAL_SHARED_LIBRARIES := python_shared
#LOCAL_LDFLAGS += -Wl,-export-dynamic,-whole-archive ./obj/local/armeabi/libpython3.5m.so -Wl,-export-dynamic,-no-whole-archive,-O1,-Bsymbolic-functions
#LOCAL_CFLAGS += -I/home/payload/Code/android/android-platform-ndk/sources/python/3.5/include/python
#LOCAL_LDFLAGS 	+= -fPIC
include $(BUILD_EXECUTABLE)

$(call import-module,python/3.5)
$(call import-module,boost/1.59.0)


