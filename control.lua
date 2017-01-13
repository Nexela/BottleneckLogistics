MOD = {}
MOD.name = "BottleneckLogistics"
MOD.interface = MOD.name
MOD.events = remote.call("Bottleneck", "get_ids")

--change_signal
--get_signal_position

-- function update.logistic(data)
-- local entity = data.entity
-- local network = entity.logistic_network
-- if network then
-- if entity.request_slot_count > 0 then
-- local satisfied = false
-- -- for _, ent in pairs(network.full_or_satisfied_requesters) do
-- -- if entity==ent then
-- -- satisfied = true
-- -- break
-- -- end
-- -- end
-- if satisfied then
-- change_signal(data, light.green)
-- else
-- change_signal(data, light.yellow)
-- end
-- else
-- change_signal(data, light.green)
-- end
-- else
-- change_signal(data, light.red)
-- end
-- end
--Faster to just change the color than it is to check it first.

local light = {
  off = defines.direction.north,
  green = defines.direction.east,
  red = defines.direction.south,
  yellow = defines.direction.west,
}
local function change_signal(signal, signal_color)
  signal_color = light[signal_color] or "red"
  signal.direction = signal_color
end

-------------------------------------------------------------------------------
--[[Update signals]]

local function update_signal(data)
  local entity = data.entity
  if entity.logistic_network then
    change_signal(data.signal, "green")
  else
    change_signal(data.signal, "red")
  end
end

-------------------------------------------------------------------------------
--[[ Event Actions]]

local function build_signal(event)
  local entity = event.created_entity
  if entity.type == "logistic-container" then
    -- local index, network = find_network(entity)
    local data = {}
    local name = "bottleneck-stoplight"
    data.position = remote.call("Bottleneck", "get_position_for_signal", entity, 0.05)
    data.entity = entity
    data.signal = entity.surface.create_entity{name=name, position=data.position, direction=light.off, force=entity.force}
    global.signals[entity.unit_number] = data
    if global.show_bottlenecks == 1 then
      update_signal(data)
    end
  end
end

local function destroy_signal(event)
  local entity = event.entity
  if entity.type == "logistic-container" then
    local data = global.signals[entity.unit_number]
    if data then
      if data.signal and data.signal.valid then
        data.signal.destroy()
      end
      global.signals[entity.unit_number] = nil
    end
  end
end

local function bottleneck_toggle(event)
  if event.enable then
    global.show_bottlenecks = 1
  else
    global.show_bottlenecks = -1
  end
  global.update_index = nil
end

local function on_tick()
  if global.show_bottlenecks == 1 then
    local signals_per_tick = global.signals_per_tick or 100
    local signals = global.signals
    local index, data = global.update_index

    --check for existing data at index
    if index and signals[index] then
      data = signals[index]
    else
      index, data = next(signals, index)
    end

    local numiter = 0
    while index and (numiter < signals_per_tick) do
      local entity = data.entity
      local signal = data.signal
      if entity.valid and signal.valid then --update if valid
        update_signal(data)
      elseif entity.valid and not signal.valid then --rebuild if signal not valid
        local name = (global.high_contrast and "bottleneck-stoplight-high") or "bottleneck-stoplight"
        signal = entity.surface.create_entity{name=name, position=data.position, direction=light.off, force=entity.force}
        data.signal = signal
      elseif not entity.valid and signal.valid then --remove if neither are valid
        signal.destroy()
        signals[index] = nil
      end

      numiter = numiter + 1
      index, data = next(signals, index)
    end
    global.update_index = index

  elseif global.show_bottlenecks < 0 then
    local show, signals_per_tick = global.show_bottlenecks, global.signals_per_tick or 100
    local signals = global.signals
    local index, data = global.update_index

    --Check for existing index and associated data
    if index and signals[index] then
      data = signals[index]
    else
      index, data = next(signals, index)
    end

    local numiter = 0
    while index and (numiter < signals_per_tick) do
      local entity = data.entity
      local signal = data.signal

      if entity.valid and signal.valid then
        if show == -1 then
          change_signal(signal, "off")
        elseif show == -2 then
          local name = (global.high_contrast and "bottleneck-stoplight-high") or "bottleneck-stoplight"
          local signal2 = signal.surface.create_entity{name=name, position=data.position, direction=signal.direction, force=signal.force}
          signal.destroy()
          data.signal = signal2
        end
      elseif entity.valid and not signal.valid then
        local name = (global.high_contrast and "bottleneck-stoplight-high") or "bottleneck-stoplight"
        signal = entity.surface.create_entity{name=name, position=data.position, direction=light.off, force=entity.force}
        data.signal = signal
      elseif not entity.valid and signal.valid then
        signal.destroy()
        signals[index] = nil
      end

      numiter = numiter + 1
      index, data = next(signals, index)
    end
    global.update_index = index
    -- if we have reached the end of the list (i.e., have removed all lights),
    -- pause updating until enabled by hotkey next
    if not index then
      global.show_bottlenecks = (show == -2 and 1) or (show == -1 and 0)
    end
  end
end

local function rebuild_signals()
  log(MOD.name..": Rebuilding signals")
  for _, surface in pairs(game.surfaces) do
    --[[Find all logistic-chests within the bounds, and pretend that they were just built]]--
    for _, am in pairs(surface.find_entities_filtered{type="logistic-container"}) do
      build_signal({created_entity = am})
    end
  end
end

-------------------------------------------------------------------------------
--[[Bootstrap]]

local function on_init()
  global = {}
  global.networks = {}
  global.signals = {}
  global.show_bottlenecks = 1
  global.signals_per_tick = 100
  global.high_contrast = false
  global.update_index = nil
end
local function on_configuration_changed(data) --luacheck: ignore data
  --rebuild_signals()
end

--[[ Setup event handlers]]--
script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
local events = MOD.events
local remove_events = {defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}
local add_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}

script.on_event(defines.events.on_tick, on_tick)
script.on_event(remove_events,destroy_signal)
script.on_event(add_events, build_signal)
script.on_event(events.rebuild_overlays, rebuild_signals)
script.on_event(events.bottleneck_toggle, bottleneck_toggle)

--[[ Setup remote interface]]--
local interface = {}
--print the global to a file
interface.print_global = function() game.write_file("logs/"..MOD.name.."/global.lua", serpent.block(global, {comment=false}),false) end
--signals to check per tick
interface.signals_per_tick = function(count) global.signals_per_tick = tonumber(count) or 100 end
remote.add_interface(MOD.interface, interface)
