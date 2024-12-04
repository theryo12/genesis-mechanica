const std = @import("std");
const mem_utils = @import("mem_utils.zig");

test "allocate and free memory" {
    const allocator = std.heap.page_allocator;
    var utils = try mem_utils.MemUtils.init(allocator);

    const size = 256;
    const ptr = try utils.alloc(size);
    defer utils.free(ptr, size);

    try std.testing.expect(ptr != null);
}

test "resize buffer" {
    const allocator = std.heap.page_allocator;
    var buffer = try mem_utils.MemUtils.SmartBuffer.init(allocator, 64);
    defer buffer.free();

    try buffer.resize(128);
    try std.testing.expect(buffer.size == 128);

    try buffer.resize(64);
    try std.testing.expect(buffer.size == 64);
}

test "memory pool allocation and deallocation" {
    const allocator = std.heap.page_allocator;
    const pool_size = 1024;
    var pool = try mem_utils.MemUtils.MemoryPool.init(allocator, 256, pool_size);

    const ptr = try pool.alloc();
    try std.testing.expect(ptr != null);

    try pool.free(ptr);

    const ptr2 = try pool.alloc();
    try std.testing.expect(ptr == ptr2);
}

test "large allocation uses default allocator" {
    const allocator = std.heap.page_allocator;
    var utils = try mem_utils.MemUtils.init(allocator);

    const size = 2048;
    const ptr: ?*u8 = try utils.alloc(size);
    defer utils.free(ptr, size);

    try std.testing.expect(ptr != null);
}
