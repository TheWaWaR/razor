build:
	zig build -Dtarget=riscv64-freestanding

run: build
	RUST_LOG=debug ckb-debugger --max-cycles 1000000000 --bin zig-out/bin/zig-riscv64

clean:
	rm -rf zig-cache/ zig-out/

