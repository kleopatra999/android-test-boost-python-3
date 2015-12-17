
COPY=$(wildcard copy/*)
JNI=$(wildcard jni/*)
LIBS=$(shell ndk-build -n | grep install | awk '{print $$4}')
DEPLOYED=$(addprefix deployed/,$(COPY) $(LIBS))

all: run-test

build: $(JNI)
	ndk-build && touch build

deployed/%: %
	@echo -n "$<\t "
	@adb push $< /data/local/tmp/ && \
	mkdir -p `dirname $@` && \
	cp -rf $< $@

deploy: build | $(DEPLOYED)

run-test: deploy
	adb shell "cd /data/local/tmp && \
	LD_LIBRARY_PATH+=:. \
	LD_PRELOAD+=:libpython3.5m.so \
	PYTHONHOME= \
	PYTHONPATH+=:/data/local/tmp/stdlib.zip:. \
	./test"

clean:
	rm -rf deployed libs obj build
	adb shell "rm -rf /data/local/tmp/*"
