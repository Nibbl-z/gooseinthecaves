require "yan"
require "biribiri"
local ui = {}

function ui:updateRequirements(tool, requirements)
    for _, v in ipairs(self.screen:get("upgrades"):get(tool .. "Requirements").children) do
        v.parent = nil
        v = nil
    end
    table.clear(self.screen:get("upgrades"):get(tool .. "Requirements").children)

    if requirements == nil then
        local text = textlabel:new {
            text = "Max upgrade reached!",
            fontpath = "Qaaxee.ttf",
            size = UDim2.new(1, 0, 0, 50),
            backgroundcolor = Color.new(0, 0, 0, 0),
            textcolor = Color.new(1, 1, 1, 1),
            halign = "right",
        }

        text:setparent(self.screen:get("upgrades"):get(tool .. "Requirements")) 

        return
    end

    for id, amount in pairs(requirements) do
        local text = textlabel:new {
            text = itemData[id].name .. " x" .. tostring(amount),
            size = UDim2.new(1, 0, 0, 50),
            backgroundcolor = Color.new(0, 0, 0, 0),
            textcolor = Color.new(1, 1, 1, 1),
            halign = "right",
            fontpath = "Qaaxee.ttf",
            children = {
                image = imagelabel:new {
                    size = UDim2.new(0, 50, 0, 50),
                    image = itemData[id].img,
                    backgroundcolor = Color.new(0, 0, 0, 0)
                }
            }
        }

        text:setparent(self.screen:get("upgrades"):get(tool .. "Requirements"))
    end
end

function ui:addNotif(text)
    local label = textlabel:new {
        text = text,
        size = UDim2.new(0.6, 0, 0, 24),
        textsize = 24,
        backgroundcolor = Color.new(0, 0, 0, 0),
        textcolor = Color.new(1,1,1, 1),
        fontpath = "Qaaxee.ttf",
        halign = "right",
    }

    label:setparent(self.screen:get("notifs"))

    biribiri:CreateAndStartTimer(1.5, function()
        tween:new(label, TweenInfo.new(0.5), { textcolor = Color.new(1, 1, 1, 0) }):play()
        biribiri:CreateAndStartTimer(0.5, function()
            table.remove(self.screen:get("notifs").children, table.find(self.screen:get("notifs").children, label))
        end)
    end)
end

function ui:init()
    self.inventoryOpen = false
    self.upgradesOpen = false

    self.screen = screen:new {
        inventory = uibase:new {
            size = UDim2.new(0, 410, 0, 300),
            position = UDim2.new(0.5, 0, 0.5, 0),
            anchorpoint = Vector2.new(0.5, 0.5),
            backgroundcolor = Color.new(0.2, 0.2, 0.2, 0.7),
            visible = function()
                return self.inventoryOpen
            end,
            leftpadding = UDim.new(0,5),
            rightpadding = UDim.new(0,5),
            children = {
                title = textlabel:new {
                    text = "Inventory",
                    size = UDim2.new(1, 0, 0, 50),
                    backgroundcolor = Color.new(0, 0, 0, 0),
                    textcolor = Color.new(1, 1, 1, 1),
                    fontpath = "Qaaxee.ttf",
                    textsize = 32
                },
            },
            cornerradius = UDim.new(0,16),
            bordersize = 4,
            bordercolor = Color.new(0,0,0, 0.5)
        },

        upgrades = uibase:new {
            size = UDim2.new(0, 400, 0, 300),
            position = UDim2.new(0.5, 0, 0.5, 0),
            anchorpoint = Vector2.new(0.5, 0.5),
            backgroundcolor = Color.new(0.2, 0.2, 0.2, 0.7),
            cornerradius = UDim.new(0,16),
            bordersize = 4,
            bordercolor = Color.new(0,0,0, 0.5),
            visible = function()
                return self.upgradesOpen
            end,
            children = {
                title = textlabel:new {
                    text = "Upgrade Tools",
                    size = UDim2.new(1, 0, 0, 50),
                    backgroundcolor = Color.new(0, 0, 0, 0),
                    textcolor = Color.new(1, 1, 1, 1),
                    fontpath = "Qaaxee.ttf",
                    textsize = 32,
                },
                pickaxe = imagelabel:new {
                    image = "img/pickaxe.png",
                    size = UDim2.new(0, 64, 0, 64),
                    anchorpoint = Vector2.new(0.5, 0),
                    position = UDim2.new(0.25, 0, 0, 60),
                    backgroundcolor = Color.new(0, 0, 0, 0)
                },
                pickaxeText = textlabel:new {
                    text = function()
                        if Player.tools[1].strength == #Player.tools[1].upgrades then return "Pickaxe (Max Tier)" end

                        return "Pickaxe (Tier " ..
                        tostring(Player.tools[1].strength) .. "->" .. tostring(Player.tools[1].strength + 1) .. ")"
                    end,
                    size = UDim2.new(0.5, 0, 0, 50),
                    position = UDim2.new(0, 0, 0, 130),
                    backgroundcolor = Color.new(0, 0, 0, 0),
                    textcolor = Color.new(1, 1, 1, 1),
                    fontpath = "Qaaxee.ttf",
                },
                pickaxeRequirements = uibase:new {
                    size = UDim2.new(0.5, -10, 0.35, 0),
                    position = UDim2.new(0, 5, 0, 170),
                    backgroundcolor = Color.new(0,0,0,0),
                    layout = "list",
                    listhalign = "center",
                    listvalign = "top"
                },
                pickaxeUpgrade = textlabel:new {
                    size = UDim2.new(0.5, -30, 0.1, 0),
                    position = UDim2.new(0, 15, 1, -10),
                    anchorpoint = Vector2.new(0, 1),
                    backgroundcolor = Color.new(0,0.7,0, 1),
                    cornerradius = UDim.new(0,8),
                    text = "Upgrade",
                    fontpath = "Qaaxee.ttf",
                    textcolor = Color.new(1, 1, 1, 1),
                    mousebutton1up = function(v) 
                        local result = Player:upgrade(1)
                        if result == true then
                            self:updateRequirements("pickaxe", TOOLS[1].upgrades[Player.tools[1].strength + 1])
                        else
                            self:addNotif("Not enough resources!")
                        end
                    end
                },

                ---
                
                sword = imagelabel:new {
                    image = "img/sword.png",
                    size = UDim2.new(0, 64, 0, 64),
                    anchorpoint = Vector2.new(0.5, 0),
                    position = UDim2.new(0.75, 0, 0, 60),
                    backgroundcolor = Color.new(0, 0, 0, 0)
                },
                swordText = textlabel:new {
                    text = function()
                        if Player.tools[2].strength == #Player.tools[2].upgrades then return "Sword (Max Tier)" end

                        return "Sword (Tier " ..
                        tostring(Player.tools[2].strength) .. "->" .. tostring(Player.tools[2].strength + 1) .. ")"
                    end,
                    fontpath = "Qaaxee.ttf",
                    size = UDim2.new(0.5, 0, 0, 50),
                    position = UDim2.new(0.5, 0, 0, 130),
                    backgroundcolor = Color.new(0, 0, 0, 0),
                    textcolor = Color.new(1, 1, 1, 1)
                },
                swordRequirements = uibase:new {
                    size = UDim2.new(0.5, -10, 0.35, 0),
                    position = UDim2.new(0.5, 5, 0, 170),
                    backgroundcolor = Color.new(0,0,0,0),
                    layout = "list",
                    listhalign = "center",
                    listvalign = "top"
                },
                swordUpgrade = textlabel:new {
                    size = UDim2.new(0.5, -30, 0.1, 0),
                    position = UDim2.new(0.5, 15, 1, -10),
                    anchorpoint = Vector2.new(0, 1),
                    text = "Upgrade",
                    fontpath = "Qaaxee.ttf",
                    textcolor = Color.new(1, 1, 1, 1),
                    backgroundcolor = Color.new(0,0.7,0, 1),
                    cornerradius = UDim.new(0,8),
                    mousebutton1up = function()
                        local result = Player:upgrade(2)
                        if result == true then
                            self:updateRequirements("sword", TOOLS[2].upgrades[Player.tools[2].strength + 1])
                        else
                            self:addNotif("Not enough resources!")
                        end
                    end
                }
            }
        },

        notifs = uibase:new {
            size = UDim2.new(1, 0, 1, 0),
            backgroundcolor = Color.new(0, 0, 0, 0),
            layout = "list",
            listhalign = "right",
            listvalign = "bottom",
        },
        health = textlabel:new {
            size = UDim2.new(0.5,0,0,50),
            position = UDim2.new(0,70,1,-10),
            anchorpoint = Vector2.new(0,1),
            textcolor = Color.new(1,0,0,1),
            backgroundcolor = Color.new(0,0,0,0),
            fontpath = "Qaaxee.ttf",
            text = function ()
                return tostring(Player.health).."/"..tostring(Player.maxHealth).." HP"
            end,
            halign = "left"
        },
        thirst = textlabel:new {
            size = UDim2.new(0.5,0,0,50),
            position = UDim2.new(0,70,1,-70),
            anchorpoint = Vector2.new(0,1),
            textcolor = Color.new(0.3,0.3,1,1),
            backgroundcolor = Color.new(0,0,0,0),
            fontpath = "Qaaxee.ttf",
            text = function ()
                return tostring(math.floor(Player.thirst)).."/100 THIRST"
            end,
            halign = "left"
        },

        status = textlabel:new {
            size = UDim2.new(1,0,0,50),
            fontpath = "Qaaxee.ttf",
            text = function ()
                return (peace and "PEACE" or "HAZARD").." PHASE ends in 0:"..string.format("%02d", math.floor(60 - gametime))
            end,
            backgroundcolor = Color.new(0,0,0,0),
            textcolor = function ()
                return peace and Color.new(1,1,1,1) or Color.new(1,0.3,0.3,1)
            end
        },

        score = textlabel:new {
            size = UDim2.new(1,0,0,50),
            fontpath = "Qaaxee.ttf",
            text = function ()
                return "SCORE: "..string.format("%06d", Player.score)
            end,
            position = UDim2.new(0,-10,0,0),
            halign = "right",
            backgroundcolor = Color.new(0,0,0,0),
            textcolor = function ()
                return peace and Color.new(1,1,1,1) or Color.new(1,0.3,0.3,1)
            end
        },

        gameOver = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = function ()
                return Color.new(0,0,0,(1 - Player.deathTransparency))
            end,
            children = {
                title = textlabel:new {
                    size = UDim2.new(1,0,0.2,0),
                    position = UDim2.new(0.5,0,0.4,0),
                    anchorpoint = Vector2.new(0.5,0.5),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = function ()
                        return Color.new(1,1,1,(1 - Player.deathTransparency))
                    end,
                    text = "The Body Was Never Found!",
                    textsize = 40,
                    fontpath = "Qaaxee.ttf"
                },

                subtitle = textlabel:new {
                    size = UDim2.new(1,0,0.2,0),
                    position = UDim2.new(0.5,0,0.5,0),
                    anchorpoint = Vector2.new(0.5,0.5),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = function ()
                        return Color.new(0.8,0.8,0.8,(1 - Player.deathTransparency))
                    end,
                    text = "press any key to inhibit another one",
                    fontpath = "Qaaxee.ttf"
                },

                score = textlabel:new {
                    size = UDim2.new(1,0,0.2,0),
                    position = UDim2.new(0,0,0.8,0),
                    anchorpoint = Vector2.new(0,0.5),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = function ()
                        return Color.new(0.8,0.8,0.8,(1 - Player.deathTransparency))
                    end,
                    text = function ()
                        return "final score: "..string.format("%06d", Player.score)
                    end,
                    fontpath = "Qaaxee.ttf"
                }
            }
        }
    }

    for k, v in pairs(Player.inventory) do
        local y = math.floor(k / 8) * 100 + 60
        local x = (k * 100) - (math.floor(k / 8) * 400) - 100

        local element = uibase:new {
            size = UDim2.new(0, 96, 0, 96),
            position = UDim2.new(0, x + 2, 0, y + 2),
            cornerradius = UDim.new(0, 4),
            backgroundcolor = Color.new(0, 0, 0, 0.5),
            children = {
                image = imagelabel:new {
                    image = v.img,
                    size = UDim2.new(0, 94, 0, 94),
                    position = UDim2.new(0, 1, 0, 1),
                    backgroundcolor = Color.new(0, 0, 0, 0)
                },
                amount = textlabel:new {
                    position = UDim2.new(1, 0, 1, 0),
                    anchorpoint = Vector2.new(1, 1),
                    size = UDim2.new(1, 0, 0.4, 0),
                    textsize = 24,
                    text = function()
                        return "x" .. tostring(v.amount)
                    end,
                    fontpath = "Qaaxee.ttf",
                    halign = "right",
                    textcolor = Color.new(1, 1, 1, 1),
                    backgroundcolor = Color.new(0, 0, 0, 0)
                }
            }
        }

        element:setparent(self.screen:get("inventory"))
    end

    self:updateRequirements("pickaxe", TOOLS[1].upgrades[1])
    self:updateRequirements("sword", TOOLS[2].upgrades[1])
end

return ui
