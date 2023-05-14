# Heap

Often the underlying implementation for a Priority Queue.

Simply put, a Heap is a binary tree where every child and grand child is 
smaller (Max Heap) or larger (Min Heap) than the current node.

Operationally:

- Whenever a node is added, we must adjust the tree
- Whenever a node is deleted, we must adjust the tree
- There is no traversing the tree


Heaps maintain a week ordering.

A Heap is always a "full tree".

## Insertion (Min Heap)

Principal: **Root node is the smallest value**

E.g., top node is the value `50`. There are several nodes following `50`

The value `3` is inserted at the bottom. This creates an unordered tree,
therefore an action must take place to re-order the tree. The action of moving
the value `3` to the top of the tree (its correct position) is called the
**heapify up** operation. This is a series of value comparisons where the
node containing `3` is compared to its parent to see check if it is less than
its parent's value. If yes, swap the node in the tree, otherwise the
**heapify up** operation is complete.

## Deletion (Min Heap)

Principal: **Root node is the smallest value**

E.g. After the above insertion, top node is `3` and we want to delete this node.
Another node `200` was added to the tree. This node is now the "maxium" node
in the tree.

We first start by "popping" this node to the caller. Now there is a hole in
the tree at the root node. To rebalance the tree, you take the bottom most node
(node with the highest value), `200` node and replace the root node with it. 
Then to rebalance the tree, the **heapify down** operation is performed. This 
operation consists of checking the node under evaluation, `200`, to
see if it is greater than the smallest value of its children. If so, swap
the `200` node with the smallest of the two children, otherwise the
**heapify down** operation is complete because it would be the smallest value
in the tree. This operation is repeated until the terminating condidtion is met.

## Implementation

When visually representing a Heap a tree based structure can be used. In
practice this structure could also be represented with an Array or ArrayList.

Without the `Tree` and `Node` structures and their pointer relationships, the
implementation requires a definition of parent-child relationships which are
represented with simple mathematical equations. 

Focusing on a node, which has an index in the array `i`, the index of the left 
child of this node is located at index `2i + 1` and the right child is located 
at index `2i + 2`.

Parent, Left Child Index

```
2i+1
```

Parent, Right Child Index

```
2i+2
```

To understand how to find the parent's index looking at a node. Algebra can be
applied:

***Note it is important to understand how the programming language handles
integer division***

Left Child or Right Child, Parent Index

```
2i + 1 = p
2i = p - 1
i = (p - 1) / 2
```

## Updating

Updating is not typically an operation to consider while learning about the
data structure however it can be done but requires an additional
data structure to heap improve performance

## Characteristics

1. Self Balancing
2. Can be used for prioritization (e.g., thread scheduling)
3. Fun data structure to implement, but easy to get wrong
