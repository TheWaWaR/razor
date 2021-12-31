TARGET := riscv64-linux-musl
CC := "zig cc --target=$(TARGET)"
LD := "zig cc --target=$(TARGET)"

SECP256K1_SRC := ../deps/secp256k1/src/ecmult_static_pre_context.h

$(SECP256K1_SRC):
	cd ../deps/secp256k1 && \
		./autogen.sh && \
		CC=$(CC) LD=$(LD) ./configure --with-bignum=no --enable-ecmult-static-precomputation --enable-endomorphism --enable-module-recovery --host=$(TARGET) && \
		make src/ecmult_static_pre_context.h src/ecmult_static_context.h
