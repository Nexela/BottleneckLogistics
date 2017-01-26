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

local bottleneck_text = table.deepcopy(data.raw["flying-text"]["flying-text"])
bottleneck_text.name = "bottleneck-text"

local key3 = {
  type = "custom-input",
  name = "bottleneck-toggle-text",
  key_sequence = "CONTROL + SHIFT + B",
  consuming = "script-only"
}

data:extend({normal, high, bottleneck_text, key3})
