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
difficulty = 1

function love.mousepressed(_, _, button)
    Player:mousepressed(button)
end

local function spawnEnemy()
    if not peace then
        local x = Player.body:getX() + love.math.random(300,500) * (love.math.random(1,2) == 1 and 1 or -1)
        local y = Player.body:getY() - 50
    
        table.insert(enemies, Enemy:new(x,y))
    end

    biribiri:CreateAndStartTimer(love.math.random(20,50)/ (10 + difficulty * 2), spawnEnemy)
end

function reset()
    peace = true
    gametime = 0
    difficulty = 1

    for _, v in ipairs(enemies) do
        v.dead = true
        v:destroy()
    end

    table.clear(enemies)

    table.clear(WorldGen.ores)
    table.clear(WorldGen.water)

    for _, v in ipairs(WorldGen.world) do
        v.body:destroy()
    end

     for _, v in ipairs(WorldGen.worldOthers) do
        v.body:destroy()
    end


    table.clear(WorldGen.world)
    table.clear(WorldGen.worldOthers)

    WorldGen:generate()
    print("RESETTING THE PLAYER!!!!!!!!!1")
    Player:reset2()
    local chosenSpawn = WorldGen.world[love.math.random(300, #WorldGen.world - 300)]
    print("OK!!")
    Player.body:setActive(true)
    Player.body:setX(chosenSpawn.x)
    Player.body:setY(chosenSpawn.y)
    Player.camera = Vector2.new(chosenSpawn.x, chosenSpawn.y)
    Player.c = Vector2.new(chosenSpawn.x, chosenSpawn.y)
    Player.body:setActive(true)
end

function love.load()
    biribiri:LoadSprites("img")
    biribiri:LoadAudio("audio", "static")
    WorldGen:generate()

    assets["audio/music.wav"]:setVolume(0.2)
    assets["audio/music.wav"]:setLooping(true)
    assets["audio/music.wav"]:play()

    local chosenSpawn = WorldGen.world[love.math.random(300, #WorldGen.world - 300)]
    Player:Init(world, chosenSpawn.x, chosenSpawn.y)

    for _, v in pairs(uis) do
        v:init()
    end

    world:setCallbacks(function (fix1, fix2)
        if fix1:getUserData() == "player" and fix2:getUserData() == "enemy" or fix2:getUserData() == "player" and fix1:getUserData() == "enemy" then
            Player:takeDamage()
        end
    end, nil)

    spawnEnemy()
end

function love.update(dt)
    gametime = gametime + dt

    if gametime >= 60 then
        gametime = 0
        peace = not peace
        if peace then
            for _, v in ipairs(enemies) do
                v.health = 0
            end
            difficulty = difficulty + 1
        end
    end

    world:update(dt * Player.gamespeed)
    Player:Update(dt)
    yan:update(dt)
    for i, v in ipairs(enemies) do
        if v.transparency <= .01 then
            table.remove(enemies, i)
        end
        v:update(dt * Player.gamespeed)
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

    if Player.health <= 0 and Player.canReset then
        reset()
    end
end

function love.draw()
    for i = -2, 100 do
        for y = -3, 3 do
            love.graphics.draw(assets["img/bg.png"], i * 960 - Player.camera.x / 10, -Player.camera.y / 10 + (y * 960))
        end
    end

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
