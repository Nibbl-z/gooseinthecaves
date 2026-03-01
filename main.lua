Player = require "modules.player"
WorldGen = require "modules.worldgen"
require "yan"

world = love.physics.newWorld(0, 2000, true)

uis = {
    game = require "ui.game"
}

function love.mousepressed(_, _, button)
    Player:mousepressed(button)
end

function love.load()
    biribiri:LoadSprites("img")
    WorldGen:generate()

    Player:Init(world)

    for _, v in pairs(uis) do
        v:init()
    end
end

function love.update(dt)
    world:update(dt)
    Player:Update(dt)
    yan:update(dt)
    biribiri:Update(dt)
end

function love.keypressed(key)
    yan:keypressed(key)

    if key == "e" then
        uis.game.inventoryOpen = not uis.game.inventoryOpen
        uis.game.upgradesOpen = false
    end

    if key == "r" then
        uis.game.upgradesOpen = not uis.game.upgradesOpen
        uis.game.inventoryOpen = false
    end

    if key == "1" then
        Player.equipped = 1
    end

    if key == "2" then
        Player.equipped = 2
    end
end

function love.draw()
    WorldGen:draw()
    Player:Draw()
    yan:draw()
end
