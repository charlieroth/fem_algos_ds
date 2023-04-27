const std = @import("std");
const testing = std.testing;
const debug = std.debug;
const heap = std.heap;
const mem = std.mem;

pub const BinaryTree = struct {
    pub const Node = struct {
        data: u8,
        left: ?*Node = null,
        right: ?*Node = null,
    };

    root: *Node,
};

pub fn pre_walk(curr: ?*BinaryTree.Node, path: *std.ArrayList(u8)) !void {
    if (curr == null) {
        return;
    }

    try path.append(curr.?.data);
    try pre_walk(curr.?.left, path);
    try pre_walk(curr.?.right, path);
}

pub fn pre_order_traversal(tree: *BinaryTree, allocator: mem.Allocator) ![]const u8 {
    var path: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    defer path.deinit();

    try pre_walk(tree.root, &path);
    return try path.toOwnedSlice();
}

pub fn post_walk(curr: ?*BinaryTree.Node, path: *std.ArrayList(u8)) !void {
    if (curr == null) {
        return;
    }

    try post_walk(curr.?.left, path);
    try post_walk(curr.?.right, path);
    try path.append(curr.?.data);
}

pub fn post_order_traversal(tree: *BinaryTree, allocator: mem.Allocator) ![]const u8 {
    var path: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    defer path.deinit();

    try post_walk(tree.root, &path);
    return try path.toOwnedSlice();
}

pub fn in_walk(curr: ?*BinaryTree.Node, path: *std.ArrayList(u8)) !void {
    if (curr == null) {
        return;
    }

    try in_walk(curr.?.left, path);
    try path.append(curr.?.data);
    try in_walk(curr.?.right, path);
}

pub fn in_order_traversal(tree: *BinaryTree, allocator: mem.Allocator) ![]const u8 {
    var path: std.ArrayList(u8) = std.ArrayList(u8).init(allocator);
    defer path.deinit();

    try in_walk(tree.root, &path);
    return try path.toOwnedSlice();
}

test "traverses tree pre-order" {
    var n6 = BinaryTree.Node{ .data = 21 };
    var n5 = BinaryTree.Node{ .data = 18 };
    var n4 = BinaryTree.Node{ .data = 4 };
    var n3 = BinaryTree.Node{ .data = 5 };
    var n2 = BinaryTree.Node{ .data = 3, .left = &n5, .right = &n6 };
    var n1 = BinaryTree.Node{ .data = 23, .left = &n3, .right = &n4 };
    var n0 = BinaryTree.Node{ .data = 7, .left = &n1, .right = &n2 };
    var bt = BinaryTree{ .root = &n0 };

    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var path = try pre_order_traversal(&bt, allocator);
    try testing.expect(path.len == 7);

    const expected_path = [7]u8{ 7, 23, 5, 4, 3, 18, 21 };
    try testing.expect(mem.eql(u8, path, &expected_path));
}

test "traverses tree post-order" {
    var n6 = BinaryTree.Node{ .data = 21 };
    var n5 = BinaryTree.Node{ .data = 18 };
    var n4 = BinaryTree.Node{ .data = 4 };
    var n3 = BinaryTree.Node{ .data = 5 };
    var n2 = BinaryTree.Node{ .data = 3, .left = &n5, .right = &n6 };
    var n1 = BinaryTree.Node{ .data = 23, .left = &n3, .right = &n4 };
    var n0 = BinaryTree.Node{ .data = 7, .left = &n1, .right = &n2 };
    var bt = BinaryTree{ .root = &n0 };

    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var path = try post_order_traversal(&bt, allocator);
    try testing.expect(path.len == 7);

    const expected_path = [7]u8{ 5, 4, 23, 18, 21, 3, 7 };
    try testing.expect(mem.eql(u8, path, &expected_path));
}

test "traverses tree in-order" {
    var n6 = BinaryTree.Node{ .data = 21 };
    var n5 = BinaryTree.Node{ .data = 18 };
    var n4 = BinaryTree.Node{ .data = 4 };
    var n3 = BinaryTree.Node{ .data = 5 };
    var n2 = BinaryTree.Node{ .data = 3, .left = &n5, .right = &n6 };
    var n1 = BinaryTree.Node{ .data = 23, .left = &n3, .right = &n4 };
    var n0 = BinaryTree.Node{ .data = 7, .left = &n1, .right = &n2 };
    var bt = BinaryTree{ .root = &n0 };

    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var path = try in_order_traversal(&bt, allocator);
    try testing.expect(path.len == 7);

    const expected_path = [7]u8{ 5, 23, 4, 7, 18, 3, 21 };
    try testing.expect(mem.eql(u8, path, &expected_path));
}
