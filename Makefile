THRIFT = $(or $(shell which thrift), $(error "`thrift' executable missing"))
REBAR = $(shell which rebar3 2>/dev/null || which ./rebar3)
SUBMODULES = build_utils
SUBTARGETS = $(patsubst %,%/.git,$(SUBMODULES))

UTILS_PATH := build_utils
TEMPLATES_PATH := .

# Name of the service
SERVICE_NAME := identification_proto

# Build image tag to be used
BUILD_IMAGE_NAME := build-erlang
BUILD_IMAGE_TAG := 61a001bbb48128895735a3ac35b0858484fdb2eb
CALL_ANYWHERE := \
	all submodules compile clean distclean \
	java.compile java.deploy

CALL_W_CONTAINER := $(CALL_ANYWHERE)

all: compile

-include $(UTILS_PATH)/make_lib/utils_container.mk

.PHONY: $(CALL_W_CONTAINER)

# CALL_ANYWHERE
$(SUBTARGETS): %/.git: %
	git submodule update --init $<
	touch $@

submodules: $(SUBTARGETS)

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean

distclean:
	$(REBAR) clean -a
	rm -rfv _build
