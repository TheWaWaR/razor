ALL_SRC := $(wildcard src/*.zig)
ALL_CKB_STD_SRC := $(wildcard ckb-std/src/*.zig)

zig-out/debug/razor: $(ALL_SRC) $(ALL_CKB_STD_SRC)
	zig build --prefix-exe-dir debug
	ls -l $@ && ls -hl $@

run: zig-out/debug/razor
	RUST_LOG=debug ckb-debugger --max-cycles 1000000000 --bin zig-out/debug/razor

zig-out/release-safe/razor: $(ALL_SRC) $(ALL_CKB_STD_SRC)
	zig build -Drelease-safe=true --prefix-exe-dir release-safe
	ls -l $@ && ls -hl $@

run-release: zig-out/release-safe/razor
	RUST_LOG=debug ckb-debugger --max-cycles 1000000000 --bin zig-out/release-safe/razor

test: zig-out/debug/razor
	cargo test --manifest-path rust-tests/Cargo.toml

clean:
	rm -rf zig-cache/ zig-out/

