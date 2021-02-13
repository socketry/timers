# frozen_string_literal: true

# Copyright, 2021, by Wander Hillen.
# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Timers
	# A priority queue implementation using a standard binary minheap. It uses straight comparison
	# of its contents to determine priority. This works because a Handle from Timers::Events implements
	# the '<' operation by comparing the expiry time.
	# See <https://en.wikipedia.org/wiki/Binary_heap> for explanations of the main methods.
	class PriorityHeap
		def initialize
			# The heap is represented with an array containing a binary tree. See
			# https://en.wikipedia.org/wiki/Binary_heap#Heap_implementation for how this array
			# is built up.
			@contents = []
		end
		
		# Returns the earliest timer or nil if the heap is empty.
		def peek
			@contents[0]
		end
		
		# Returns the number of elements in the heap
		def size
			@contents.size
		end
		
		# Returns the earliest timer if the heap is non-empty and removes it from the heap.
		# Returns nil if the heap is empty. (and doesn't change the heap in that case)
		def pop
			# If the heap is empty:
			if @contents.empty?
				return nil
			end
			
			# If we have only one item, no swapping is required:
			if @contents.size == 1
				return @contents.pop
			end
			
			# Take the root of the tree:
			value = @contents[0]
			
			# Remove the last item in the tree:
			last = @contents.pop
			
			# Overwrite the root of the tree with the item:
			@contents[0] = last
			
			# Bubble it down into place:
			bubble_down(0)
			
			# validate!
			
			return value
		end
		
		# Inserts a new timer into the heap, then rearranges elements until the heap invariant is true again.
		def push(element)
			# Insert the item at the end of the heap:
			@contents.push(element)
			
			# Bubble it up into position:
			bubble_up(@contents.size - 1)
			
			# validate!
			
			return self
		end
		
		private
		
		# Validate the heap invariant.
		def validate!(index = 0)
			if value = @contents[index]
				left_index = index*2 + 1
				if left_value = @contents[left_index]
					unless value < left_value
						raise "Invalid left index from #{index}!"
					end
					
					validate!(left_index)
				end
				
				right_index = left_index + 1
				if right_value = @contents[right_index]
					unless value < right_value
						raise "Invalid right index from #{index}!"
					end
					
					validate!(right_index)
				end
			end
		end
		
		def swap(i, j)
			@contents[i], @contents[j] = @contents[j], @contents[i]
		end
		
		def bubble_up(index)
			parent_index = (index - 1) / 2 # watch out, integer division!
			
			while index > 0 && @contents[index] < @contents[parent_index]
				# if the node has a smaller value than its parent, swap these nodes
				# to uphold the minheap invariant and update the index of the 'current'
				# node. If the node is already at index 0, we can also stop because that
				# is the root of the heap.
				# swap(index, parent_index)
				@contents[index], @contents[parent_index] = @contents[parent_index], @contents[index]
				
				index = parent_index
				parent_index = (index - 1) / 2 # watch out, integer division!
			end
		end
		
		def bubble_down(index)
			swap_value = 0
			swap_index = nil
			
			while true
				left_index = (2 * index) + 1
				left_value = @contents[left_index]
				
				if left_value.nil?
					# This node has no children so it can't bubble down any further.
					# We're done here!
					return
				end
				
				# Determine which of the child nodes has the smallest value:
				right_index = left_index + 1
				right_value = @contents[right_index]
				
				if right_value.nil? or right_value > left_value
					swap_value = left_value
					swap_index = left_index
				else
					swap_value = right_value
					swap_index = right_index
				end
				
				if @contents[index] < swap_value
					# No need to swap, the minheap invariant is already satisfied:
					return
				else
					# At least one of the child node has a smaller value than the current node, swap current node with that child and update current node for if it might need to bubble down even further:
					# swap(index, swap_index)
					@contents[index], @contents[swap_index] = @contents[swap_index], @contents[index]
					
					index = swap_index
				end
			end
		end
	end
end
