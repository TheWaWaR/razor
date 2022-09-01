const std = @import("std");

pub const SysError = error{
    /// Index out of bound
    IndexOutOfBound,
    /// Field is missing for the target
    ItemMissing,
    /// Slice out of bound
    SliceOutOfBound,
    /// Data encoding error
    WrongFormat,
    /// Unknown syscall return error code
    UnknownSyscallError,
} || std.mem.Allocator.Error;
