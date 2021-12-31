TARGET := riscv64-linux-musl
CC := zig cc --target=$(TARGET)
LD := zig cc --target=$(TARGET)

ZIG_DIR := $(shell dirname $(shell readlink -f $(shell which zig)))
SECP256K1_INCLUDES := -I build -I ../deps/ckb-production-scripts/c -I ../deps/ckb-c-stdlib -I ../deps/secp256k1/src -I ../deps/secp256k1 \
		-I $(ZIG_DIR)/lib/libc/include/generic-musl \
		-I $(ZIG_DIR)/lib/libc/include/riscv64-linux-musl
CFLAGS := $(SECP256K1_INCLUDES) -fPIC -O3 -nostdinc -nostdlib -fvisibility=hidden -Wall -Werror -Wno-nonnull -Wno-unused-function -g

SECP256K1_SRC := ../deps/secp256k1/src/ecmult_static_pre_context.h


all: build/secp256k1.o

build/secp256k1.o: secp256k1.c build/secp256k1_data_info.h
	$(CC) $(CFLAGS) -o $@ -c secp256k1.c

build/secp256k1_data_info.h: build/dump_secp256k1_data
	$<

build/dump_secp256k1_data: dump_secp256k1_data.c $(SECP256K1_SRC)
	mkdir -p build
	zig cc -I ../deps/secp256k1/src -I ../deps/secp256k1 -I ../deps/ckb-c-stdlib -o $@ $<

$(SECP256K1_SRC):
	cd ../deps/secp256k1 && \
		./autogen.sh && \
		CC="$(CC)" LD="$(LD)" ./configure --with-bignum=no --enable-ecmult-static-precomputation --enable-endomorphism --enable-module-recovery --host=$(TARGET) && \
		make src/ecmult_static_pre_context.h src/ecmult_static_context.h

clean:
	rm -rf build/*
	cd ../deps/secp256k1 && [ -f "Makefile" ] && make clean
