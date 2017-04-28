local normal = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight"])
normal.name = "bottleneck-stoplight-scaled"
for _, dir in pairs(normal.pictures.picture) do
    dir.scale = .45
    dir.shift = {dir.shift[1]-.1, dir.shift[2]+.1}
end

local high = table.deepcopy(data.raw["storage-tank"]["bottleneck-stoplight-high"])
high.name = "bottleneck-stoplight-high-scaled"
for _, dir in pairs(high.pictures.picture) do
    dir.scale = .45
    dir.shift = {dir.shift[1]-.1, dir.shift[2]+.1}
end

--Prepare for conversion to simple-entity!
--data.raw["simple-entity-with-force"]["simple-entity-with-force"].render_layer = "explosion"
data:extend({normal, high})
--
-- tile
-- tile-transition
-- resource
-- decorative
-- remnants
-- floor
-- transport-belt-endings
-- corpse
-- floor-mechanics
-- item
-- lower-object
-- object
-- higher-object-above
-- higher-object-under
-- wires
-- lower-radius-visualization
-- radius-visualization
-- entity-info-icon
-- explosion
-- projectile
-- smoke
-- air-object
-- air-entity-info-con
-- light-effect
-- selection-box
-- arrow
-- cursor
