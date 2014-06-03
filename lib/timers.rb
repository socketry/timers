
# Workaround for thread safety issues in SortedSet initialization
# See: https://github.com/celluloid/timers/issues/20
SortedSet.new

require 'timers/version'

require 'timers/group'
require 'timers/timeout'
