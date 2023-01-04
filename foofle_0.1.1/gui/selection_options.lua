local guis = require("__flib__.gui")
local tables = require("__flib__.table")
local header = require("gui/header")

local function add_inventory(contents, inventory)
    for item in pairs(inventory.get_contents()) do
        contents[item] = true
    end
end

local function add_fluids(fluids, entity)
    for fluid in pairs(entity.get_fluid_contents()) do
        fluids[fluid] = true
    end
end

local function scan_entities(entities_to_scan)
    local entities = {}
    local contents = {}
    local fluids = {}
    local settings = {}
    local signals = {}
    for _, entity in pairs(entities_to_scan) do
        table.insert(entities, entity)
        if entity.type == "character" then
            add_inventory(contents, entity.get_main_inventory())
        end
        if entity.type == "container" then
            add_inventory(contents, entity.get_inventory(defines.inventory.chest))
        end
        if entity.type == "storage-tank" then
            add_fluids(fluids, entity)
        end
        if entity.type == "pipe" or entity.type == "pipe-to-ground" then
            add_fluids(fluids, entity)
        end
    end

    return {
        entities = entities,
        contents = contents,
        fluids = fluids,
        settings = settings,
        signals = signals,
    }
end

local function build_ui(groups)
    local results = {}

    table.insert(results, {
        type = "label",
        caption = { "foofle.category-contents" }
    })
    table.insert(results, {
        type = "table",
        column_count = 10,
        children = tables.filter(tables.map(groups.contents, function(_, k)
            return {
                type = "sprite-button",
                sprite = "item/" .. k,
                actions = {
                    on_click = { action_type = "goto", type = "item", name = k, sprite = "item/" .. k }
                }
            }
        end), function() return true end, true)
    })

    table.insert(results, {
        type = "label",
        caption = { "foofle.category-fluids" }
    })
    table.insert(results, {
        type = "table",
        column_count = 10,
        children = tables.filter(tables.map(groups.fluids, function(_, k)
            return {
                type = "sprite-button",
                sprite = "fluid/" .. k,
                actions = {
                    on_click = { action_type = "goto", type = "fluid", name = k, sprite = "fluid/" .. k }
                }
            }
        end), function() return true end, true)
    })
    return results
end

local function show_entities(player, entities)
    -- Entities
    -- Contents (inventories, storage, belts, pipes)
    -- Settings (e.g. recipes, signals)
    -- Signals (active signals)
    local result_groups = scan_entities(entities)

    local gui = guis.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header({ "foofle.title-selection" }),
                {
                    type = "scroll-pane",
                    style = "flib_naked_scroll_pane_no_padding",
                    -- vertical_scroll_policy = "always",
                    -- style_mods = {width = 650, height = 400, padding = 6},
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            children = build_ui(result_groups)
                        },
                    }
                }
            }
        }
    })
    gui.titlebar.drag_target = gui.window
    gui.window.force_auto_center()
end

return {
    show_entities = show_entities
}