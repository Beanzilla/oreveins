
-- Places a node within a 3x3x3 around the main node
local make_ore = function (pos, elapsed)
    local meta = minetest.get_meta(pos)
    local ore = meta:get_string("product")
    
    -- local a = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}
    -- local b = {x = pos.x, y = pos.y - 1, z = pos.z - 1}
    -- local c = {x = pos.x + 1, y = pos.y - 1, z = pos.z - 1}
    local positons = {}
    -- Bottom 9
    table.insert(positons, vector.subtract(pos, vector.new(-1, 1, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(0, 1, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(1, 1, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(-1, 1, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(0, 1, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(1, 1, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(-1, 1, 1)))
    table.insert(positons, vector.subtract(pos, vector.new(0, 1, 1)))
    table.insert(positons, vector.subtract(pos, vector.new(1, 1, 1)))

    -- Center 8
    table.insert(positons, vector.subtract(pos, vector.new(-1, 0, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(0, 0, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(1, 0, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(-1, 0, 0)))
    -- table.insert(positons, vector.subtract(pos, vector.new(0, 0, 0))) -- Since this one is obviously pos, which is us
    table.insert(positons, vector.subtract(pos, vector.new(1, 0, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(-1, 0, 1)))
    table.insert(positons, vector.subtract(pos, vector.new(0, 0, 1)))
    table.insert(positons, vector.subtract(pos, vector.new(1, 0, 1)))

    -- Top 9
    table.insert(positons, vector.subtract(pos, vector.new(-1, -1, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(0, -1, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(1, -1, -1)))
    table.insert(positons, vector.subtract(pos, vector.new(-1, -1, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(0, -1, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(1, -1, 0)))
    table.insert(positons, vector.subtract(pos, vector.new(-1, -1, 1)))
    table.insert(positons, vector.subtract(pos, vector.new(0, -1, 1)))
    table.insert(positons, vector.subtract(pos, vector.new(1, -1, 1)))

    -- Iterate over all positions finding a position which is air/empty
    for indx, sec in pairs(positons) do
        local node = minetest.get_node_or_nil(sec)
        local name = "nil"
        if node ~= nil then
            name = node.name
        end
        if oreveins.log_debug then
            oreveins.tools.log(""..tostring(indx).." "..minetest.pos_to_string(sec, 1).." "..name)
        end
        if name == "air" then
            if oreveins.log_debug then
                oreveins.tools.log("I built a "..ore.." here.")
            end
            minetest.swap_node(sec, {name = ore})
            return true
        end
    end
    return true -- Keep the nodetimer going
end

-- Now we use all this to make our machine
local grouping = nil
local sounding = nil
if oreveins.GAMEMODE == "MCL2" or oreveins.GAMEMODE == "MCL5" then
    local mcl_sounds = rawget(_G, "mcl_sounds") or oreveins.tools.error("Failed obtaining mcl_sounds")
    grouping = {handy=3}
    sounding = mcl_sounds.node_sound_metal_defaults()
elseif oreveins.GAMEMODE == "MTG" then
    local default = rawget(_G, "default") or oreveins.tools.error("Failed obtaining default for sounds")
    grouping = {crumbly = 3}
    sounding = default.node_sound_metal_defaults()
else
    grouping = {crumbly = 3, handy=3}
end

-- Registers a node which passively produces ores (Returns if successful)
oreveins.register_orevein = function (itemstring, maxtime)
    if minetest.registered_nodes[itemstring] == nil then
        oreveins.tools.log("Invalid node "..itemstring.." for creating orevein.")
        return false
    end
    local itemstring_split = oreveins.tools.split(itemstring, ":")
    local from_mod = itemstring_split[1]
    local item = itemstring_split[2]
    local item_split = oreveins.tools.split(item, "_")
    local name = "ore"
    name = item_split[ #item_split ]
    name = oreveins.tools.firstToUpper(name)
    local texts = ItemStack(itemstring.." 1"):get_definition().tiles[1] or oreveins.tools.error("Failed obtaining texture of "..itemstring)
    minetest.register_node("oreveins:"..item, {
        short_description = name.." Vein",
        description = name.." Vein\n"..itemstring,
        _doc_items_long_desc = oreveins.S("Oreveins produce ores over a period of time, this allows the world to remain more or less untouched, since oreveins produce an unlimited amount"),
        _dock_items_usagehelp = oreveins.S("Place a node on the ground, place a orevein on top of that block then remove that block (under the orevein), wait till it produces. keep nodes away from the orevein to allow placeing ores there"),
        _dock_items_hidden=false,
        tiles = {
            texts.."^oreveins_overlay.png"
        },
        groups = grouping,
        sounds = sounding,
        paramtype2 = "facedir",
        light_source = 1,
        drop = "oreveins:"..item,
        on_construct = function (pos)
            local meta = minetest.get_meta(pos)
            meta:set_string("product", itemstring)
            meta:set_int("max_time", maxtime)
        end,
        after_place_node = function (pos, placer, itemstack)
            local meta = minetest.get_meta(pos)
            local timer = minetest.get_node_timer(pos)
            timer:start(meta:get_int("max_time"))
        end,
        on_timer = function (pos, elapsed)
            return make_ore(pos, elapsed)
        end
    })
    if oreveins.ir ~= nil and oreveins.blacklist_replication then
        oreveins.ir.bl_add("oreveins:"..item)
    end
    if oreveins.craftable then
        minetest.register_craft({
            output = "oreveins:"..item.." 1",
            recipe = {
                {itemstring, itemstring, itemstring},
                {itemstring, itemstring, itemstring},
                {itemstring, itemstring, itemstring}
            }
        })
    end
    minetest.register_craft({
        type = "fuel",
        recipe = "oreveins:"..item,
        burntime = 600 -- 10 minutes
    })
    return true
end
