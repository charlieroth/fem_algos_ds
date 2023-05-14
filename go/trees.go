package main

import (
	"fmt"
	"strconv"
)

type BinaryTreeNode struct {
	Data  int
	Left  *BinaryTreeNode
	Right *BinaryTreeNode
}

type BinaryTree struct {
	Root *BinaryTreeNode
}

func Walk(curr *BinaryTreeNode, order string, path *string) {
	if curr == nil {
		return
	}

	switch order {
	case "pre-order":
		*path = fmt.Sprintf("%s%s->", *path, strconv.FormatInt(int64(curr.Data), 10))
		Walk(curr.Left, order, path)
		Walk(curr.Right, order, path)
	case "in-order":
		Walk(curr.Left, order, path)
		*path = fmt.Sprintf("%s%s->", *path, strconv.FormatInt(int64(curr.Data), 10))
		Walk(curr.Right, order, path)
	case "post-order":
		Walk(curr.Left, order, path)
		Walk(curr.Right, order, path)
		*path = fmt.Sprintf("%s%s->", *path, strconv.FormatInt(int64(curr.Data), 10))
	default:
		panic("invalid traversal order")
	}
}

func Traverse(tree BinaryTree, order string) string {
	path := ""
	Walk(tree.Root, order, &path)
	return path
}

func Bfs(root *BinaryTreeNode, needle int) bool {
	queue := []*BinaryTreeNode{}
	queue = append(queue, root)
	for len(queue) > 0 {
		// pop the first element, as if FIFO queue
		curr := queue[0]
		queue = queue[1:]

		if curr == nil {
			continue
		}

		if curr.Data == needle {
			return true
		}

		queue = append(queue, curr.Left)
		queue = append(queue, curr.Right)
	}

	return false
}

func Search(curr *BinaryTreeNode, needle int) bool {
	if curr != nil {
		if curr.Data == needle {
			return true
		}

		if curr.Data < needle {
			return Search(curr.Right, needle)
		}

		return Search(curr.Left, needle)
	}

	return false
}

func Dfs(head *BinaryTreeNode, needle int) bool {
	return Search(head, needle)
}

func Compare(a *BinaryTreeNode, b *BinaryTreeNode) bool {
	// Two trees are structural and value equivalent if bottom is reached
	// without returning false prior
	if a == nil && b == nil {
		return true
	}

	// Structural equivalence: Two tress are not equivalent if two of (what
	// are supposed to be the same) nodes, are not the same
	if a == nil || b == nil {
		return false
	}

	// Value equivalence: Two tress are not equivalent if two of (what
	// are supposed to be the same) nodes, are not the same value
	if a.Data != b.Data {
		return false
	}

	return Compare(a.Left, b.Left) && Compare(a.Right, b.Right)
}

func Insert(parent *BinaryTreeNode, curr *BinaryTreeNode, node *BinaryTreeNode) {
	if curr != nil {
		if curr.Data < node.Data {
			Insert(curr, curr.Right, node)
			return
		}

		Insert(curr, curr.Left, node)
		return
	}

	if parent != nil {
		if parent.Data < node.Data {
			parent.Right = node
			return
		}

		parent.Left = node
		return
	}
}

func main() {
	tree := BinaryTree{
		Root: &BinaryTreeNode{
			Data: 10,
			Left: &BinaryTreeNode{
				Data: 5,
				Left: &BinaryTreeNode{
					Data:  4,
					Left:  nil,
					Right: nil,
				},
				Right: nil,
			},
			Right: &BinaryTreeNode{
				Data:  15,
				Left:  nil,
				Right: nil,
			},
		},
	}

	treeB := BinaryTree{
		Root: &BinaryTreeNode{
			Data: 10,
			Left: &BinaryTreeNode{
				Data: 5,
				Left: &BinaryTreeNode{
					Data:  4,
					Left:  nil,
					Right: nil,
				},
				Right: nil,
			},
			Right: &BinaryTreeNode{
				Data:  15,
				Left:  nil,
				Right: nil,
			},
		},
	}

	treeC := BinaryTree{
		Root: &BinaryTreeNode{
			Data: 10,
			Left: &BinaryTreeNode{
				Data: 7,
				Left: &BinaryTreeNode{
					Data:  5,
					Left:  nil,
					Right: nil,
				},
				Right: nil,
			},
			Right: &BinaryTreeNode{
				Data:  15,
				Left:  nil,
				Right: nil,
			},
		},
	}

	// Traversal
	preOrderTraversalPath := Traverse(tree, "pre-order")
	fmt.Printf("pre-order traversal: %s\n", preOrderTraversalPath)
	inOrderTraversalPath := Traverse(tree, "in-order")
	fmt.Printf("in-order traversal: %s\n", inOrderTraversalPath)
	postOrderTraversalPath := Traverse(tree, "post-order")
	fmt.Printf("post-order traversal: %s\n", postOrderTraversalPath)

	// BFS
	needle := 10
	bfsFound := Bfs(tree.Root, needle)
	fmt.Printf("bfs: did find %d in tree? %v\n", needle, bfsFound)
	needle = 42
	bfsFound = Bfs(tree.Root, needle)
	fmt.Printf("bfs: did find %d in tree? %v\n", needle, bfsFound)

	// Comparison
	same := Compare(tree.Root, treeB.Root)
	fmt.Printf("tree and treeB are the same? %v\n", same)
	same = Compare(tree.Root, treeC.Root)
	fmt.Printf("tree and treeC are the same? %v\n", same)

	// Insertion
	fmt.Println("inserting nodes into new tree...")
	treeD := BinaryTree{Root: &BinaryTreeNode{Data: 10}}

	n1 := BinaryTreeNode{Data: 7}
	Insert(nil, treeD.Root, &n1)
	path := Traverse(treeD, "in-order")
	fmt.Printf("path: %s\n", path)

	n2 := BinaryTreeNode{Data: 15}
	Insert(nil, treeD.Root, &n2)
	path = Traverse(treeD, "in-order")
	fmt.Printf("path: %s\n", path)

	n3 := BinaryTreeNode{Data: 3}
	Insert(nil, treeD.Root, &n3)
	path = Traverse(treeD, "in-order")
	fmt.Printf("path: %s\n", path)

	n4 := BinaryTreeNode{Data: 12}
	Insert(nil, treeD.Root, &n4)
	path = Traverse(treeD, "in-order")
	fmt.Printf("path: %s\n", path)

	// DFS
	needle = 3
	dfsFound := Dfs(treeD.Root, needle)
	fmt.Printf("dfs: did find %d in treeD? %v\n", needle, dfsFound)

	needle = 42
	dfsFound = Dfs(treeD.Root, needle)
	fmt.Printf("dfs: did find %d in treeD? %v\n", needle, dfsFound)
}
