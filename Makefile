COPY    = $(wildcard copy/*)
JNI     = $(shell find jni/ -type f)

.PHONY: all clean build deploy run-test python-copy python-clean
.NOTPARALLEL: but you can still run ndk-build in parallel with -j or so
all: run-test | make-env

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
$(info OUTPUTS  = $(OUTPUTS))

# local copy of deployed files to automate adb push
DEPLOYED        = $(addprefix deployed/,$(COPY) $(OUTPUTS))
PYTHON_DIR     ?= $(NDK_ROOT)/sources/python/3.5/libs/armeabi
PYTHON_FILES   ?= $(shell find $(PYTHON_DIR) -type f)
PYTHON_COPY     = $(PYTHON_FILES:$(PYTHON_DIR)/%=copy/%)
endif

endif


build: $(OUTPUTS)
deploy: $(DEPLOYED)
clean:
	rm -rf deployed libs obj .make
	adb shell "rm -rf /data/local/tmp/*"



# make-env
#  creates .make/ containing seldom changing information
#  which is always needed but generally slow to acquire
make-env: .make/outputs.mk .make/ndk-root.mk
.make/outputs.mk .make/ndk-root.mk: | .make

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



$(OUTPUTS): $(JNI)
	ndk-build

# deployed/%
#   adb push and make local copy of deployed file to automate with make
deployed/%: %
	@echo -n "$<\t "
	@adb push $< /data/local/tmp/ && \
	mkdir -p $(dir $@) && cp -rf $< $@

# run-test
#	 LD_LIBRARY_PATH+=:.                         # to find LD_PRELOADed library
#	 LD_PRELOAD+=:libpython3.5m.so               # link python symbols such that native module (.so) finds those
#	 PYTHONHOME=                                 # platform specific path prefixes. empty is enough for local python files.
#	 PYTHONPATH+=:/data/local/tmp/stdlib.zip:.   # the import paths. note there is a zip with the standard library and the local path
run-test: deploy
	adb shell "                                 \
	 cd /data/local/tmp &&                      \
	 LD_LIBRARY_PATH+=:.                        \
	 LD_PRELOAD+=:libpython3.5m.so              \
	 PYTHONHOME=                                \
	 PYTHONPATH+=:/data/local/tmp/stdlib.zip:.  \
	 ./test"



python-copy: $(PYTHON_COPY)

python-clean:
	rm -rf $(PYTHON_COPY)

copy/%: $(PYTHON_DIR)/%
	mkdir -p $(dir $@) && cp -rf $< $@
