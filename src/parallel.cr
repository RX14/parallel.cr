require "./pchan"

module Parallel
  VERSION = "0.1.0"
end

def pspawn
  Process.fork { yield }
end
