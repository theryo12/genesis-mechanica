const std = @import("std");
const Allocator = std.mem.Allocator;

pub const MemUtils = struct {
    allocator: Allocator,
    memory_pool: MemoryPool,

    pub const MemoryPool = struct {
        allocator: Allocator,
        block_size: usize,
        pool_size: usize,
        free_blocks: std.ArrayList(?*u8),

        pub fn alloc(self: *MemoryPool) !?*u8 {
            if (self.free_blocks.items.len > 0) {
                return self.free_blocks.pop();
            } else {
                const block = try self.allocator.alloc(u8, self.block_size);
                return &block.ptr[0];
            }
        }

        pub fn free(self: *MemoryPool, ptr: ?*u8) !void {
            try self.free_blocks.append(ptr);
        }

        pub fn init(allocator: Allocator, block_size: usize, pool_size: usize) !MemoryPool {
            const free_blocks = std.ArrayList(?*u8).init(allocator);
            return MemoryPool{
                .allocator = allocator,
                .block_size = block_size,
                .pool_size = pool_size,
                .free_blocks = free_blocks,
            };
        }
    };

    pub const SmartBuffer = struct {
        data: ?*u8,
        size: usize,
        capacity: usize,
        allocator: Allocator,

        pub fn ensureCapacity(self: *SmartBuffer, new_size: usize) !void {
            if (new_size <= self.capacity) return;

            const new_capacity = @max(new_size, self.capacity * 2);
            const new_data = try self.allocator.alloc(u8, new_capacity);

            if (self.data) |old_ptr| {
                const old_data = @as([*]const u8, @ptrCast(old_ptr))[0..self.size];
                const new_data_slice = @as([*]u8, @ptrCast(new_data.ptr))[0..self.size];

                std.mem.copyForwards(u8, new_data_slice, old_data);
                self.allocator.destroy(old_ptr);
            }

            self.data = &new_data.ptr[0];
            self.capacity = new_capacity;
        }

        pub fn resize(self: *SmartBuffer, new_size: usize) !void {
            try self.ensureCapacity(new_size);
            self.size = new_size;
        }

        pub fn free(self: *SmartBuffer) void {
            if (self.data) |ptr| {
                self.allocator.destroy(ptr);
                self.data = null;
                self.size = 0;
                self.capacity = 0;
            }
        }

        pub fn init(allocator: Allocator, initial_size: usize) !SmartBuffer {
            var buffer = SmartBuffer{ .data = null, .size = 0, .capacity = 0, .allocator = allocator };
            try buffer.resize(initial_size);
            return buffer;
        }
    };

    pub fn alloc(self: *MemUtils, size: usize) !?*u8 {
        if (size <= 1024) {
            return self.memory_pool.alloc();
        } else {
            const block = try self.allocator.alloc(u8, size);
            return &block.ptr[0];
        }
    }

    pub fn free(self: *MemUtils, ptr: ?*u8, size: usize) void {
        if (size <= 1024) {
            self.memory_pool.free(ptr) catch {};
        } else if (ptr) |p| {
            self.allocator.destroy(p);
        }
    }

    pub fn init(allocator: Allocator) !MemUtils {
        return MemUtils{
            .allocator = allocator,
            .memory_pool = try MemoryPool.init(allocator, 256, 1024),
        };
    }
};
