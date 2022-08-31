BUILD_MODE?=-Drelease-small=true

build: zig-out/bin/razor

zig-out/bin/razor:
	zig build ${BUILD_MODE}
	ls -rShl zig-out/bin/razor
	# riscv64-unknown-elf-strip zig-out/bin/razor
	# ls -rShl zig-out/bin/razor

run: zig-out/bin/razor
	RUST_LOG=debug ckb-debugger --max-cycles 1000000000 --bin zig-out/bin/razor

clean:
	rm -rf zig-cache/ zig-out/

