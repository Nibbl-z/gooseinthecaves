Player = require "modules.player"
local WorldGen = require "modules.worldgen"
require "perlin"

world = love.physics.newWorld(0, 2000, true)

function love.load()
    perlin:init()
    biribiri:LoadSprites("img")
    WorldGen:generate()

    Player:Init(world)
end

function love.update(dt)
    world:update(dt)
    Player:Update(dt)
end

function love.draw()
    WorldGen:draw()
    Player:Draw()
end