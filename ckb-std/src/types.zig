/// Specifies how the script `code_hash` is used to match the script code and how to run the code.
pub const ScriptHashType = enum(u8) {
    /// Type "data" matches script code via cell data hash, and run the script code in v0 CKB VM.
    data = 0,
    /// Type "type" matches script code via cell type script hash.
    @"type" = 1,
    /// Type "data" matches script code via cell data hash, and run the script code in v1 CKB VM.
    data1 = 2,
};
