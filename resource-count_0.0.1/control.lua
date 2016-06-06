require "defines"

script.on_init(function()
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

script.on_event(defines.events.on_tick, function(event)
    if event.tick % 10 ~= 0 then
        return
    end
    for index, player in ipairs(game.players) do
        showResourceCount(player)
    end
end)

function showResourceCount(player)
    if (player.selected == nil) or (player.selected.prototype.type ~= "resource") then
        player.gui.top.resource_total.caption = ""
        return
    end
    local resources = floodFindResources(player.selected)
    local count = sumResources(resources)
    player.gui.top.resource_total.caption = player.selected.name .. ": " .. count.total .. " in " .. count.count .. " tiles"
end

function initPlayers()
    for _, player in ipairs(game.players) do
        initPlayer(player)
    end
end

function playerCreated(event)
    local player = game.players[event.player_index]
    initPlayer(player)
end

function initPlayer(player)
    player.gui.top.add{type="label", name="resource_total", caption=""}
end

function sumResources(resources)
    local total = 0
    local count = 0
    for key, resource in pairs(resources) do
        total = total + resource.amount
        count = count + 1
    end
    return {total = total, count = count}
end

function floodFindResources(entity)
    local found = {}
    floodCount(found, entity)
    return found
end

function floodCount(found, entity)
    local name = entity.name
    local pos = entity.position
    local key = pos.x .. "," .. pos.y
    if found[key] then
        return
    end
    found[key] = entity
    
    local RANGE = 2.2
    local surface = entity.surface
    local area = {{pos.x - RANGE, pos.y - RANGE}, {pos.x + RANGE, pos.y + RANGE}}
    for _, res in pairs(surface.find_entities_filtered { area = area, name = entity.name}) do
        local key2 = res.position.x .. "," .. res.position.y
        if not found[key2] then
            floodCount(found, res)
        end
    end
end
