
-- Places a node within a 3x3x3 around the main node
local make_ore = function (pos, elapsed)
    local meta = minetest.get_meta(pos)
    --oreveins.tools.log("make_ore "..minetest.serialize(oreveins._internal.oreos[meta:get_string("id")]))
    local ore = oreveins._internal.oreos[meta:get_string("id")]["nodes"][math.random(#oreveins._internal.oreos[meta:get_string("id")]["nodes"])]
    local size = meta:get_int("size")
    meta:set_int("time", 0) -- Reset internal time

    local pos_add = vector.add(pos, vector.new(size, size, size))
    local pos_sub = vector.subtract(pos, vector.new(size, size, size))

    local air_nodes = minetest.find_nodes_in_area(pos_add, pos_sub, {"air"}, true)
    if air_nodes == nil then return true end -- It's empty so let's treat it like we've already placed a node.

    air_nodes = air_nodes["air"]
    --oreveins.tools.log("find_nodes_in_area found "..minetest.serialize(air_nodes))

    -- Iterate over all positions finding a position which is air/empty
    for indx, sec in pairs(air_nodes) do
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
    grouping = {handy=1, axey=1, pickaxey=1, shovely=1}
    sounding = mcl_sounds.node_sound_metal_defaults()
elseif oreveins.GAMEMODE == "MTG" then
    local default = rawget(_G, "default") or oreveins.tools.error("Failed obtaining default for sounds")
    grouping = {oddly_breakable_by_hand = 1}
    sounding = default.node_sound_metal_defaults()
else
    grouping = {oddly_breakable_by_hand = 1, handy=1, axey=1, pickaxey=1, shovely=1}
end

-- Registers a node which passively produces ores (Returns if successful)
oreveins.make_orevein = function (id, use_id_as_name)
    if oreveins._internal.oreos[id] == nil then
        oreveins.tools.log("Invalid node "..itemstring.." for creating orevein.")
        return false
    end
    local itemstring = oreveins._internal.oreos[id]["nodes"][1]
    local itemstring_split = oreveins.tools.split(itemstring, ":")
    local from_mod = itemstring_split[1]
    local item = itemstring_split[2]
    local item_split = oreveins.tools.split(item, "_")
    local name = "ore"
    name = item_split[ #item_split ]
    if use_id_as_name ~= nil then
        name = id
    end
    name = oreveins.tools.firstToUpper(name)
    local texts = ItemStack(itemstring.." 1"):get_definition().tiles[1] or oreveins.tools.error("Failed obtaining texture of "..itemstring)
    minetest.register_node("oreveins:"..id, {
        short_description = name.." Vein",
        description = name.." Vein\n"
            .."Produces: "..tostring(#oreveins._internal.oreos[id]["nodes"]).." nodes\n"
            .."Size: "..tostring(oreveins._internal.oreos[id]["size"]).." cubed\n"
            .."Speed: "..tostring(oreveins._internal.oreos[id]["speed"]).." seconds",
        _doc_items_long_desc = oreveins.S("Oreveins produce ores over a period of time, this allows the world to remain more or less untouched, since oreveins produce an unlimited amount"),
        _doc_items_usagehelp = oreveins.S("Place a node on the ground, place a orevein on top of that block then remove that block (under the orevein), wait till it produces. keep nodes away from the orevein to allow placeing ores there"),
        _doc_items_hidden=false,
        tiles = {
            texts.."^oreveins_overlay.png"
        },
        groups = grouping,
        -- Ah MCL uses extra stuff
        _mcl_blast_resistance = 2,
		_mcl_hardness = 2,
        sounds = sounding,
        paramtype2 = "facedir",
        light_source = 1,
        drop = "oreveins:"..item,
        on_construct = function (pos)
            local meta = minetest.get_meta(pos)
            meta:set_string("id", id)
            meta:set_string("product", itemstring)
            meta:set_int("max_time", oreveins._internal.oreos[id]["speed"])
            meta:set_int("time", 0)
            meta:set_int("size", oreveins._internal.oreos[id]["size"])
            meta:set_string("infotext", name.." Vein ("..tostring(maxtime)..")")
        end,
        after_place_node = function (pos, placer, itemstack)
            local meta = minetest.get_meta(pos)
            local timer = minetest.get_node_timer(pos)
            timer:start(1)
        end,
        on_timer = function (pos, elapsed)
            local meta = minetest.get_meta(pos)
            meta:set_string("infotext", name.." Vein ("..tostring(meta:get_int("max_time")-meta:get_int("time"))..")")
            if(meta:get_int("time")+1 > meta:get_int("max_time")) then
                return make_ore(pos, elapsed)
            end
            meta:set_int("time", meta:get_int("time")+1)
            return true
        end
    })
    if oreveins.ir ~= nil and oreveins.blacklist_replication then
        oreveins.ir.bl_add("oreveins:"..id)
    end
    --[[if oreveins.craftable then
        minetest.register_craft({
            output = "oreveins:"..item.." 1",
            recipe = {
                {itemstring, itemstring, itemstring},
                {itemstring, itemstring, itemstring},
                {itemstring, itemstring, itemstring}
            }
        })
    end]]
    minetest.register_craft({
        type = "fuel",
        recipe = "oreveins:"..item,
        burntime = 600 -- 10 minutes
    })
    return true
end

-- Calls make_orevein for each vein id in _internals
oreveins.make_veins = function()
    local oreos = oreveins._internal.oreos
    local mades = 0
    oreveins.tools.log(minetest.serialize(oreos))
    for idx, cookie in pairs(oreos) do
        oreveins.tools.log("I want a "..idx)
        if idx ~= "orepack" then
            oreveins.make_orevein(idx, false)
            mades = mades + 1
        else
            oreveins.make_orevein(idx, true)
            mades = mades + 1
        end
    end
    oreveins.tools.log("Made "..tostring(mades).." oreveins.")
end
