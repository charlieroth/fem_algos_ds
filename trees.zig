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

pub fn compare(a: ?*BinaryTree.Node, b: ?*BinaryTree.Node) bool {
    // Two trees are structural and value equivalent if bottom is reached
    // without returning false prior
    if (a == null and b == null) {
        return true;
    }

    // Structural equivalence: Two tress are not equivalent if two of (what
    // are supposed to be the same) nodes, are not the same
    if (a == null or b == null) {
        return false;
    }

    // Value equivalence: Two tress are not equivalent if two of (what
    // are supposed to be the same) nodes, are not the same value
    if (a.?.data != b.?.data) {
        return false;
    }

    return compare(a.?.left, b.?.left) and compare(a.?.right, b.?.right);
}

pub fn search(curr: ?*BinaryTree.Node, needle: u8) bool {
    if (curr) |node| {
        if (node.data == needle) {
            return true;
        }

        if (node.data < needle) {
            return search(node.right, needle);
        }

        return search(node.left, needle);
    }

    return false;
}

pub fn dfs(head: ?*BinaryTree.Node, needle: u8) bool {
    return search(head, needle);
}

// pub fn insert(parent: ?*BinaryTree.Node, curr: ?*BinaryTree.Node, node: *BinaryTree.Node) void {
//     if (node.data > curr.?.data) {
//         insert(curr, curr.?.right, node);
//     } else if (node.data <= curr.?.data) {
//         insert(curr, curr.?.left, node);
//     } else {
//         if (node.data > parent.?.data) {
//             parent.?.right = node;
//             return;
//         }
//
//         parent.?.left = node;
//         return;
//     }
// }

var n6 = BinaryTree.Node{ .data = 21 };
var n5 = BinaryTree.Node{ .data = 18 };
var n4 = BinaryTree.Node{ .data = 4 };
var n3 = BinaryTree.Node{ .data = 5 };
var n2 = BinaryTree.Node{
    .data = 3,
    .left = &n5,
    .right = &n6,
};
var n1 = BinaryTree.Node{
    .data = 23,
    .left = &n3,
    .right = &n4,
};
var n0 = BinaryTree.Node{
    .data = 7,
    .left = &n1,
    .right = &n2,
};
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

test "compare: two trees are structural and value equivalent" {
    var bt1n6 = BinaryTree.Node{ .data = 21 };
    var bt1n5 = BinaryTree.Node{ .data = 18 };
    var bt1n4 = BinaryTree.Node{ .data = 4 };
    var bt1n3 = BinaryTree.Node{ .data = 5 };
    var bt1n2 = BinaryTree.Node{
        .data = 3,
        .left = &bt1n5,
        .right = &bt1n6,
    };
    var bt1n1 = BinaryTree.Node{
        .data = 23,
        .left = &bt1n3,
        .right = &bt1n4,
    };
    var bt1n0 = BinaryTree.Node{
        .data = 7,
        .left = &bt1n1,
        .right = &bt1n2,
    };
    var bt1 = BinaryTree{ .root = &bt1n0 };

    var trees_are_equal = compare(bt.root, bt1.root);
    try testing.expect(trees_are_equal == true);
}

test "compare: two trees are structural equivalent and not value equivalent" {
    var bt1n6 = BinaryTree.Node{ .data = 42 };
    var bt1n5 = BinaryTree.Node{ .data = 18 };
    var bt1n4 = BinaryTree.Node{ .data = 4 };
    var bt1n3 = BinaryTree.Node{ .data = 5 };
    var bt1n2 = BinaryTree.Node{
        .data = 3,
        .left = &bt1n5,
        .right = &bt1n6,
    };
    var bt1n1 = BinaryTree.Node{
        .data = 23,
        .left = &bt1n3,
        .right = &bt1n4,
    };
    var bt1n0 = BinaryTree.Node{
        .data = 7,
        .left = &bt1n1,
        .right = &bt1n2,
    };
    var bt1 = BinaryTree{ .root = &bt1n0 };

    var trees_are_equal = compare(bt.root, bt1.root);
    try testing.expect(trees_are_equal == false);
}

test "compare: two trees are note structural or value equivalent" {
    var bt1n4 = BinaryTree.Node{ .data = 4 };
    var bt1n3 = BinaryTree.Node{ .data = 5 };
    var bt1n2 = BinaryTree.Node{
        .data = 3,
        .left = null,
        .right = null,
    };
    var bt1n1 = BinaryTree.Node{
        .data = 23,
        .left = &bt1n3,
        .right = &bt1n4,
    };
    var bt1n0 = BinaryTree.Node{
        .data = 7,
        .left = &bt1n1,
        .right = &bt1n2,
    };
    var bt1 = BinaryTree{ .root = &bt1n0 };

    var trees_are_equal = compare(bt.root, bt1.root);
    try testing.expect(trees_are_equal == false);
}

test "bfs: finds 4 in tree" {
    var bt1n3 = BinaryTree.Node{ .data = 4 };
    var bt1n2 = BinaryTree.Node{
        .data = 15,
        .left = null,
        .right = null,
    };
    var bt1n1 = BinaryTree.Node{
        .data = 5,
        .left = &bt1n3,
        .right = null,
    };
    var bt1n0 = BinaryTree.Node{
        .data = 10,
        .left = &bt1n1,
        .right = &bt1n2,
    };

    var bt1 = BinaryTree{ .root = &bt1n0 };
    var value_found = search(bt1.root, 4);
    try testing.expect(value_found == true);
}

test "bfs: fails to find 11 in tree" {
    var bt1n3 = BinaryTree.Node{ .data = 4 };
    var bt1n2 = BinaryTree.Node{
        .data = 15,
        .left = null,
        .right = null,
    };
    var bt1n1 = BinaryTree.Node{
        .data = 5,
        .left = &bt1n3,
        .right = null,
    };
    var bt1n0 = BinaryTree.Node{
        .data = 10,
        .left = &bt1n1,
        .right = &bt1n2,
    };

    var bt1 = BinaryTree{ .root = &bt1n0 };
    var value_found = search(bt1.root, 11);
    try testing.expect(value_found == false);
}
