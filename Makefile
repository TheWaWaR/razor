build:
	zig build -Dtarget=riscv64-freestanding
	ls -rShl zig-out/bin/zig-riscv64
	riscv64-unknown-elf-strip zig-out/bin/zig-riscv64
	ls -rShl zig-out/bin/zig-riscv64

run: build
	RUST_LOG=debug ckb-debugger --max-cycles 1000000000 --bin zig-out/bin/zig-riscv64

clean:
	rm -rf zig-cache/ zig-out/

