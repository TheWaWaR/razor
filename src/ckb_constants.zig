pub const SYS_EXIT: u64 = 93;
pub const SYS_VM_VERSION: u64 = 2041;
pub const SYS_CURRENT_CYCLES: u64 = 2042;
pub const SYS_EXEC: u64 = 2043;
pub const SYS_LOAD_TRANSACTION: u64 = 2051;
pub const SYS_LOAD_SCRIPT: u64 = 2052;
pub const SYS_LOAD_TX_HASH: u64 = 2061;
pub const SYS_LOAD_SCRIPT_HASH: u64 = 2062;
pub const SYS_LOAD_CELL: u64 = 2071;
pub const SYS_LOAD_HEADER: u64 = 2072;
pub const SYS_LOAD_INPUT: u64 = 2073;
pub const SYS_LOAD_WITNESS: u64 = 2074;
pub const SYS_LOAD_CELL_BY_FIELD: u64 = 2081;
pub const SYS_LOAD_HEADER_BY_FIELD: u64 = 2082;
pub const SYS_LOAD_INPUT_BY_FIELD: u64 = 2083;
pub const SYS_LOAD_CELL_DATA_AS_CODE: u64 = 2091;
pub const SYS_LOAD_CELL_DATA: u64 = 2092;
pub const SYS_DEBUG: u64 = 2177;

pub const CKB_SUCCESS: u64 = 0;

pub const Source = enum(u64) {
    input = 1,
    output = 2,
    cell_dep = 3,
    header_dep = 4,
    group_input = 0x0100000000000001,
    group_output = 0x0100000000000002,
};
pub const CellField = enum(u64) {
    capacity = 0,
    data_hash = 1,
    lock = 2,
    lock_hash = 3,
    @"type" = 4,
    type_hash = 5,
    occupied_capacity = 6,
};
pub const HeaderField = enum(u64) {
    epoch_number = 0,
    epoch_start_block_number = 1,
    epoch_length = 2,
};
pub const InputField = enum(u64) {
    out_point = 0,
    since = 1,
};
