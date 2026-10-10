local lgi = require("lgi")
local Gio = lgi.Gio
local GioUnix = lgi.require("GioUnix", "2.0")
local GLib = lgi.GLib
local GdkPixbuf = lgi.require("GdkPixbuf", "2.0")
local Gtk = lgi.require("Gtk", "3.0")

local ui = gisland.ui
local MAX_RESULTS = 8
local ICON_SIZE = 28
local applications = {}
local applications_by_action = {}
local icon_cache = {}
local query = ""
local icon_theme
local visibility = "hidden"
local placeholder = "Search applications"
local window_start = 1
local launch_serial = 0
local launch_helper = GLib.build_filenamev({ GLib.get_user_config_dir(), "gisland", "modules",
  "launcher", "launch.lua" })

local function array(values)
  local result = gisland.array()
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function folded(value)
  return GLib.utf8_casefold(value or "", -1)
end

local function discover_applications()
  local found = {}
  for _, info in ipairs(GioUnix.DesktopAppInfo.get_all()) do
    local ok, visible = pcall(function() return info:should_show() end)
    if ok and visible then
      local name = info:get_display_name() or info:get_name()
      if name and name ~= "" then
        local app = {
          info = info,
          name = name,
          display_name = info:get_name() or "",
          description = info:get_description() or "",
          executable = info:get_executable() or "",
          desktop_id = info:get_id() or "",
        }
        app.folded_name = folded(app.name)
        app.folded_search = folded(table.concat({ app.name, app.display_name,
          app.description, app.executable }, " "))
        found[#found + 1] = app
      end
    end
  end
  table.sort(found, function(left, right)
    if left.folded_name == right.folded_name then return left.desktop_id < right.desktop_id end
    return left.folded_name < right.folded_name
  end)
  for index, app in ipairs(found) do
    app.action_id = "launch:" .. tostring(index)
    applications_by_action[app.action_id] = app
  end
  applications = found
end

local function subsequence_penalty(text, needle)
  local position, first, previous, gaps = 1, nil, nil, 0
  for character in needle:gmatch(utf8.charpattern) do
    local found = text:find(character, position, true)
    if not found then return nil end
    first = first or found
    if previous then gaps = gaps + math.max(0, found - previous - 1) end
    previous, position = found, found + #character
  end
  return (first or 1) + gaps
end

local function score(app, needle)
  if needle == "" then return 100 end
  if app.folded_name == needle then return 0 end
  if app.folded_name:sub(1, #needle) == needle then return 10 + #app.folded_name - #needle end
  local word = app.folded_name:find(" " .. needle, 1, true)
  if word then return 100 + word end
  local name_match = app.folded_name:find(needle, 1, true)
  if name_match then return 200 + name_match end
  local metadata_match = app.folded_search:find(needle, 1, true)
  if metadata_match then return 400 + metadata_match end
  local fuzzy = subsequence_penalty(app.folded_name, needle)
  if fuzzy then return 800 + fuzzy end
  return nil
end

local function results()
  local needle = folded(query):match("^%s*(.-)%s*$")
  local matches = {}
  for _, app in ipairs(applications) do
    local rank = score(app, needle)
    if rank then matches[#matches + 1] = { app = app, rank = rank } end
  end
  table.sort(matches, function(left, right)
    if left.rank == right.rank then return left.app.folded_name < right.app.folded_name end
    return left.rank < right.rank
  end)
  return matches
end

local function rgba_image(pixbuf)
  local width, height = math.tointeger(pixbuf:get_width()), math.tointeger(pixbuf:get_height())
  local rowstride, channels = math.tointeger(pixbuf:get_rowstride()), math.tointeger(pixbuf:get_n_channels())
  local has_alpha, source = pixbuf:get_has_alpha(), pixbuf:read_pixel_bytes():get_data()
  local rows = {}
  for y = 0, height - 1 do
    local row = {}
    for x = 0, width - 1 do
      local offset = y * rowstride + x * channels + 1
      row[#row + 1] = string.char(source:byte(offset), source:byte(offset + 1),
        source:byte(offset + 2), has_alpha and source:byte(offset + 3) or 255)
    end
    rows[#rows + 1] = table.concat(row)
  end
  return { width = width, height = height, pixels = table.concat(rows) }
end

local function icon_resource(app)
  local key = app.desktop_id ~= "" and app.desktop_id or app.action_id
  if icon_cache[key] ~= nil then return icon_cache[key] or nil end
  local ok, resource = pcall(function()
    local icon = assert(app.info:get_icon(), "application has no icon")
    local icon_info = assert(icon_theme:lookup_by_gicon(icon, ICON_SIZE, 0), "icon not found")
    local filename = assert(icon_info:get_filename(), "icon has no local file")
    local pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(filename, ICON_SIZE, ICON_SIZE, true)
    local image = rgba_image(pixbuf)
    return { id = "app-icon-" .. app.action_id:sub(8), format = "rgba8", width = image.width,
      height = image.height, data = GLib.base64_encode(image.pixels) }
  end)
  icon_cache[key] = ok and resource or false
  return ok and resource or nil
end

local function result_content(app, resource)
  local children = {}
  if resource then
    children[#children + 1] = ui.image { resource_id = resource.id, role = "launcher-app-icon",
      accessible_label = app.name }
  end
  children[#children + 1] = ui.text { value = app.name, role = "body", truncation = "end" }
  return ui.row { alignment = "center", gap = "normal", children = array(children) }
end

local function publish()
  local children = { ui.text_input { input_id = "application-query", action_id = "query-changed",
    initial_value = "", placeholder = placeholder, accessible_label = placeholder,
    navigation_action_id = "navigate-results" } }
  local resources, matches = {}, results()
  window_start = math.max(1, math.min(window_start, math.max(1, #matches - MAX_RESULTS + 1)))
  for index = window_start, math.min(#matches, window_start + MAX_RESULTS - 1) do
    local match = matches[index]
    local app, resource = match.app, icon_resource(match.app)
    if resource then resources[#resources + 1] = resource end
    children[#children + 1] = ui.button { action_id = app.action_id,
      accessible_label = "Lancer " .. app.name, close_on_activate = true,
      content = result_content(app, resource) }
  end
  if #matches == 0 then
    children[#children + 1] = ui.row { alignment = "center", gap = "small",
      children = array { ui.text { value = "Aucune application trouvée", role = "muted" } } }
  end
  local publication = { context_id = "launcher", priority = 100, activation_only = true,
    views = { expanded = ui.column { alignment = "start", gap = "small", children = array(children) } },
    presentation = { expanded_style = "palette" } }
  if #resources > 0 then publication.resources = array(resources) end
  gisland.publish(publication)
end

local function preferred_action(app)
  for _, action in ipairs(app.info:list_actions()) do
    local lowered = action:lower()
    if lowered == "new" or lowered == "new-window" or lowered == "newwindow" then
      return action
    end
  end
  return "-"
end

local function launch(action_id)
  local app = applications_by_action[action_id]
  if not app then return false, "application inconnue" end
  launch_serial = launch_serial + 1
  local unit = string.format("gisland-launch-%d-%d", GLib.get_monotonic_time(), launch_serial)
  local ok, pid = pcall(function()
    local flags = GLib.SpawnFlags.SEARCH_PATH + GLib.SpawnFlags.DO_NOT_REAP_CHILD +
      GLib.SpawnFlags.STDIN_FROM_DEV_NULL + GLib.SpawnFlags.STDOUT_TO_DEV_NULL +
      GLib.SpawnFlags.STDERR_TO_DEV_NULL
    return GLib.spawn_async(nil, { "systemd-run", "--user", "--scope", "--collect", "--quiet",
      "--unit=" .. unit, "lua5.4", launch_helper, app.desktop_id, preferred_action(app) }, nil,
      flags)
  end)
  if not ok then
    gisland.log("error", "Impossible de lancer " .. app.name .. ": " .. tostring(pid))
    return false, "échec du lancement"
  end
  GLib.child_watch_add(GLib.PRIORITY_DEFAULT, pid, function(child, status)
    GLib.spawn_close_pid(child)
    local exited = pcall(GLib.spawn_check_wait_status, status)
    if not exited then
      gisland.log("error", "Le lanceur détaché de " .. app.name .. " a échoué")
    end
  end)
  return true
end

return gisland.module {
  init = function(config, metadata)
    assert(metadata.protocol_minor == 10)
    placeholder = config.placeholder
    GLib.unsetenv("WAYLAND_DISPLAY")
    GLib.setenv("XDG_SESSION_TYPE", "x11", true)
    icon_theme = Gtk.IconTheme.get_default() or Gtk.IconTheme.new()
    discover_applications()
    gisland.log("info", tostring(#applications) .. " applications disponibles")
    publish()
  end,
  actions = { ["query-changed"] = function(value)
    if type(value) ~= "string" or #value > 1024 then return false, "recherche invalide" end
    query = value
    window_start = 1
    publish()
    return true
  end,
  ["navigate-results"] = function(value)
    if value ~= -1 and value ~= 1 then return false, "navigation invalide" end
    local matches = results()
    if value > 0 and window_start + MAX_RESULTS <= #matches then
      window_start = window_start + 1
    elseif value < 0 and window_start > 1 then
      window_start = window_start - 1
    end
    publish()
    return true
  end },
  visibility = function(state)
    if state == "expanded-active" and visibility ~= "expanded-active" and
        (query ~= "" or window_start ~= 1) then
      query = ""
      window_start = 1
      publish()
    end
    visibility = state
  end,
  fallback_action = launch,
}
