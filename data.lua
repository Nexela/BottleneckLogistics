local normal = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight"])
normal.name = "bottleneck-stoplight-scaled"
for _, dir in pairs(normal.pictures.picture) do
  dir.scale = .3
end

local high = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight-high"])
high.name = "bottleneck-stoplight-high-scaled"
for _, dir in pairs(high.pictures.picture) do
  dir.scale = .3
end

data:extend({normal, high})
