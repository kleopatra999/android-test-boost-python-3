PROJECT_NAME    = test
EXECUTABLE      = $(PROJECT_NAME)
REMOTE          = /data/local/tmp/$(PROJECT_NAME)
JNI             = $(shell find jni/ -type f)
ASSETS          = $(shell find assets/ -type f)
# The python folder which gets copied to the device.
# The default path is relative to NDK_ROOT but can only be reliably set below.
# You can still override the default here.
# Default: $(NDK_ROOT)/sources/python/3.5/libs/armeabi
#PYTHON_DIR      =

.PHONY: all
all: ndk-build

.PHONY: help
help:
	@echo
ifneq (,$(findstring help,$(MAKECMDGOALS)))
$(info 'make' or 'make ndk-build' compiles and links the files in 'jni/'.)
$(info 'make install' pushes assets, python and outputs of 'ndk-build' \
 on the device into $(REMOTE). It creates a 'install' cache for incrementally updating files on the device.)
$(info 'make run' runs the executable '$(EXECUTABLE)' on the device.)
$(info 'make clean' removes everything execept the 'install' cache.)
$(info 'make uninstall' removes the 'install' cache and removes the project folder on the device.)
endif

# To get information out of ndk-build to build more incrementally
#  I do some jumping through loops.
# First I ask ndk-build for NDK_ROOT via grep if necessary.
# Second I ask ndk-build for its outputs to know what needs to be pushed
#  to device.
# Polling ndk-build for this information takes too much time (2 seconds)
#  so I cache this information in hidden makefiles.
# These makefiles get made on startup and their make rules
#  depend on the jni/Android.mk etc. and the ndk-build executables in PATH.
ifeq (,$(findstring clean,$(MAKECMDGOALS)))
-include .make/ndk-root.mk
-include .make/outputs.mk

ifneq (,$(wildcard .make/*))
$(info NDK_ROOT = $(NDK_ROOT))
PYTHON_DIR     ?= $(NDK_ROOT)/sources/python/3.5/libs/armeabi
PYTHON_FILES   ?= $(shell find $(PYTHON_DIR) -type f)
PYTHON_OUT      = assets/python
PYTHON_COPY     = $(PYTHON_FILES:$(PYTHON_DIR)/%=$(PYTHON_OUT)/%)
ASSETS         += $(PYTHON_COPY)
# This softlinks python directly into assets/python.
# The rule for pushing assets onto the device works fine with this.
# The install cache doesn't need to fully copy python but can still
# push incrementally to the device.
$(shell ln -sf $(PYTHON_DIR) $(PYTHON_OUT))
endif

endif



.PHONY: clean uninstall
clean:
	rm -rf libs obj .make
uninstall:
	adb shell "rm -rf $(REMOTE)"
	rm -rf install



# make-env
#  creates .make/ containing seldom changing information
#  which is always needed but generally slow to acquire
make-env: .make/outputs.mk .make/ndk-root.mk
.make/outputs.mk .make/ndk-root.mk: | .make
.make/%: | .make

.make:
	@mkdir .make

# the ndk-build output files, like libraries and executables
.make/outputs.mk: jni/*.mk
	$(file >  $@,define OUTPUTS = )
	$(file >> $@,$(shell ndk-build -n | grep install | awk '{print $$4}'))
	$(file >> $@,endef)

# the value of NDK_ROOT
.make/ndk-root.mk: $(shell whereis ndk-build | cut -d\  -f2-)
	$(file >  $@,define NDK_ROOT = )
	$(file >> $@,$(shell ndk-build -np | grep '^NDK_ROOT' | awk '{print $$3}'))
	$(file >> $@,endef)



.PHONY: install
install: install-libs install-assets

INSTALL_OUTPUTS = $(addprefix install/,$(OUTPUTS:./%=%))
INSTALL_ASSETS  = $(addprefix install/,$(ASSETS:./%=%))

define install-adb-push =
adb push $< $(REMOTE)$(@:install%=%)
@mkdir -p $(dir $@) && touch $@
endef

.PHONY: install-libs
install-libs: $(INSTALL_OUTPUTS)
install/libs/armeabi/%: obj/local/armeabi/%
	$(install-adb-push)

.PHONY: install-assets
install-assets: $(INSTALL_ASSETS)
install/assets/%: assets/%
	$(install-adb-push)

# libs/armeabi/libcrystax.so
#  is always touched by ndk-build,
#  and resides only in the libs/ directory.
# I deal with it separately and through a cached version.
install/libs/armeabi/libcrystax.so: .make/libcrystax.so
	$(install-adb-push)
.make/libcrystax.so: libs/armeabi/libcrystax.so
	@cmp -s $< $@ || ( cp $< $@ && echo cp $< $@ )



.PHONY: ndk-build
ndk-build: libs/armeabi
libs/armeabi: $(JNI)
	ndk-build



# run-test
#     LD_LIBRARY_PATH    # to find LD_PRELOADed library
#     LD_PRELOAD         # link python symbols such that native module (.so) finds those
#     PYTHONHOME         # platform specific path prefixes. empty is enough for local python files.
#     PYTHONPATH         # the import paths. note there is a zip with the standard library and the local path
#    MAIN_PY            # a path to the python file `test` will load and run, defaults to ../../assetes/main.py
.PHONY: run
run:
	adb shell '                                             \
	 cd $(REMOTE)/libs/armeabi &&                           \
	 LD_LIBRARY_PATH+=:.                                    \
	 LD_LIBRARY_PATH+=:$(REMOTE)/$(PYTHON_OUT)/             \
	 LD_PRELOAD+=:libpython3.5m.so                          \
	 PYTHONHOME=                                            \
	 PYTHONPATH+=:$(REMOTE)/$(PYTHON_OUT)/stdlib.zip        \
	 PYTHONPATH+=:$(REMOTE)/$(PYTHON_OUT)/                  \
	 MAIN_PY=$(REMOTE)/assets/main.py                       \
	 ./$(EXECUTABLE)'
