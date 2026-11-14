# Builds `atmos-uv`, the Atmos compiler dedicated to this environment:
# it includes `uv.atm` before every program and links libuv.
#
#   make                    # needs the compiler in ../lang (or LANG=<dir>)
#   ./atmos-uv prog.atm
#   make test

LANG ?= ../lang

atmos-uv: uv.atm $(LANG)/atmos
	$(MAKE) -C $(LANG) env OUT=$(CURDIR)/atmos-uv ENV=$(CURDIR)/uv.atm ENV_LDFLAGS="-luv"

test: atmos-uv
	tst/run.sh

clean:
	rm -rf atmos-uv build

.PHONY: test clean
