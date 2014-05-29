# Copyright, 2014, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'hitimes'

class Timers
  # An exclusive, monotonic timeout class.
  class Timeout
    def initialize(duration)
      @duration = duration
      @remaining = true
    end
    
    attr :duration
    attr :remaining
    
    # Yields while time remains for work to be done:
    def while_time_remaining(&block)
      @interval = Hitimes::Interval.new
      @interval.start
      
      while time_remaining?
        yield @remaining
      end
    ensure
      @interval.stop
      @interval = nil
    end
    
    private
    
    def time_remaining?
      @remaining = (@duration - @interval.duration)
    
      return @remaining > 0
    end
  end
end
