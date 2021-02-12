# frozen_string_literal: true

module Timers
  # A priority queue implementation using a standard binary minheap. It uses straight comparison
  # of its contents to determine priority. This works because a Handle from Timers::Events implements
  # the '<' operation by comparing the expiry time.

  # See https://en.wikipedia.org/wiki/Binary_heap for explanations of the main methods.

  class PriorityHeap
    def initialize
      # The heap is represented with an array containing a binary tree. See
      # https://en.wikipedia.org/wiki/Binary_heap#Heap_implementation for how this array
      # is built up.
      @contents = []
    end

    # Returns the earliest timer or nil if the heap is empty.
    def first
      @contents[0]
    end

    # Returns the number of elements in the heap
    def size
      @contents.size
    end

    # Returns the earliest timer if the heap is non-empty and removes it from the heap.
    # Returns nil if the heap is empty. (and doesn't change the heap in that case)
    def pop
      return nil if @contents.empty?
      return @contents.pop if @contents.size == 1 # no need to do heap trickery in this case
      min = @contents[0]
      last = @contents.pop
      @contents[0] = last
      bubble_down(0)
      min
    end

    # Inserts a new timer into the heap, then rearranges elements until the heap invariant
    # is true again.
    def insert(element)
      @contents.push(element)
      bubble_up(@contents.size - 1)
      self
    end

    private

    def swap(index1, index2)
      temp = @contents[index1]
      @contents[index1] = @contents[index2]
      @contents[index2] = temp
    end

    def bubble_up(index)
      parent_index = (index - 1) / 2 # watch out, integer division!
      while index > 0 && @contents[index] < @contents[parent_index]
        # if the node has a smaller value than its parent, swap these nodes
        # to uphold the minheap invariant and update the index of the 'current'
        # node. If the node is already at index 0, we can also stop because that
        # is the root of the heap.
        swap(index, parent_index)
        index = parent_index
        parent_index = (index - 1) / 2 # watch out, integer division!
      end
    end

    def bubble_down(index)
      least_valued_child_node = 0
      while(true)
        left_child_index = (2 * index) + 1
        left_child_value = @contents[left_child_index]
        if left_child_value.nil?
          # This node has no children so it can't bubble down any further.
          # We're done here!
          return
        end
        # Determine which of the child nodes has the smallest value
        right_child_index = left_child_index + 1
        right_child_value = @contents[right_child_index]
        if right_child_value.nil?
          # node only has a left child
          least_valued_child_node = left_child_value
          least_valued_child_index = left_child_index
        elsif right_child_value > left_child_value
          least_valued_child_node = left_child_value
          least_valued_child_index = left_child_index
        else
          least_valued_child_node = right_child_value
          least_valued_child_index = right_child_index
        end
        if @contents[index] < least_valued_child_node
          # No need to swap, the minheap invariant is already satisfied.
          return
        else
          # at least one of the child node has a smaller value than the current
          # node, swap current node with that child and update current node for
          # if it might need to bubble down even further.
          swap(index, least_valued_child_index)
          index = least_valued_child_index
        end
      end
    end
  end
end
