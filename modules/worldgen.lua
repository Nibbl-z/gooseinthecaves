local worldgen = {}
worldgen.world = {}

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

function worldgen:generate()
    local dirChange = 20
    local dir = true
    local height = 0
    local height2 = 0
    local mult = 1.2

    local x = 0
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

        local node = createNode(x - 500, height + 1000, width, 500)

        if between then
            local abovenode = createNode(x - 500, height2 + 550 + height, width, 150)
            table.insert(self.world, abovenode)
        end

        x = x + width
        table.insert(self.world, node)
    end
end

function worldgen:draw()
    for i, node in ipairs(self.world) do
        love.graphics.rectangle("fill", node.x - Player.camera.x + 25, node.y - Player.camera.y + 25, node.width, node.height)
    end
end

return worldgen