local lgi = require("lgi")
local Gio = lgi.Gio
local GioUnix = lgi.require("GioUnix", "2.0")

local desktop_id, action = ...
if not desktop_id or desktop_id == "" then
  io.stderr:write("desktop application id is missing\n")
  os.exit(2)
end

local info = GioUnix.DesktopAppInfo.new(desktop_id)
if not info then
  io.stderr:write("desktop application is unavailable: " .. desktop_id .. "\n")
  os.exit(3)
end

local context = Gio.AppLaunchContext()
local launched
if action and action ~= "-" then
  info:launch_action(action, context)
  launched = true
else
  launched = info:launch(nil, context)
end

if not launched then
  io.stderr:write("desktop application launch failed: " .. desktop_id .. "\n")
  os.exit(4)
end
