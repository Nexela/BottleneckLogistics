MOD = {}
MOD.name = "BottleneckLogistics"
MOD.if_name = MOD.name

--[[ Testing Code
/c
SEL=game.player.selected
for i=1, 2000 do
    local ent = SEL.surface.create_entity{
        name="logistic-chest-requester",
        force=SEL.force,
        position=SEL.surface.find_non_colliding_position("logistic-chest-requester", SEL.position, 0, 1)
    }
    game.raise_event(defines.events.on_built_entity, {created_entity=ent, player_index=game.player.index})
end

]]
-------------------------------------------------------------------------------
--[[Update signals]]

local LIGHT

local function color_logistic_input_inventory(point, inv)
    local deliveries = point.targeted_items_deliver
    for _, filter in pairs(point.filters) do
        --game.print(name .. "_" .. (deliveries[name] or "nil"))
        local icount = inv.get_item_count(filter.name)
        if icount + (deliveries[filter.name] or 0) == 0 then
            return "red"
        elseif icount + (deliveries[filter.name] or 0) < math.floor(filter.count * .50) then
            return "yellowmin"
        elseif icount < math.floor(filter.count * .75) then
            return "yellow"
        end
    end
    return "green"
end

local function change_signal(signal, signal_color)
    signal_color = LIGHT[signal_color] or "off"
    signal.graphics_variation = signal_color
end

local function update_signal(data)
    local entity = data.entity
    if entity.logistic_network then
        if entity.prototype.logistic_mode == "requester" then
            local point = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
            if point and point.mode == defines.logistic_mode.requester and point.filters then
                change_signal(data.signal, color_logistic_input_inventory(point, entity.get_inventory(defines.inventory.chest)))
            else
                change_signal(data.signal, "redsmall")
            end
        else
            change_signal(data.signal, "off")
        end
    else
        change_signal(data.signal, "redx")
    end
end

-------------------------------------------------------------------------------
--[[ Event Actions]]

local function build_signal(event)
    local entity = event.created_entity
    if entity.type == "logistic-container" then
        local data = {}
        data.entity = entity
        data.signal = remote.call("Bottleneck", "new_signal", entity)
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

local function on_tick()
    if global.show_bottlenecks == 1 then
        local signals_per_tick = global.signals_per_tick or 5
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
            if entity.valid and data.signal.valid then --update if valid
                update_signal(data)
            elseif entity.valid and not data.signal.valid then --rebuild if signal not valid
                data.signal = remote.call("Bottleneck", "new_signal", entity)
            elseif not entity.valid and data.signal.valid then --remove if neither are valid
                data.signal.destroy()
                signals[index] = nil
            end

            numiter = numiter + 1
            index, data = next(signals, index)
        end
        global.update_index = index

    elseif global.show_bottlenecks < 0 then
        local show, signals_per_tick = global.show_bottlenecks, global.signals_per_tick or 5
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
            --local signal = data.signal

            if entity.valid and data.signal.valid then
                if show == -1 then
                    change_signal(data.signal, "off")
                elseif show == -2 then
                    local current_variation = data.signal.graphics_variation
                    data.signal.destroy()
                    data.signal = remote.call("Bottleneck", "new_signal", entity, current_variation)
                end
            elseif entity.valid and not data.signal.valid then
                data.signal = remote.call("Bottleneck", "new_signal", entity)
            elseif not entity.valid and data.signal.valid then
                data.signal.destroy()
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
    global.signals = {}
    global.update_index = nil
    for _, surface in pairs(game.surfaces) do
        for _, signal in pairs(surface.find_entities_filtered{name = "bottleneck-stoplight"}) do
            signal.destroy()
        end
        --[[Find all logistic-chests within the bounds, and pretend that they were just built]]--
        for _, logistic_chest in pairs(surface.find_entities_filtered{type="logistic-container"}) do
            build_signal({created_entity = logistic_chest})
        end
    end
end

local function update_settings(event)
    if event.setting == "bottleneck-enabled" then
        global.show_bottlenecks = settings.global["bottleneck-enabled"].value and 1 or -1
        global.update_index = nil
    end
end
script.on_event(defines.events.on_runtime_mod_setting_changed, update_settings)

-------------------------------------------------------------------------------
--[[Bootstrap]]
local function run_conditionals()
    LIGHT = remote.call("Bottleneck", "get_lights")
    if remote.interfaces["picker"] and remote.interfaces["picker"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("picker", "dolly_moved_entity_id"),
            function(event)
                remote.call("Bottleneck", "entity_moved", event, global.signals[event.moved_entity.unit_number])
            end
        )
    end
end

local function on_init()
    global = {}
    global.signals = {}
    global.show_bottlenecks = 1
    global.update_index = nil
    run_conditionals()
end
script.on_init(on_init)

local function on_load()
    run_conditionals()
end
script.on_load(on_load)

local function on_configuration_changed()
    global.show_bottlenecks = global.show_bottlenecks or 1
    rebuild_signals()
end
script.on_configuration_changed(on_configuration_changed)

local remove_events = {defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}
local add_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}

script.on_event(defines.events.on_tick, on_tick)
script.on_event(remove_events,destroy_signal)
script.on_event(add_events, build_signal)

--[[ Setup remote interface]]--
local interface = {}
--print the global to a file
interface.print_global = function() game.write_file(MOD.name.."/global.lua", serpent.block(global, {nocode=true, comment=false})) end
interface.rebuild = rebuild_signals
remote.add_interface(MOD.if_name, interface)
