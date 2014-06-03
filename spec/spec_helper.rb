require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'timers'

# Level of accuracy enforced by tests (50ms)
TIMER_QUANTUM = 0.05
