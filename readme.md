# Timers

Collections of one-shot and periodic timers, intended for use with event loops such as [async](https://github.com/socketry/async).

[![Development Status](https://github.com/socketry/timers/workflows/Test/badge.svg)](https://github.com/socketry/timers/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'timers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timers

## Usage

Create a new timer group with `Timers::Group.new`:

``` ruby
require 'timers'

timers = Timers::Group.new
```

Schedule a proc to run after 5 seconds with `Timers::Group#after`:

``` ruby
five_second_timer = timers.after(5) { puts "Take five" }
```

The `five_second_timer` variable is now bound to a Timers::Timer object. To
cancel a timer, use `Timers::Timer#cancel`

Once you've scheduled a timer, you can wait until the next timer fires with `Timers::Group#wait`:

``` ruby
# Waits 5 seconds
timers.wait

# The script will now print "Take five"
```

You can schedule a block to run periodically with `Timers::Group#every`:

``` ruby
every_five_seconds = timers.every(5) { puts "Another 5 seconds" }

loop { timers.wait }
```

You can also schedule a block to run immediately and periodically with `Timers::Group#now_and_every`:

``` ruby
now_and_every_five_seconds = timers.now_and_every(5) { puts "Now and in another 5 seconds" }

loop { timers.wait }
```

If you'd like another method to do the waiting for you, e.g. `Kernel.select`,
you can use `Timers::Group#wait_interval` to obtain the amount of time to wait. When
a timeout is encountered, you can fire all pending timers with `Timers::Group#fire`:

``` ruby
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

``` ruby
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

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
