const std = @import("std");
const mem_utils = @import("utils/mem/mem_utils.zig");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Test 1: Test copyMemory
    const src = [5]u8{ 1, 2, 3, 4, 5 };
    const dst = [_]u8{ 0, 0, 0, 0, 0 };
    mem_utils.copyMemory(&dst, &src);
    std.debug.print("Test 1: copyMemory\n", .{});
    std.debug.print("Source: ", .{});
    for (src) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\nDestination: ", .{});
    for (dst) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    // Test 2: Test zeroMemory
    const mem_to_zero = [_]u8{ 42, 43, 44, 45 };
    std.debug.print("Test 2: zeroMemory before\n", .{});
    for (mem_to_zero) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});
    mem_utils.zeroMemory(&mem_to_zero);
    std.debug.print("Test 2: zeroMemory after\n", .{});
    for (mem_to_zero) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    // Test 3: Test allocateZeroed
    const count: usize = 5;
    const buffer = mem_utils.allocateZeroed(u32, allocator, count) catch |err| {
        std.debug.print("Error allocating memory: {}\n", .{err});
        return;
    };
    std.debug.print("Test 3: allocateZeroed (buffer)\n", .{});
    for (buffer) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});

    // Test 5: Test resizeSlice
    const old_slice = [_]u32{ 1, 2, 3 };
    const new_size: usize = 5;
    const resized_slice = mem_utils.resizeSlice(u32, allocator, old_slice, new_size) catch |err| {
        std.debug.print("Error resizing slice: {}\n", .{err});
        return;
    };
    std.debug.print("Test 5: resizeSlice (old slice)\n", .{});
    for (old_slice) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});
    std.debug.print("Test 5: resizeSlice (resized slice)\n", .{});
    for (resized_slice) |v| std.debug.print("{d} ", .{v});
    std.debug.print("\n", .{});
}
