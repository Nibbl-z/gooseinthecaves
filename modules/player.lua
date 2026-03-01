require "biribiri"
require "yan"

local player = {}

items = {
    stone = 1,
    copper = 2,
    iron = 3,
    diamond = 4,
    water = 5,
    yeast = 6
}

itemData = {
    [1] = {
        name = "Stone",
        img = "img/ore_stone.png"
    },
    [2] = {
        name = "Copper Ore",
        img = "img/ore_copper.png"
    },
    [3] = {
        name = "Iron Ore",
        img = "img/ore_iron.png"
    },
    [4] = {},
    [5] = {},
    [6] = {}
}

TOOLS = {

}

function player:Init(world)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")
    self.body:setLinearDamping(2)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setRestitution(0)
    self.fixture:setUserData("player")

    self.grounded = false
    self.flipped = false
    self.jumpPressed = false

    self.maxHealth = 100
    self.health = self.maxHealth

    self.speed = 4000
    self.jumpHeight = 2500
    self.dashSpeed = 2000

    self.c = Vector2.new(0, 0)
    self.camera = Vector2.new(0, 0)
    self.camoffset = Vector2.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    self.dashCooldown = 0
    self.maxDashCooldown = 1

    self.spritesheet = assets["img/goose.png"]
    self.quads = {}

    self.running = false
    self.dashing = -1

    local w, h = 51, 50

    for y = 0, self.spritesheet:getHeight() - h, h do
        for x = 0, self.spritesheet:getWidth(), w do
            table.insert(self.quads, love.graphics.newQuad(x, y, w, h, self.spritesheet:getDimensions()))
        end
    end

    self.frame = 1
    self.runningFrame = 1

    self.runFrameTimer = 0
    self.dashFrameTimer = 0

    self.dmgOverlay = 0.0
    self.lastDmg = self.maxHealth

    self.heartSpritesheet = assets["img/heart.png"]
    self.heartQuads = {}
    self.heartFrame = 1
    local w, h = 51, 50

    for y = 0, self.heartSpritesheet:getHeight() - h, h do
        for x = 0, self.heartSpritesheet:getWidth(), w do
            table.insert(self.heartQuads, love.graphics.newQuad(x, y, w, h, self.heartSpritesheet:getDimensions()))
        end
    end

    biribiri:CreateAndStartTimer(0.1, function ()
        self.heartFrame = self.heartFrame + 1
        if self.heartFrame == 14 then
            self.heartFrame = 1
        end
    end, true)

    TOOLS = {
        {
            id = "pickaxe",
            img = assets["img/pickaxe.png"],
            rotation = 0,
            upgrades = {
                {
                    [items.stone] = 3
                },
                {
                    [items.stone] = 5
                },
                {
                    [items.stone] = 7,
                    [items.copper] = 3
                },
                {
                    [items.stone] = 10,
                    [items.copper] = 5
                },
            },
            strength = 0,
            debounce = 0,
            click = function(self, this, x, y)
                if this.debounce ~= 0 then return end
                this.rotation = math.rad(45)
                local db = math.clamp((0.5 - (this.strength / 40)), 0.1, 1000)
                tween:new(this, TweenInfo.new(db), { rotation = 0 }):play()
                this.debounce = db

                for _, ore in ipairs(WorldGen.ores) do
                    if biribiri.distance(x, y, ore.x, ore.y) < 75 and this.strength < MINIMUM_ORE_TIER[ore.type] then
                        uis.game:addNotif("you cant mine this stupid")
                    end
                    if biribiri.distance(x, y, ore.x, ore.y) < 75 and ore.progress ~= 0 and this.strength >= MINIMUM_ORE_TIER[ore.type] then
                        ore.progress = math.clamp(ore.progress - (this.strength + 1), 0, math.huge)
                        if ore.progress == 0 then
                            uis.game:addNotif("Collected +1 " .. itemData[items[ore.type]].name)
                            self.inventory[items[ore.type]].amount = self.inventory[items[ore.type]].amount + 1
                        end
                    end
                end
            end
        },

        {
            id = "sword",
            img = assets["img/sword.png"],
            rotation = 0,
            upgrades = {
                {
                    [items.stone] = 3
                },
                {
                    [items.stone] = 5
                },
                {
                    [items.stone] = 7,
                    [items.copper] = 3
                },
                {
                    [items.stone] = 10,
                    [items.copper] = 5
                },
            },
            strength = 0,
            debounce = 0,
            click = function(self, this, x, y)
                if this.debounce ~= 0 then return end
                this.rotation = math.rad(45)
                local db = math.clamp((0.5 - (this.strength / 40)), 0.1, 1000)
                tween:new(this, TweenInfo.new(db), { rotation = 0 }):play()
                this.debounce = db

                for _, enemy in ipairs(enemies) do
                    if biribiri.distance(x, y, enemy.body:getX(), enemy.body:getY()) < 75 then
                        enemy.health = math.clamp(enemy.health - 1, 0, math.huge)
                    end
                end
            end
        }
    }
    self.tools = {
        [1] = TOOLS[1],
        [2] = TOOLS[2]
    }

    self.inventory = {

    }

    for k, v in pairs(items) do
        self.inventory[v] = {
            id = k,
            amount = 0,
            img = itemData[v].img or "img/goog.png"
        }
    end

    self.equipped = 1
end

function player:canUpgrade(tool)
    local upgrade = self.tools[tool].upgrades[self.tools[tool].strength + 1]
    if upgrade == nil then return false end

    for id, amount in pairs(upgrade) do
        if self.inventory[id].amount < amount then
            return false
        end
    end

    return true
end

function player:upgrade(tool)
    if not self:canUpgrade(tool) then return end

    local upgrade = self.tools[tool].upgrades[self.tools[tool].strength + 1]
    if upgrade == nil then return end

    for id, amount in pairs(upgrade) do
        self.inventory[id].amount = self.inventory[id].amount - amount
    end

    self.tools[tool].strength = self.tools[tool].strength + 1

    return true
end

local DASH_DIRECTIONS = {
    a = { x = -1, y = 0 },
    w = { x = 0, y = -1 },
    d = { x = 1, y = 0 },
    s = { x = 0, y = 1 }
}

function player:takeDamage()
    if self.dmgOverlay > 0.0 then return end
    self.health = self.health - 1
end

function player:Update(dt)
    for k, v in pairs(self.tools) do
        v.debounce = math.clamp(v.debounce - dt, 0, 100)
    end

    if self.health ~= self.lastDmg then
        --assets["audio/death.wav"]:play()
        self.dmgOverlay = 1.0
    end

    if #self.body:getContacts() >= 1 then
        self.grounded = true
    else
        self.grounded = false
    end

    if love.keyboard.isDown("a") then
        self.body:applyLinearImpulse(-self.speed * dt, 0)
        self.flipped = false
        self.running = true
    end

    if love.keyboard.isDown("d") then
        self.body:applyLinearImpulse(self.speed * dt, 0)
        self.flipped = true
        self.running = true
    end

    if not love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
        self.running = false
    end

    if love.keyboard.isDown("space") and self.grounded and not self.jumpPressed then
        self.jumpPressed = true
        self.body:applyLinearImpulse(0, -self.jumpHeight)
    end

    if not love.keyboard.isDown("space") then
        self.jumpPressed = false
    end

    if love.keyboard.isDown("lshift") and self.dashCooldown <= 0 then
        local dashDir = { x = 0, y = 0 }

        for key, value in pairs(DASH_DIRECTIONS) do
            if love.keyboard.isDown(key) then
                dashDir.x = value.x
                dashDir.y = value.y
            end
        end

        if dashDir.x == 0 and dashDir.y ~= 0 then
            self.dashing = 1
        elseif dashDir.y == 0 and dashDir.x ~= 0 then
            self.dashing = 2
        end

        if dashDir.x ~= 0 or dashDir.y ~= 0 then
            --assets["audio/dash.wav"]:play()
            self.dashFrameTimer = 0.3
            self.body:applyLinearImpulse(dashDir.x * self.dashSpeed, dashDir.y * self.dashSpeed * 3)
            self.dashCooldown = self.maxDashCooldown
        end
    end

    self.dashCooldown = self.dashCooldown - dt

    self.camoffset = Vector2.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self.c.x = biribiri:lerp(self.c.x, self.body:getX(), 0.1)
    self.c.y = biribiri:lerp(self.c.y, self.body:getY(), 0.1)

    self.camera.x = self.c.x - self.camoffset.x
    self.camera.y = self.c.y - self.camoffset.y

    if self.dashing == 1 then
        self.frame = 10
    elseif self.dashing == 2 then
        self.frame = 9
    elseif self.running then
        self.runFrameTimer = self.runFrameTimer + dt

        if self.runFrameTimer >= 0.1 then
            self.runFrameTimer = 0

            self.runningFrame = self.runningFrame + 1
            if self.runningFrame == 8 then
                self.runningFrame = 1
            end
        end


        self.frame = self.runningFrame
    else
        self.frame = 8
    end

    self.dashFrameTimer = self.dashFrameTimer - dt

    if self.dashFrameTimer <= 0 then
        self.dashing = -1
    end

    self.dmgOverlay = math.clamp(self.dmgOverlay - dt * 3, 0, 1)
    self.lastDmg = self.health
end

function player:mousepressed(button)
    local mx, my = love.mouse.getX() - 425, love.mouse.getY() - 325
    local px, py = self.body:getX() + 25 - self.camera.x, self.body:getY() + 25 - self.camera.y
    local angle = math.atan2(mx, my)
    local dist = math.clamp(math.sqrt((mx) ^ 2 + (my) ^ 2), 10, 200)

    if button == 1 then
        self.tools[self.equipped].click(self, self.tools[self.equipped], math.sin(angle) * dist + px + self.camera.x, math.cos(angle) * dist + py + self.camera.y)
    end
end

function player:reset()
    self.body:setLinearVelocity(0, 0)
    self.body:setX(0)
    self.body:setY(0)
    self.health = self.maxHealth
    self.lastDmg = self.maxHealth
end

function player:Draw()
    local px, py = self.body:getX() + 25 - self.camera.x, self.body:getY() + 25 - self.camera.y
    love.graphics.draw(self.spritesheet, self.quads[self.frame], px, py, 0, self.flipped and -1 or 1, 1, 25, 25)

    local mx, my = love.mouse.getX() - 425, love.mouse.getY() - 325

    local angle = math.atan2(mx, my)
    local dist = math.clamp(math.sqrt((mx) ^ 2 + (my) ^ 2), 10, 200)

    love.graphics.draw(self.tools[self.equipped].img, math.sin(angle) * dist + px, math.cos(angle) * dist + py,
        self.tools[self.equipped].rotation, 1, 1, 0, 50)

    love.graphics.draw(assets["img/heart.png"], self.heartQuads[self.heartFrame], 10, love.graphics.getHeight() - 60, 0, 1, 1)
end

return player
