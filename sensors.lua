lpeg = require "lpeg"
inspect = require "inspect"

locale = lpeg.locale()
space = locale.space

config = lpeg.V"config"
device = lpeg.V"device"
position = lpeg.V"position"
when = lpeg.V"when"
status = lpeg.V"status"
time = lpeg.V"time"

function parse (device, position, when, status)
  return {
    device = device,
    position = position,
    when = when,
    status = status
  }
end

function parseTime( from, to )
  return { from = from, to = to }
end

function parsePosition(list)
  return list[1] or "any"
end

grammar = lpeg.P{
  [1] = config,
  config = device * ( lpeg.Ct(position^0) / parsePosition ) * when * status * space^0 / parse,
  device = lpeg.C( lpeg.P("camera") + lpeg.P("sensor") + lpeg.P("lights") ) * space^0,
  position = lpeg.C(lpeg.R("19") * lpeg.R("09")^0) * space^0,
  when =  ( lpeg.C( lpeg.P("always") + lpeg.P("never") ) + lpeg.P("from") * space^0 * time * lpeg.P("to") * space^0 * time / parseTime ) * space^0,
  time = lpeg.C( ( lpeg.P("10") + lpeg.P("11") + lpeg.P("12") + lpeg.R("19") ) * ( lpeg.P("am") + lpeg.P("pm") ) ) * space^0,
  status = lpeg.C(lpeg.P("off") + lpeg.P("on")) * space^0
}

for line in io.lines("sensors.config") do
  configuration = grammar:match(line)
  print(inspect(configuration))
  -- do something with configuration table ...
end
