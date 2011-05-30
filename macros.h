#define ABS(target) ((target) - (BASE) - .)

#define QUAD_ABS(address) .quad 0x8000000000000000 + BASE + address

#define MEM_BASE(dest) \
    li dest, 1; \
    rldicr dest, dest, 63, 0;

#define LOAD_LABEL(base, dest, source, address) \
    oris    dest, source, ((base) + (address))@h; \
    ori    dest, dest, ((base) + (address))@l;

#define LOAD_LABEL2(dest, source, address) LOAD_LABEL(BASE, dest, source, address)

#define LOADI_LABEL2(dest, address) LOAD_LABEL2(dest, dest, address)
