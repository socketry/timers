
# Workaround for thread safety issues in SortedSet initialization
# See: https://github.com/celluloid/timers/issues/20
SortedSet.new

require 'timers/version'

require 'timers/group'
require 'timers/timeout'

module Timers
  # Compatibility
  def self.new
    warn "Timers is no longer a class, please use Timers::Group.new"
    Group.new
  end
end
