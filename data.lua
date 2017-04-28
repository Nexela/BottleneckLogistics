local normal = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight"])
normal.name = "bottleneck-stoplight-scaled"
normal.render_layer = "explosion"
for _, dir in pairs(normal.pictures.picture) do
    dir.scale = .45
    dir.shift = {dir.shift[1]-.1, dir.shift[2]+.1}
end

local high = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight-high"])
high.name = "bottleneck-stoplight-high-scaled"
for _, dir in pairs(normal.pictures.picture) do
    dir.scale = .45
    dir.shift = {dir.shift[1]-.1, dir.shift[2]+.1}
end
data.raw["simple-entity-with-force"]["simple-entity-with-force"].render_layer = "explosion"
data:extend({normal, high})
