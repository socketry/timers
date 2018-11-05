# Timers

Collections of one-shot and periodic timers, intended for use with event loops such as [async].

[![Build Status](https://secure.travis-ci.org/socketry/timers.svg)](https://travis-ci.org/socketry/timers)
[![Code Climate](https://codeclimate.com/github/socketry/timers.svg)](https://codeclimate.com/github/socketry/timers)
[![Coverage Status](https://coveralls.io/repos/socketry/timers/badge.svg)](https://coveralls.io/r/socketry/timers)

[async]: https://github.com/socketry/async

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'timers'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install timers

## Usage

Create a new timer group with `Timers::Group.new`:

```ruby
require 'timers'

timers = Timers::Group.new
```

Schedule a proc to run after 5 seconds with `Timers::Group#after`:

```ruby
five_second_timer = timers.after(5) { puts "Take five" }
```

The `five_second_timer` variable is now bound to a Timers::Timer object. To
cancel a timer, use `Timers::Timer#cancel`

Once you've scheduled a timer, you can wait until the next timer fires with `Timers::Group#wait`:

```ruby
# Waits 5 seconds
timers.wait

# The script will now print "Take five"
```

You can schedule a block to run periodically with `Timers::Group#every`:

```ruby
every_five_seconds = timers.every(5) { puts "Another 5 seconds" }

loop { timers.wait }
```

You can also schedule a block to run immediately and periodically with `Timers::Group#now_and_every`:
```ruby
now_and_every_five_seconds = timers.now_and_every(5) { puts "Now and in another 5 seconds" }

loop { timers.wait }
```

If you'd like another method to do the waiting for you, e.g. `Kernel.select`,
you can use `Timers::Group#wait_interval` to obtain the amount of time to wait. When
a timeout is encountered, you can fire all pending timers with `Timers::Group#fire`:

```ruby
loop do
  interval = timers.wait_interval
  ready_readers, ready_writers = select readers, writers, nil, interval

  if ready_readers || ready_writers
    # Handle IO
    ...
  else
    # Timeout!
    timers.fire
  end
end
```

You can also pause and continue individual timers, or all timers:

```ruby
paused_timer = timers.every(5) { puts "I was paused" }

paused_timer.pause
10.times { timers.wait } # will not fire paused timer

paused_timer.resume
10.times { timers.wait } # will fire timer

timers.pause
10.times { timers.wait } # will not fire any timers

timers.resume
10.times { timers.wait } # will fire all timers
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2018, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).  
Copyright, 2016, by [Tony Arcieri](bascule@gmail.com).  
Copyright, 2016, by Jeremy Hinegardner.  
Copyright, 2016, by Sean Gregory.  
Copyright, 2016, by Chuck Remes.  
Copyright, 2016, by Utenmiki.  
Copyright, 2016, by Ron Evans.  
Copyright, 2016, by Larry Lv.  
Copyright, 2016, by Bruno Enten.  
Copyright, 2016, by Jesse Cooke.  
Copyright, 2016, by Nicholas Evans.  
Copyright, 2016, by Dimitrij Denissenko.  
Copyright, 2016, by Ryan LeCompte.  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
