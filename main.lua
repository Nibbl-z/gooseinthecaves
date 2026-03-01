Player = require "modules.player"
WorldGen = require "modules.worldgen"
local Enemy = require "modules.enemy"
require "yan"

world = love.physics.newWorld(0, 2000, true)

uis = {
    game = require "ui.game"
}

enemies = {}

peace = true
gametime = 0

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

    for i = 1, 5 do 
        table.insert(enemies, Enemy:new(love.math.random(0,2000), 0))
    end

    world:setCallbacks(function (fix1, fix2)
        if fix1:getUserData() == "player" and fix2:getUserData() == "enemy" or fix2:getUserData() == "player" and fix1:getUserData() == "enemy" then
            Player:takeDamage()
        end
    end, nil)
end

function love.update(dt)
    gametime = gametime + dt
    world:update(dt)
    Player:Update(dt)
    yan:update(dt)
    for i, v in ipairs(enemies) do
        if v.transparency <= .01 then
            table.remove(enemies, i)
        end
        v:update(dt)
    end
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

    for _, v in ipairs(enemies) do
        v:draw()
    end
    yan:draw()

    love.graphics.setColor(1,1,1,Player.dmgOverlay)
    love.graphics.draw(assets["img/damage_overlay.png"], 0, 0, 0, love.graphics.getWidth() / 800, love.graphics.getHeight() / 600)
    love.graphics.setColor(1,1,1,1)
end
