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

	preOrderTraversalPath := Traverse(tree, "pre-order")
	fmt.Printf("pre-order traversal: %s\n", preOrderTraversalPath)
	inOrderTraversalPath := Traverse(tree, "in-order")
	fmt.Printf("in-order traversal: %s\n", inOrderTraversalPath)
	postOrderTraversalPath := Traverse(tree, "post-order")
	fmt.Printf("post-order traversal: %s\n", postOrderTraversalPath)
}
