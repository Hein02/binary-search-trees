# frozen_string_literal: true

# This class represents a node of the binary tree
class Node
  attr_accessor :key, :left, :right

  def initialize(key = nil)
    @key = key
    @left = nil
    @right = nil
  end
end

# This class represents the binary search tree
class Tree # rubocop:disable Metrics/ClassLength
  def initialize(array)
    sorted_uniq = array.uniq.sort
    @root = build_tree(sorted_uniq, 0, sorted_uniq.size - 1)
  end

  # Insert the node with the given key
  #
  # @param key [Numeric] the key of the node
  # @return [Numeric] the key of the found node if the given key exists in the tree
  # @return [Node] the root node of the tree if key not existed
  def insert(key, root = @root)
    return root.key if key == root.key

    if key < root.key
      return root.left = Node.new(key) if root.left.nil?

      insert(key, root.left)
    else
      return root.right = Node.new(key) if root.right.nil?

      insert(key, root.right)
    end
    root
  end

  # Delete the node with the given key
  #
  # @param [Numeric] the key of the node to be deleted
  # @return [Node] the root node of the tree
  def delete(key)
    @root = delete_recursive(key, @root)
  end

  # Print the tree
  def pretty_print(node = @root, prefix = '', is_left: true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", is_left: false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.key}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", is_left: true) if node.left
  end

  # Find the node of the given key
  #
  # @param [Numeric] the key of the node
  # @return [Node] the node if found
  # @return [Nil] nil if not found
  def find(key, root = @root)
    return if root.nil?
    return root if key == root.key

    key < root.key ? find(key, root.left) : find(key, root.right)
  end

  # Traverse the tree with BFT (iterative)
  #
  # @return [Array<Numeric>] array of the key of each node if no block is given
  # @return [Node] yield each node if block is given
  def level_order_iterative
    queue = [@root]
    nodes = []
    until queue.size.zero?
      current_node = queue.shift
      block_given? ? yield(current_node) : nodes << current_node.key
      queue << current_node.left if current_node.left
      queue << current_node.right if current_node.right
    end
    nodes
  end

  # Traverse the tree with BFT (recursive)
  #
  # @return see (#level_order_iterative)
  def level_order_recursive(queue = [@root], nodes = [], &block)
    return nodes if queue.size.zero?

    current_node = queue.shift
    block_given? ? yield(current_node) : nodes << current_node.key
    queue << current_node.left if current_node.left
    queue << current_node.right if current_node.right
    level_order_recursive(queue, nodes, &block)
  end

  # Traverse the tree with DFT (DLR)
  #
  # @return see (#level_order_iterative)
  def preorder(node = @root, nodes = [], &block)
    return nodes if node.nil?

    block_given? ? yield(node) : nodes << node.key
    preorder(node.left, nodes, &block)
    preorder(node.right, nodes, &block)
  end

  # Traverse the tree with DFT (LDR)
  #
  # @return see (#level_order_iterative)
  def inorder(node = @root, nodes = [], &block)
    return nodes if node.nil?

    inorder(node.left, nodes, &block)
    block_given? ? yield(node) : nodes << node.key
    inorder(node.right, nodes, &block)
  end

  # Traverse the tree with DFT (LRD)
  #
  # @return see (#level_order_iterative)
  def postorder(node = @root, nodes = [], &block)
    return nodes if node.nil?

    postorder(node.left, nodes, &block)
    postorder(node.right, nodes, &block)
    block_given? ? yield(node) : nodes << node.key
  end

  # Return the height of the given node
  #
  # @param [Node] the given node
  # @return [Numeric] the number of edges in longest path from a given node to a leaf node.
  def height(node, count = -1)
    return count if node.nil?

    count += 1
    [height(node.left, count), height(node.right, count)].max
  end

  # Return the depth of the given node
  #
  # @param node [Node] the given node
  # @return [Numeric] the number of edges in path from a given node to the tree’s root node
  def depth(node, root = @root, count = 0)
    return count if node.key == root.key

    count += 1
    return depth(node, root.left, count) if node.key < root.key
    return depth(node, root.right, count) if node.key > root.key
  end

  # Check whether the tree is balanced or not
  #
  # @return false if the difference between heights of left subtree and right subtree of a node is more than 1
  # @return true if there is no more node and the difference is less than or equal to 1
  def balanced?(root = @root)
    return true if root.nil?

    left = height(root.left, 0)
    right = height(root.right, 0)
    return false if (left - right).abs > 1

    balanced?(root.left)
    balanced?(root.right)
  end

  # Rebalance the tree
  #
  # @return [Node] the root node of the tree
  def rebalance
    sorted_array = inorder
    @root = build_tree(sorted_array, 0, sorted_array.size - 1)
  end

  private

  # Build a binary tree
  #
  # @param array [Array] sorted array with no duplicate
  # @param start_point [Numeric] index of the first element of the array
  # @param end_point [Numeric] index of the last element of the array
  # @return [Node] the root node of the tree
  def build_tree(array, start_point, end_point)
    return if start_point > end_point

    mid_point = (start_point + end_point) / 2
    root = Node.new(array[mid_point])
    root.left = build_tree(array, start_point, mid_point - 1)
    root.right = build_tree(array, mid_point + 1, end_point)
    root
  end

  # Remove the node of the given key from the given root and return the sub-tree
  #
  # @param key [Numeric] the key of the node to be deleted
  # @param root [Node] the starting node
  # @return [Tree] the sub-tree of the deleted node
  def delete_recursive(key, root) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    return root if root.nil?

    if key < root.key
      root.left = delete_recursive(key, root.left)
    elsif key > root.key
      root.right = delete_recursive(key, root.right)
    else
      return root.right if root.left.nil?
      return root.left if root.right.nil?

      root.key = smallest(root.right)
      root.right = delete_recursive(root.key, root.right)
    end

    root
  end

  # Find the smallest key from the sub-tree of the given node
  #
  # @param root [Node] the starting node
  # @return [Numeric] the key of the smallest node
  def smallest(root)
    return root.key if root.left.nil?

    smallest(root.left)
  end
end

def sample
  tree = Tree.new((Array.new(15) { rand(1..100) }))
  puts tree.balanced?
  traverse(tree)
  5.times { tree.insert(rand(150..300)) }
  puts tree.balanced?
  tree.rebalance
  puts tree.balanced?
  traverse(tree)
end

def traverse(tree)
  print "Level Order(I): #{tree.level_order_iterative}\n"
  print "Level Order(R): #{tree.level_order_recursive}\n"
  print "Preorder: #{tree.preorder}\n"
  print "Inorder:#{tree.inorder}\n"
  print "Postorder: #{tree.postorder}\n"
end

sample
