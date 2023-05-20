const std = @import("std");

const mem = std.mem;
const testing = std.testing;

pub const StackError = error{Empty};

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            value: T,
            next: ?*Node = null,
        };

        head: ?*Node = null,
        length: usize = 0,
        allocator: mem.Allocator,

        pub fn init(allocator: mem.Allocator) Self {
            return Self{
                .head = null,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self.head == null) return;

            while (self.length != 0) {
                _ = self.pop();
            }
        }

        pub fn push(self: *Self, value: T) !void {
            var node = try self.allocator.create(Node);
            node.value = value;
            node.next = null;
            self.length += 1;

            if (self.head) |head| {
                node.next = head;
                self.head = node;
                return;
            } else {
                self.head = node;
            }
        }

        pub fn pop(self: *Self) T {
            if (self.head) |head| {
                var prev_head = head;
                var prev_head_value = prev_head.value;

                self.head = head.next;
                self.length -= 1;
                self.allocator.destroy(prev_head);

                return prev_head_value;
            }

            return -1;
        }

        pub fn print(self: *Self) void {
            var curr: ?*Node = self.head;
            while (curr) |node| {
                std.debug.print("{}->", .{node.value});
                curr = node.next;
            }
            std.debug.print("\n", .{});
        }
    };
}

test "push 5 items" {
    var stack = Stack(i32).init(testing.allocator);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try testing.expect(stack.length == 3);
    try stack.push(4);
    try stack.push(5);
    try testing.expect(stack.length == 5);
}

test "pushes 5 items, pops 3 items" {
    var stack = Stack(i32).init(testing.allocator);
    defer stack.deinit();

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try stack.push(4);
    try stack.push(5);
    try testing.expect(stack.length == 5);
    _ = stack.pop();
    _ = stack.pop();
    try testing.expect(stack.length == 3);
}
