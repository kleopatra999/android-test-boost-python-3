# Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := my_native_py
LOCAL_SRC_FILES := my_native_py.cpp
LOCAL_SHARED_LIBRARIES := boost_python3_shared python_shared
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE 	:= test
LOCAL_SRC_FILES := test.cpp
LOCAL_SHARED_LIBRARIES := python_shared
include $(BUILD_EXECUTABLE)

$(call import-module,python/3.5)
$(call import-module,boost/1.59.0)


