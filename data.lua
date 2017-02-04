--Quick to use empty sprite
local Proto = {}
Proto.empty_sprite ={
    filename = "__Bottleneck__/graphics/off.png",
    priority = "extra-high",
    width = 1,
    height = 1
}

--Quick to use empty animation
Proto.empty_animation = {
    filename = Proto.empty_sprite.filename,
    width = Proto.empty_sprite.width,
    height = Proto.empty_sprite.height,
    line_length = 1,
    frame_count = 1,
    shift = { 0, 0},
    animation_speed = 0
}

local normal = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight"])
normal.name = "bottleneck-stoplight-scaled"
for _, dir in pairs(normal.pictures.picture) do
    dir.scale = .3
    dir.shift = {-0.5, -0.15}
end

local high = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight-high"])
high.name = "bottleneck-stoplight-high-scaled"
for _, dir in pairs(high.pictures.picture) do
    dir.scale = .3
    dir.shift = {-0.5, -0.15}
end

local bottleneck_text = table.deepcopy(data.raw["flying-text"]["flying-text"])
bottleneck_text.name = "bottleneck-text"

local key3 = {
    type = "custom-input",
    name = "bottleneck-toggle-text",
    key_sequence = "CONTROL + SHIFT + B",
    consuming = "script-only"
}

-- local base_map = function(name, x_offset)
-- return {
-- type = "rail-signal",
-- name = name,
-- icon = "__Bottleneck__/graphics/red.png",
-- flags = {"building-direction-8-way", "filter-directions", "not-on-map"},
-- max_health = 0,
-- selectable_in_game = false,
-- animation =
-- {
-- filename = "__BottleneckLogistics__/graphics/percentby5s_vert.png",
-- priority = "extra-high",
-- x = x_offset,
-- width = 32,
-- height = 16,
-- frame_count = 1,
-- direction_count = 8,
-- scale = 1.2
-- },
-- }
-- end
--
-- local map1 = base_map("bn_signals_1", 0)
-- local map2 = base_map("bn_signals_2", 32)
-- local map3 = base_map("bn_signals_3", 64)

local map_base = function (name, x_off, y_off)
    local yt = {
        [1] = y_off,
        [2] = y_off + 16,
        [3] = y_off + 16 + 16,
        [4] = y_off + 16 + 16 +16,
    }

    local picture = function (filename, x_offset, y_offset)
        return {
            filename = filename,
            priority = "extra-high",
            x = x_offset,
            y = y_offset,
            width = 32,
            height = 16,
            scale = .8,
            frame_count = 1,
            shift = {0.0, 0.0}
        }
    end
    return {
        type = "storage-tank",
        name = name,
        icon = "__Bottleneck__/graphics/red.png",
        max_health = 0,
        selectable_in_game = false,
        collision_mask = {"floor-layer"},
        fluid_box = {
            base_area = 0,
            pipe_covers = nil,
            pipe_connections = {},
        },
        window_bounding_box = {{-0.0,-0.0}, {0.0, 0.0}},
        pictures = {
            picture = {
                north = picture("__BottleneckLogistics__/graphics/percentby5s_vert.png", x_off, yt[1]),
                east = picture("__BottleneckLogistics__/graphics/percentby5s_vert.png", x_off, yt[2]),
                south = picture("__BottleneckLogistics__/graphics/percentby5s_vert.png", x_off, yt[3]),
                west = picture("__BottleneckLogistics__/graphics/percentby5s_vert.png", x_off, yt[4]),
            },
            fluid_background = Proto.empty_sprite,
            window_background = Proto.empty_sprite,
            flow_sprite = Proto.empty_sprite,
        },
        flow_length_in_ticks = 360,
        vehicle_impact_sound = nil,
        working_sound = nil,
    }
end

local map1 = map_base("bn_percents_1", 0, 0)
local map2 = map_base("bn_percents_2", 0, 16 * 4)
local map3 = map_base("bn_percents_3", 32, 0)
local map4 = map_base("bn_percents_4", 32, 16 * 4)
local map5 = map_base("bn_percents_5", 64, 0)
local map6 = map_base("bn_percents_6", 64, 16 * 4)

data:extend({normal, high, bottleneck_text, key3, map1, map2, map3, map4, map5, map6})
