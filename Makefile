COPY=$(wildcard copy/*)
JNI=$(wildcard jni/*)

# the ndk-build outputs
LIBS=$(shell ndk-build -n | grep install | awk '{print $$4}')

# local copy of deployed files to automate adb push
DEPLOYED=$(addprefix deployed/,$(COPY) $(LIBS))

all: run-test

build: $(LIBS)

$(LIBS): $(JNI)
	ndk-build

deployed/%: %
	@echo -n "$<\t "
	@adb push $< /data/local/tmp/ && \
	mkdir -p `dirname $@` && \
	cp -rf $< $@                                # local copy of deployed files to automate adb push

deploy: build | $(DEPLOYED)

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

clean:
	rm -rf deployed libs obj build
	adb shell "rm -rf /data/local/tmp/*"
