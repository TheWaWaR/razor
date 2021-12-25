pub const SysError = error{
    /// Index out of bound
    IndexOutOfBound,
    /// Field is missing for the target
    ItemMissing,
    /// Slice out of bound
    SliceOutOfBound,
    /// Data encoding error
    WrongFormat,
};
