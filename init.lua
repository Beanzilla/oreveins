
oreveins = {}

oreveins.S = minetest.get_translator("oreveins")
oreveins.MODPATH = minetest.get_modpath("oreveins")

dofile(oreveins.MODPATH.."/settings.lua")
dofile(oreveins.MODPATH.."/tool_belt.lua")

-- This attempts to detect the gamemode
if not minetest.registered_nodes["default:stone"] then
    if not minetest.registered_nodes["mcl_core:stone"] then
        oreveins.GAMEMODE = "N/A"
    else
        -- Attempt to determine if it's MCL5 or MCL2
        if not minetest.registered_nodes["mcl_deepslate:deepslate"] then
            oreveins.GAMEMODE = "MCL2"
        else
            oreveins.GAMEMODE = "MCL5"
        end
    end
else
    oreveins.GAMEMODE = "MTG"
end

oreveins.tools.log("Gamemode: "..oreveins.GAMEMODE)

-- If item_replicators is avalible do we block replicating oreveins?
oreveins.ir = nil
if minetest.get_modpath("item_replicators") ~= nil then
    local ir = rawget(_G, "item_replicators") or nil
    if ir then
        oreveins.ir = ir
    end
end

dofile(oreveins.MODPATH.."/register.lua")

-- Now register the ores
if oreveins.GAMEMODE == "MTG" then
    oreveins.register_orevein("default:stone_with_coal", 15)
    oreveins.register_orevein("default:stone_with_iron", 35)
    oreveins.register_orevein("default:stone_with_copper", 35)
    oreveins.register_orevein("default:stone_with_tin", 35)
    oreveins.register_orevein("default:stone_with_gold", 35)
    oreveins.register_orevein("default:stone_with_mese", 45)
    oreveins.register_orevein("default:stone_with_diamond", 60)
    if minetest.get_modpath("technic") ~= nil then
        oreveins.register_orevein("technic:mineral_zinc", 45)
        oreveins.register_orevein("technic:mineral_lead", 45)
        oreveins.register_orevein("technic:mineral_chromium", 60)
        oreveins.register_orevein("technic:mineral_uranium", 70)
        oreveins.register_orevein("technic:mineral_sulfur", 70)
    end
    if minetest.get_modpath("moreores") ~= nil then
        oreveins.register_orevein("moreores:mineral_silver", 45)
        oreveins.register_orevein("moreores:mineral_mithril", 50)
        oreveins.register_orevein("moreores:mineral_tin", 45)
    end
elseif oreveins.GAMEMODE == "MCL5" or oreveins.GAMEMODE == "MCL2" then
    oreveins.register_orevein("mcl_core:stone_with_coal", 15)
    oreveins.register_orevein("mcl_core:stone_with_iron", 35) -- In MCL2 iron ore drops itself, thus in MCL2 the orevein is actually quite cheap
    oreveins.register_orevein("mcl_core:stone_with_gold", 35) -- In MCL2 gold ore drops itself, thus in MCL2 the orevein is actually quite cheap
    oreveins.register_orevein("mcl_core:stone_with_lapis", 45)
    oreveins.register_orevein("mcl_core:stone_with_redstone", 45)
    oreveins.register_orevein("mcl_core:stone_with_diamond", 60)
    oreveins.register_orevein("mcl_core:stone_with_emerald", 60)
end
