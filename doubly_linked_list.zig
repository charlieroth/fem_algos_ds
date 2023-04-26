const std = @import("std");
const testing = std.testing;

const ListError = error{ ItemNotFound, IndexOutOfRange, EmptyList };

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            next: ?*Node = null,
            prev: ?*Node = null,
            data: T,
        };

        head: ?*Node = null,
        tail: ?*Node = null,
        length: u64 = 0,

        pub fn len(self: *Self) u64 {
            return self.length;
        }

        pub fn insert_at(self: *Self, node: *Node, index: u64) ListError!void {
            if (index > self.length) {
                return ListError.IndexOutOfRange;
            }

            if (index == self.length) {
                self.append(node);
                return;
            } else if (index == 0) {
                self.prepend(node);
                return;
            }

            self.length += 1;

            var curr: ?*Node = self.head;
            var i: u64 = 0;
            while (i < index) : (i += 1) {
                curr = curr.?.next;
            }

            node.next = curr;
            node.prev = curr.?.prev;
            curr.?.prev.?.next = node;
            curr.?.prev = node;
        }

        pub fn remove(self: *Self, item: *Node) ListError!void {
            if (self.length == 0) {
                return ListError.EmptyList;
            }

            if (item.data == self.head.?.data) {
                try self.remove_at(0);
                return;
            } else if (item.data == self.tail.?.data) {
                try self.remove_at(self.length - 1);
                return;
            }

            self.length -= 1;
            item.prev.?.next = item.next;
            item.next.?.prev = item.prev;
        }

        pub fn remove_at(self: *Self, index: u64) ListError!void {
            if (index > self.length or index < 0) {
                return ListError.IndexOutOfRange;
            }

            self.length -= 1;
            if (index == 0) {
                self.head = self.head.?.next;
                self.head.?.prev = null;
                return;
            } else if (index == self.length) {
                self.tail = self.tail.?.prev;
                self.tail.?.next = null;
                return;
            }

            var curr: ?*Node = self.head;
            var i: u64 = 0;
            while (i < index) : (i += 1) {
                curr = curr.?.next;
            }

            curr.?.prev.?.next = curr.?.next;
            curr.?.next.?.prev = curr.?.prev;
        }

        pub fn append(self: *Self, item: *Node) void {
            self.length += 1;

            if (self.tail == null) {
                self.tail = item;
                self.head = item;
                return;
            }

            item.prev = self.tail;
            self.tail.?.next = item;
            self.tail = item;
        }

        pub fn prepend(self: *Self, node: *Node) void {
            self.length += 1;
            if (self.head == null) {
                self.head = node;
                self.tail = node;
                return;
            }

            node.next = self.head;
            self.head.?.prev = node;
            self.head = node;
        }

        pub fn debug(self: *Self) void {
            var curr: ?*Node = self.head;
            std.debug.print("\n", .{});
            while (curr) |node| {
                std.debug.print("{d}->", .{node.data});
                curr = node.next;
            }
            std.debug.print("\n", .{});
        }
    };
}

test "initializes linked list" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};
    try testing.expect(ll.head == null);
    try testing.expect(ll.tail == null);
    try testing.expect(ll.len() == 0);
}

test "prepends items to linked list" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};
    var n1 = DLL.Node{ .data = 10 };
    var n2 = DLL.Node{ .data = 13 };
    ll.prepend(&n1);
    ll.prepend(&n2);

    try testing.expect(ll.head.?.data == n2.data);
    try testing.expect(ll.tail.?.data == n1.data);
}

test "append items to linked list" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};
    var n1 = DLL.Node{ .data = 10 };
    var n2 = DLL.Node{ .data = 13 };
    ll.append(&n1);
    ll.append(&n2);

    try testing.expect(ll.head.?.data == n1.data);
    try testing.expect(ll.tail.?.data == n2.data);
}

test "inserts item at an index" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 4);

    var n3 = DLL.Node{ .data = 3 };
    try ll.insert_at(&n3, 2);
    try testing.expect(ll.len() == 5);

    try testing.expect(n3.prev.?.data == n2.data);
    try testing.expect(n3.next.?.data == n4.data);
}

test "removes item at head" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n3 = DLL.Node{ .data = 3 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n3);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 5);

    try ll.remove_at(0);
    try testing.expect(ll.len() == 4);
    try testing.expect(ll.head.?.data == n2.data);
    try testing.expect(n2.prev == null);
    try testing.expect(n2.next.?.data == n3.data);
}

test "removes item at tail" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n3 = DLL.Node{ .data = 3 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n3);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 5);

    try ll.remove_at(4);
    try testing.expect(ll.len() == 4);
    try testing.expect(ll.tail.?.data == n4.data);
    try testing.expect(n4.next == null);
}

test "removes item at 'middle' index" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n3 = DLL.Node{ .data = 3 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n3);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 5);

    try ll.remove_at(2);

    try testing.expect(ll.len() == 4);
    try testing.expect(n2.next.?.data == n4.data);
    try testing.expect(n4.prev.?.data == n2.data);
}

test "removes item (head)" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n3 = DLL.Node{ .data = 3 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n3);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 5);

    try ll.remove(&n1);
    try testing.expect(ll.len() == 4);
    try testing.expect(ll.head.?.data == n2.data);
    try testing.expect(n2.prev == null);
    try testing.expect(n2.next.?.data == n3.data);
}

test "removes item (tail)" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n3 = DLL.Node{ .data = 3 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n3);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 5);

    try ll.remove(&n5);
    try testing.expect(ll.len() == 4);
    try testing.expect(ll.tail.?.data == n4.data);
    try testing.expect(n4.next == null);
}

test "removes item (middle)" {
    const DLL = DoublyLinkedList(u8);
    var ll = DLL{};

    var n1 = DLL.Node{ .data = 1 };
    var n2 = DLL.Node{ .data = 2 };
    var n3 = DLL.Node{ .data = 3 };
    var n4 = DLL.Node{ .data = 4 };
    var n5 = DLL.Node{ .data = 5 };

    ll.append(&n1);
    ll.append(&n2);
    ll.append(&n3);
    ll.append(&n4);
    ll.append(&n5);
    try testing.expect(ll.len() == 5);

    try ll.remove(&n3);
    try testing.expect(ll.len() == 4);
    try testing.expect(n2.next.?.data == n4.data);
    try testing.expect(n4.prev.?.data == n2.data);
}
