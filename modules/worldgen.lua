local worldgen = {}
worldgen.world = {}
worldgen.ores = {}

function createNode(x, y, width, height)
    local body = love.physics.newBody(world, x + width / 2, y + height / 2, "static")
    local shape = love.physics.newRectangleShape(width, height)
    local fixture = love.physics.newFixture(body, shape)
    fixture:setRestitution(0)

    local node = {
        x = x,
        y = y,
        width = width,
        height = height,
        body = body,
        shape = shape,
        fixture = fixture
    }

    return node
end

local ORE_STRENGTHS = {
    stone = 3,
    copper = 15,
    iron = 75
}

MINIMUM_ORE_TIER = {
    stone = 0,
    copper = 1,
    iron = 3
}

function createOre(x, y, type)
    local ore = {
        x = x,
        y = y,
        type = type,
        progress = ORE_STRENGTHS[type]
    }

    return ore
end

function drawOre(ore)
    if ore.progress <= 0 then return end

    if ore.progress ~= ORE_STRENGTHS[ore.type] then
        love.graphics.rectangle("fill", ore.x - Player.camera.x, ore.y - Player.camera.y - 5, 64, 10)
        love.graphics.setColor(1,0,0,1)
        love.graphics.rectangle("fill", ore.x - Player.camera.x, ore.y - Player.camera.y - 5, 64 * (ore.progress / ORE_STRENGTHS[ore.type]), 10)
        love.graphics.setColor(1,1,1,1)
    end

    love.graphics.draw(assets["img/ore_"..ore.type..".png"], ore.x - Player.camera.x, ore.y - Player.camera.y, 0, 0.5,0.5)
end

function pickOre()
    local chances = {
        {"iron", 0.1},
        {"copper", 0.4},
        {"stone", 1}
    }

    local roll = love.math.random()

    for _, v in ipairs(chances) do
        if roll <= v[2] then
            return v[1]
        end
    end
end

function worldgen:generate()
    local dirChange = 20
    local dir = true
    local height = 0
    local height2 = 0
    local mult = 1.2

    local x = -500
    local between = false
    local betweenChange = 30

    for _ = 1, 500 do
        dirChange = dirChange - 1
        betweenChange = betweenChange - 1

        if love.math.random(1, dirChange) == 1 then
            dir = not dir
            dirChange = love.math.random(15,30)
            mult = 1.2
        else
            mult = mult * love.math.random(90,115) / 100
        end

        if love.math.random(1, betweenChange) == 1 then
            between = not between

            if between then
                betweenChange = love.math.random(20,40)
            else
                betweenChange = love.math.random(4,10)
            end
        end

        height = height + love.math.random() * mult * (dir and 1 or -1) * 30
        height2 = math.clamp(height2 + love.math.random() * (mult / 2) * (dir and 1 or -1) * 20, -math.huge, 100)

        local width = love.math.random(100,200)

        local node = createNode(x, height + 1000, width, 500)

        if between then
            local abovenode = createNode(x, height2 + 550 + height, width, 150)
            table.insert(self.world, abovenode)
        end

        if love.math.random(1,4) == 1 then
            table.insert(self.ores, createOre(x + width / 2, height + 980, pickOre()))
        end

        if love.math.random(1,4) == 1 and between then
            table.insert(self.ores, createOre(x + width / 2, height2 + 530 + height, pickOre()))
        end

        x = x + width
        table.insert(self.world, node)
    end
end

function worldgen:draw()
    for i, node in ipairs(self.world) do
        love.graphics.rectangle("fill", node.x - Player.camera.x + 25, node.y - Player.camera.y + 25, node.width, node.height)
    end

    for _, ore in ipairs(self.ores) do
        drawOre(ore)
    end
end

return worldgen