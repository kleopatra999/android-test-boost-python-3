
COPY=$(wildcard copy/*)
JNI=$(wildcard jni/*)
LIBS=$(wildcard obj/local/armeabi/)
DEPLOYED=$(addprefix deployed/,libs/armeabi copy)

all: copy/python | run-test

build:
	ndk-build

deployed/%: %
	@adb push $< /data/local/tmp/
	@mkdir -p `dirname $@`
	@cp -rf $< $@

deploy: build | $(DEPLOYED)

run-test: deploy
	adb shell "cd /data/local/tmp && LD_LIBRARY_PATH=. PYTHONHOME= PYTHONPATH=/data/local/tmp/stdlib.zip ./test"

clean:
	rm -rf deployed libs obj
	adb shell "rm -rf /data/local/tmp/*"
