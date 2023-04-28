const std = @import("std");
const testing = std.testing;
const debug = std.debug;
const heap = std.heap;
const mem = std.mem;

const TailQueue = std.TailQueue;

pub const TraversalOrder = enum {
    PreOrder,
    InOrder,
    PostOrder,
};

pub const BinaryTree = struct {
    pub const Node = struct {
        data: u8,
        left: ?*Node = null,
        right: ?*Node = null,
    };

    root: *Node,
};

const Queue = TailQueue(?*BinaryTree.Node);

pub fn walk(curr: ?*BinaryTree.Node, path: *std.ArrayList(u8), order: TraversalOrder) !void {
    if (curr == null) {
        return;
    }

    if (order == .PreOrder) {
        try path.append(curr.?.data);
        try walk(curr.?.left, path, order);
        try walk(curr.?.right, path, order);
    } else if (order == .InOrder) {
        try walk(curr.?.left, path, order);
        try path.append(curr.?.data);
        try walk(curr.?.right, path, order);
    } else {
        try walk(curr.?.left, path, order);
        try walk(curr.?.right, path, order);
        try path.append(curr.?.data);
    }
}

// Traversal is DFS via a Stack
// The stack in this case is the "function call stack"
pub fn traverse(allocator: mem.Allocator, tree: *BinaryTree, order: TraversalOrder) ![]const u8 {
    var path: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    defer path.deinit();

    try walk(tree.root, &path, order);
    return try path.toOwnedSlice();
}

pub fn bfs(head: *BinaryTree.Node, needle: u8) bool {
    var queue = Queue{};
    queue.append(&Queue.Node{ .data = head });

    while (queue.len > 0) {
        var curr = queue.popFirst();
        if (curr) |node| {
            if (node.data) |node_data| {
                if (node_data.data == needle) {
                    return true;
                }
                queue.append(&Queue.Node{ .data = node_data.left });
                queue.append(&Queue.Node{ .data = node_data.right });
            }
        } else {
            continue;
        }
    }

    return false;
}

var n6 = BinaryTree.Node{ .data = 21 };
var n5 = BinaryTree.Node{ .data = 18 };
var n4 = BinaryTree.Node{ .data = 4 };
var n3 = BinaryTree.Node{ .data = 5 };
var n2 = BinaryTree.Node{ .data = 3, .left = &n5, .right = &n6 };
var n1 = BinaryTree.Node{ .data = 23, .left = &n3, .right = &n4 };
var n0 = BinaryTree.Node{ .data = 7, .left = &n1, .right = &n2 };
var bt = BinaryTree{ .root = &n0 };

test "traverses tree pre-order" {
    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var path = try traverse(allocator, &bt, .PreOrder);
    try testing.expect(path.len == 7);

    const expected_path = [7]u8{ 7, 23, 5, 4, 3, 18, 21 };
    try testing.expect(mem.eql(u8, path, &expected_path));
}

test "traverses tree post-order" {
    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var path = try traverse(allocator, &bt, .PostOrder);
    try testing.expect(path.len == 7);

    const expected_path = [7]u8{ 5, 4, 23, 18, 21, 3, 7 };
    try testing.expect(mem.eql(u8, path, &expected_path));
}

test "traverses tree in-order" {
    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var path = try traverse(allocator, &bt, .InOrder);
    try testing.expect(path.len == 7);

    const expected_path = [7]u8{ 5, 23, 4, 7, 18, 3, 21 };
    try testing.expect(mem.eql(u8, path, &expected_path));
}

test "bfs: does find 23" {
    const needle = 23;
    var did_find_needle = bfs(bt.root, needle);
    try testing.expect(did_find_needle == true);
}

test "bfs: does not find 42" {
    const needle = 42;
    var did_find_needle = bfs(bt.root, needle);
    try testing.expect(did_find_needle == false);
}
