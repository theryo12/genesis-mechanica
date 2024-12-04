const std = @import("std");
const mem_utils = @import("mem_utils.zig");

test "copy works for slices of equal length" {
    var src = [_]u8{ 1, 2, 3, 4, 5 };
    var dst = [_]u8{ 0, 0, 0, 0, 0 };

    try mem_utils.copy(dst[0..], src[0..]);

    try std.testing.expect(std.mem.eql(u8, dst[0..], src[0..]));
}

test "copy returns an error for slices of unequal length" {
    var src = [_]u8{ 1, 2, 3 };
    var dst = [_]u8{ 0, 0 };

    const result = mem_utils.copy(dst[0..], src[0..]);

    try std.testing.expectError(error.InvalidSliceLength, result);
}

test "fill sets all elements to the specified value" {
    var buf = [_]u8{ 0, 0, 0, 0, 0 };

    mem_utils.fill(buf[0..], 42);

    try std.testing.expect(std.mem.eql(u8, buf[0..], &[_]u8{ 42, 42, 42, 42, 42 }));
}

test "zero clears all elements to 0" {
    var buf = [_]u8{ 1, 2, 3, 4, 5 };

    mem_utils.zero(buf[0..]);

    try std.testing.expect(std.mem.eql(u8, buf[0..], &[_]u8{ 0, 0, 0, 0, 0 }));
}

test "equals returns true for identical slices" {
    const a = [_]u8{ 1, 2, 3, 4, 5 };
    const b = [_]u8{ 1, 2, 3, 4, 5 };

    try std.testing.expect(mem_utils.equals(a[0..], b[0..]));
}

test "equals returns false for slices with differing content" {
    const a = [_]u8{ 1, 2, 3, 4, 5 };
    const b = [_]u8{ 1, 2, 0, 4, 5 };

    try std.testing.expect(!mem_utils.equals(a[0..], b[0..]));
}

test "alignPointer correctly aligns to the specified boundary" {
    const ptr = @as(usize, 7);
    const alignment = 4;

    const aligned_ptr = mem_utils.alignPointer(ptr, alignment);

    try std.testing.expect(mem_utils.isAligned(aligned_ptr, alignment));
}

test "allocate initializes memory to zero" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = allocator.deinit();

    const size = 5;
    const buf = try mem_utils.allocate(&allocator.allocator(), size);
    defer mem_utils.deallocate(&allocator.allocator(), buf);

    try std.testing.expect(std.mem.eql(u8, buf, &[_]u8{ 0, 0, 0, 0, 0 }));
}

test "deallocate frees memory without errors" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = allocator.deinit();

    const buf = try mem_utils.allocate(&allocator.allocator(), 5);

    mem_utils.deallocate(&allocator.allocator(), buf);
}
