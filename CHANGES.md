3.0.1 (2013-06-27)
------------------
* Require 'set' automatically

3.0.0 (2013-06-14)
------------------
* Refactor `Timers` class into `Timers::Group`
* Add `Timers::Timeout` class for implementing timeouts
* Fix timer fudging
* Update to RSpec 3

2.0.0 (2013-12-30)
------------------
* Switch to Hitimes for high precision monotonic counters
* Removed Timers#time. Replaced with Timers#current_offset which provides a
  monotonic time counter.

1.1.0
-----
* Timers#after_milliseconds and #after_ms for waiting in milliseconds

1.0.2
-----
* Handle overdue timers correctly

1.0.1
-----
* Explicitly require Forwardable from stdlib

1.0.0
-----
* Initial release
