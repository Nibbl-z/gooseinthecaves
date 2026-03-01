local enemy = {}
enemy.__index = enemy

function enemy:new(x, y)
    local body = love.physics.newBody(world, x, y, "dynamic")
    body:setLinearDamping(2)
    local shape = love.physics.newRectangleShape(50, 50)
    local fixture = love.physics.newFixture(body, shape)
    fixture:setRestitution(0)
    fixture:setUserData("enemy")
    local object = {
        spritesheet = assets["img/greygoose.png"],
        body = body,
        shape = shape,
        fixture = fixture,
        quads = {},
        frame = 1,
        speed = 3000,
        jumpHeight = 2000,
        grounded = false,
        flipped = false,
        running = false,
        runFrameTimer = 0,
        runningFrame = 1,
        lastX = 0,
        dead = false,
        health = 2,
        maxHealth = 2,
        transparency = 1,
    }

    
    local w, h = 51, 50

    for y = 0, object.spritesheet:getHeight() - h, h do
        for x = 0, object.spritesheet:getWidth(), w do
            table.insert(object.quads, love.graphics.newQuad(x, y, w, h, object.spritesheet:getDimensions()))
        end
    end

    biribiri:CreateAndStartTimer(0.5, function ()
        if object.dead then return end
        print(math.abs(object.lastX - object.body:getX()))
        if math.abs(object.lastX - object.body:getX()) < 200 then
            object.lastX = object.body:getX()
            if object.grounded and math.abs(Player.body:getX() - object.body:getX()) > 100 then
                object.body:applyLinearImpulse(0, -object.jumpHeight)
            end
        else
            object.lastX = object.body:getX()
        end
    end, true)

    setmetatable(object, self)
    return object
end

function enemy:update(dt)
    if self.dead then
        self.frame = 9
        return
    end

    if self.health == 0 then
        self.dead = true
        self.fixture:setUserData(nil)
        self.body:applyLinearImpulse(love.math.random(-300,300), love.math.random(100,300))

        biribiri:CreateAndStartTimer(2, function ()
            tween:new(self, TweenInfo.new(0.5), {transparency = 0}):play()

            biribiri:CreateAndStartTimer(0.5, function ()
                self:destroy()
            end)
        end)

        return
    end

    if #self.body:getContacts() >= 1 then
        self.grounded = true
    else
        self.grounded = false
    end

    local dist = Player.body:getX() - self.body:getX()
    self.running = false
    if dist < -10 then
        self.body:applyLinearImpulse(-self.speed * dt, 0)
        self.running = true
        self.flipped = false
    end

    if dist > 10 then
        self.running = true
        self.flipped = true
        self.body:applyLinearImpulse(self.speed * dt, 0)
    end

    if self.running then
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
end

function enemy:destroy()
    self.fixture:destroy()
    self.shape:release()
    self.body:destroy()
end

function enemy:draw()
    if self.transparency <= 0.01 then return end
    local px, py = self.body:getX() + 25 - Player.camera.x, self.body:getY() + 25 - Player.camera.y

    if self.health ~= self.maxHealth and self.health ~= 0 then
        love.graphics.rectangle("fill", px - 20, py - 35, 50, 10)
        love.graphics.setColor(1,0,0,1)
        love.graphics.rectangle("fill", px - 20, py - 35, 50 * (self.health / self.maxHealth), 10)
        love.graphics.setColor(1,1,1,1)
    end
    
    love.graphics.setColor(1,1,1,self.transparency)
    love.graphics.draw(self.spritesheet, self.quads[self.frame], px, py, 0, self.flipped and -1 or 1, 1, 25, 25)
    love.graphics.setColor(1,1,1,1)
end

return enemy