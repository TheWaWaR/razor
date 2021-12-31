TARGET := riscv64-linux-musl
CC := "zig cc --target=$(TARGET)"
LD := "zig cc --target=$(TARGET)"

SECP256K1_SRC := ../deps/secp256k1/src/ecmult_static_pre_context.h

build/secp256k1_data_info.h: build/dump_secp256k1_data
	$<

build/dump_secp256k1_data: dump_secp256k1_data.c $(SECP256K1_SRC)
	mkdir -p build
	zig cc -I ../deps/secp256k1/src -I ../deps/secp256k1 -I ../deps/ckb-c-stdlib -o $@ $<

$(SECP256K1_SRC):
	cd ../deps/secp256k1 && \
		./autogen.sh && \
		CC=$(CC) LD=$(LD) ./configure --with-bignum=no --enable-ecmult-static-precomputation --enable-endomorphism --enable-module-recovery --host=$(TARGET) && \
		make src/ecmult_static_pre_context.h src/ecmult_static_context.h
