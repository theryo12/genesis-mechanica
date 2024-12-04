const std = @import("std");

/// `mem_utils.zig`
/// A lightweight, optimized memory utility module.
/// Provides safe, idiomatic functions for common memory operations.
pub fn copy(dst: []u8, src: []const u8) !void {
    // ensure the destination and source slices are the same length
    if (dst.len != src.len) {
        return error.InvalidSliceLength;
    }
    std.mem.copyForwards(u8, dst, src);
}

/// Fills a slice with a specified byte value.
/// - `buf`: The slice to fill.
/// - `value`: The byte value to fill the slice with.
pub fn fill(buf: []u8, value: u8) void {
    for (buf) |*byte| {
        byte.* = value;
    }
}

/// Zeroes out a slice by filling it with `0x00`.
/// - `buf`: The slice to zero.
pub fn zero(buf: []u8) void {
    fill(buf, 0);
}

/// Compares two slices for equality.
/// - Returns `true` if the slices are equal; otherwise, `false`.
pub fn equals(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    return std.mem.eql(u8, a, b);
}

/// Aligns a pointer to the specified alignment.
/// Returns a pointer that is guaranteed to be aligned.
/// - `ptr`: The pointer to align.
/// - `alignment`: Must be a power of 2.
pub fn alignPointer(ptr: usize, alignment: u32) usize {
    return (ptr + alignment - 1) & ~(alignment - 1);
}

/// Checks if a pointer is aligned to a specific boundary.
/// - `ptr`: The pointer to check.
/// - `alignment`: Must be a power of 2.
/// - Returns `true` if the pointer is aligned; otherwise, `false`.
pub fn isAligned(ptr: usize, alignment: u32) bool {
    return (ptr & (alignment - 1)) == 0;
}

/// Memory utilities to wrap standard allocators.
/// These helpers ensure safer and easier-to-read allocation patterns.
pub fn allocate(allocator: *const std.mem.Allocator, size: usize) ![]u8 {
    const buf = try allocator.alloc(u8, size);
    zero(buf); // zero the memory to prevent uninitialized data issues
    return buf;
}

/// Frees memory allocated by an allocator.
/// - `allocator`: The allocator used for the allocation.
/// - `buffer`: The slice to free.
pub fn deallocate(allocator: *const std.mem.Allocator, buffer: []u8) void {
    allocator.free(buffer);
}
