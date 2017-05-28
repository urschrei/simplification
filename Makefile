RUSTDIR = ../rdp

simplification/cutil.so: simplification/cutil.pyx simplification/cutil.c setup.py simplification/librdp.dylib
	@echo "Rebuilding Cython extension"
	@python setup.py build_ext --inplace

# here's how to build an up-to-date OSX binary
# changing util.{py, pyx} will also trigger a rebuild
simplification/librdp.dylib: $(RUSTDIR)/src/*.rs $(RUSTDIR)/Cargo.toml simplification/util.py
	@echo "Running Rust tests"
	cargo test --manifest-path=$(RUSTDIR)/Cargo.toml
	@echo  "Rebuilding Rust release binary"
	@cargo build --manifest-path=$(RUSTDIR)/Cargo.toml --release
	@cp $(RUSTDIR)/target/release/librdp.dylib simplification

.PHONY: clean
clean:
	@echo "Cleaning Rust project"
	@cd $(RUSTDIR) && cargo clean
	@echo "Removing Wheel build and dist dir"
	-@rm -rf build
	-@rm -rf dist
	-@rm *.pyc
	-@rm simplification/*.pyc
	-@rm simplification/*.dylib
	-@rm simplification/*.so
	-@rm simplification*.c

# rebuild OSX binary if it's out of date, then run Python module tests 
.PHONY: test
test: simplification/librdp.dylib simplification/cutil.so
	@echo "Running Python 2.7 module tests"
	@venv/bin/nosetests -v
	@echo "Running Python 3.5 module tests"
	@venv3/bin/nosetests -v

.PHONY: release
release:
	@rm -rf dist/*
	@echo "Getting latest release from GitHub"
	@python release.py
	@echo "Successfully retrieved release. Uploading to PyPI"
	@twine upload dist/* --sign --identity 39C1ED9A -r pypi
	@echo "Successfully uploaded wheels to PyPI"
