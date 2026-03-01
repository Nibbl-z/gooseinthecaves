Player = require "modules.player"
WorldGen = require "modules.worldgen"
require "yan"

world = love.physics.newWorld(0, 2000, true)

local uis = {
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
end

function love.keypressed(key)
    yan:keypressed(key)

    if key == "e" then
        uis.game.inventoryOpen = not uis.game.inventoryOpen
    end
end

function love.draw()
    WorldGen:draw()
    Player:Draw()
    yan:draw()
end