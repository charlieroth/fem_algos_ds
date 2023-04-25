const std = @import("std");
const testing = std.testing;

const LinkedListError = error{ ItemNotFound, IndexOutOfRange };

pub fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        next: ?*Node(T) = null,
        prev: ?*Node(T) = null,
        data: T,
    };
}

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        head: ?*Node(T) = null,
        tail: ?*Node(T) = null,
        length: u64 = 0,

        pub fn len(self: *Self) u64 {
            return self.length;
        }

        pub fn insert_at(self: *Self, item: *Node(T), index: u64) LinkedListError!void {
            if (index > self.length) {
                return LinkedListError.IndexOutOfRange;
            }

            if (index == self.length) {
                self.append(item);
                return;
            } else if (index == 0) {
                self.prepend(item);
                return;
            }

            self.length += 1;

            var curr: ?*Node(T) = self.head;
            var i: u64 = 0;
            while (i < index) : (i += 1) {
                curr = curr.?.next;
            }

            item.next = curr;
            item.prev = curr.?.prev;
            curr.?.prev = item;
            curr.?.prev.?.next = item;
        }

        // pub fn remove(self: *Self, item: *Node(T)) LinkedListError!T {}
        //
        // pub fn remove_at(self: *Self, index: u64) LinkedListError!T {}

        pub fn append(self: *Self, item: *Node(T)) void {
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

        pub fn prepend(self: *Self, item: *Node(T)) void {
            self.length += 1;
            if (self.head == null) {
                self.head = item;
                self.tail = item;
                return;
            }

            item.next = self.head;
            self.head.?.prev = item;
            self.head = item;
        }

        // pub fn get(index: T) LinkedListError!T {}
    };
}

test "initializes linked list" {
    var ll = LinkedList(u8){};
    try testing.expect(ll.head == null);
    try testing.expect(ll.tail == null);
    try testing.expect(ll.len() == 0);
}

test "prepends items to linked list" {
    var ll = LinkedList(u8){};
    var n1 = Node(u8){ .data = 10 };
    ll.prepend(&n1);

    try testing.expect(ll.head.?.data == n1.data);
}

test "append items to linked list" {
    var ll = LinkedList(u8){};
    var n1 = Node(u8){ .data = 10 };
    var n2 = Node(u8){ .data = 13 };
    ll.append(&n1);
    ll.append(&n2);

    try testing.expect(ll.head.?.data == n1.data);
    try testing.expect(ll.tail.?.data == n2.data);
}

// TODO: seems to be mistake in ordering???
test "append items to linked list" {
    var ll = LinkedList(u8){};

    var n0 = Node(u8){ .data = 0 };
    var n1 = Node(u8){ .data = 1 };
    var n3 = Node(u8){ .data = 3 };
    var n4 = Node(u8){ .data = 4 };

    ll.append(&n0);
    ll.append(&n1);
    ll.append(&n3);
    ll.append(&n4);
    try testing.expect(ll.len() == 4);

    var n2 = Node(u8){ .data = 2 };
    try ll.insert_at(&n2, 1);
    try testing.expect(ll.len() == 5);
    try testing.expect(n2.next.?.data == n3.data);
    try testing.expect(n2.prev.?.data == n1.data);
}
