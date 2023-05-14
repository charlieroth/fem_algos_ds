const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const assert = std.debug.assert;

const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;

pub const MinHeapError = error{
    Deletion,
    Capacity,
};

const p = std.PriorityQueue;

pub const MinHeap = struct {
    length: usize,
    data: []i32,
    allocator: Allocator,

    pub fn init(allocator: Allocator) MinHeap {
        return MinHeap{ .data = &[_]i32{}, .length = 0, .allocator = allocator };
    }

    pub fn deinit(self: *MinHeap) void {
        self.allocator.free(self.data);
    }

    pub fn insert(self: *MinHeap, value: i32) !void {
        try self.ensure_capacity(1);
        // Insert value to end of heap, heapify up value
        self.data[self.length] = value;
        self.heapify_up(self.length);
        self.length += 1;
    }

    pub fn ensure_capacity(self: *MinHeap, requested_capacity: usize) !void {
        return self.ensure_total_capacity(self.length + requested_capacity);
    }

    pub fn ensure_total_capacity(self: *MinHeap, new_capacity: usize) !void {
        var better_capacity = self.data.len;
        // If there is already enough capacity, no need to adjust items slice
        if (better_capacity >= new_capacity) return;

        // Find new capacity
        while (true) {
            better_capacity += (better_capacity / 2) + 8;
            if (better_capacity >= new_capacity) break;
        }
        self.data = try self.allocator.realloc(self.data, better_capacity);
    }

    pub fn delete(self: *MinHeap) !i32 {
        if (self.length == 0) {
            return MinHeapError.Deletion;
        }

        self.length -= 1;

        const val = self.data[0];
        if (self.length == 0) {
            self.data = try self.allocator.realloc(self.data, 1);
            return val;
        }

        self.data[0] = self.data[self.length];
        self.heapify_down(0);
        return val;
    }

    pub fn heapify_down(self: *MinHeap, idx: usize) void {
        const left_idx = left_child(idx);
        const right_idx = right_child(idx);

        // Terminating conditions:
        // 1. If current index is greater than or equal to length of heap
        // 2. If left index is greater than or equal to length of heap
        if (idx >= self.length or left_idx >= self.length) return;

        const left_value = self.data[left_idx];
        const right_value = self.data[right_idx];
        const curr_value = self.data[idx];

        // Two cases to consider for MinHeap:
        // 1. Right value is smallest, current value is greater than right
        // value, therefore swap right and current nodes, heapify down
        // 2. Left value is smallest, current value is greater than left value,
        // therefore swap left and current nodes, heapify down
        if (left_value > right_value and curr_value > right_value) {
            self.data[idx] = right_value;
            self.data[right_idx] = curr_value;
            self.heapify_down(right_idx);
        } else if (right_value > left_value and curr_value > left_value) {
            self.data[idx] = left_value;
            self.data[left_idx] = curr_value;
            self.heapify_down(left_idx);
        }
    }

    pub fn heapify_up(self: *MinHeap, idx: usize) void {
        if (idx == 0) return;

        const curr_value = self.data[idx];

        // Get parent, get parent value, check if larger
        const parent_idx = parent(idx);
        const parent_value = self.data[parent_idx];

        if (parent_value > curr_value) {
            // Swap node with parent, heapify up again
            self.data[idx] = parent_value;
            self.data[parent_idx] = curr_value;
            self.heapify_up(parent_idx);
        }
    }
};

pub fn parent(idx: usize) usize {
    return (idx - 1) / 2;
}

pub fn left_child(idx: usize) usize {
    return (idx * 2) + 1;
}

pub fn right_child(idx: usize) usize {
    return (idx * 2) + 2;
}

test "min heap: insert values & remove all values in correct order" {
    var allocator = testing.allocator;
    var min_heap: MinHeap = MinHeap.init(allocator);
    defer min_heap.deinit();

    try testing.expectEqual(@as(usize, 0), min_heap.length);

    try min_heap.insert(5);
    try min_heap.insert(3);
    try min_heap.insert(69);
    try min_heap.insert(420);
    try min_heap.insert(4);
    try min_heap.insert(1);
    try min_heap.insert(8);
    try min_heap.insert(7);

    try testing.expectEqual(@as(usize, 8), min_heap.length);

    try testing.expectEqual(@as(i32, 1), try min_heap.delete());
    try testing.expectEqual(@as(i32, 3), try min_heap.delete());
    try testing.expectEqual(@as(i32, 4), try min_heap.delete());
    try testing.expectEqual(@as(i32, 5), try min_heap.delete());

    try testing.expectEqual(@as(usize, 4), min_heap.length);

    try testing.expectEqual(@as(i32, 7), try min_heap.delete());
    try testing.expectEqual(@as(i32, 8), try min_heap.delete());
    try testing.expectEqual(@as(i32, 69), try min_heap.delete());
    try testing.expectEqual(@as(i32, 420), try min_heap.delete());
}
