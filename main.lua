Player = require "modules.player"
WorldGen = require "modules.worldgen"
require "perlin"

world = love.physics.newWorld(0, 2000, true)

function love.mousepressed(_, _, button)
    Player:mousepressed(button)
end

function love.load()
    perlin:init()
    biribiri:LoadSprites("img")
    WorldGen:generate()

    Player:Init(world)
end

function love.update(dt)
    world:update(dt)
    Player:Update(dt)
    yan:update(dt)
end

function love.draw()
    WorldGen:draw()
    Player:Draw()
end