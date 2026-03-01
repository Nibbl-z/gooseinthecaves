require "yan"
local ui = {}

function ui:updateRequirements(tool, requirements)
    for _, v in ipairs(self.screen:get("upgrades"):get(tool.."Requirements").children) do
        v.parent = nil
        v = nil
    end
    table.clear(self.screen:get("upgrades"):get(tool.."Requirements").children)

    for id, amount in pairs(requirements) do
        local text = textlabel:new {
            text = itemData[id].name .." x"..tostring(amount),
            size = UDim2.new(1,0,0,50),
            backgroundcolor = Color.new(0,0,0,0),
            textcolor = Color.new(1,1,1,1),
            halign = "right",
            children = {
                image = imagelabel:new {
                    size = UDim2.new(0,50,0,50),
                    image = itemData[id].img,
                    backgroundcolor = Color.new(0,0,0,0)
                }
            }
        }

        text:setparent(self.screen:get("upgrades"):get(tool.."Requirements"))
    end
end

function ui:init()
    self.inventoryOpen = false
    self.upgradesOpen = true

    self.screen = screen:new {
        inventory = uibase:new {
            size = UDim2.new(0, 400, 0, 300),
            position = UDim2.new(0.5, 0, 0.5, 0),
            anchorpoint = Vector2.new(0.5, 0.5),
            backgroundcolor = Color.new(0.2, 0.2, 0.2, 0.7),
            visible = function()
                return self.inventoryOpen
            end
        },

        upgrades = uibase:new {
            size = UDim2.new(0, 400, 0, 300),
            position = UDim2.new(0.5, 0, 0.5, 0),
            anchorpoint = Vector2.new(0.5, 0.5),
            backgroundcolor = Color.new(0.2, 0.2, 0.2, 0.7),
            visible = function()
                return self.upgradesOpen
            end,
            children = {
                title = textlabel:new {
                    text = "Upgrade Tools",
                    size = UDim2.new(1,0,0,50),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1)
                },
                pickaxe = imagelabel:new {
                    image = "img/pickaxe.png",
                    size = UDim2.new(0,64,0,64),
                    anchorpoint = Vector2.new(0.5,0),
                    position = UDim2.new(0.25,0,0,60),
                    backgroundcolor = Color.new(0,0,0,0)
                },
                pickaxeRequirements = uibase:new {
                    size = UDim2.new(0.5,0,0.4,0),
                    position = UDim2.new(0,0,0,130),
                    backgroundcolor = Color.new(1,1,1,0.2),
                    layout = "list",
                    listhalign = "center",
                    listvalign = "top"
                },
                pickaxeUpgrade = textlabel:new {
                    size = UDim2.new(0.5,0,0.1,0),
                    position = UDim2.new(0,0,1,-10),
                    anchorpoint = Vector2.new(0,1),
                    backgroundcolor = Color.new(0,1,0,0.4),
                    text = "Upgrade",
                    textcolor = Color.new(1,1,1,1),
                    mousebutton1up = function ()
                        local result = Player:upgrade(1)
                        if result == true then
                            print("good")

                            self:updateRequirements("pickaxe", TOOLS[1].upgrades[Player.tools[1].strength + 1])
                        end
                    end
                }
            }
        }
    }

    for k, v in pairs(Player.inventory) do
        local y = math.floor(k / 8) * 50
        local x = (k * 50) - (math.floor(k / 8) * 400) - 50

        local element = uibase:new {
            size = UDim2.new(0, 46, 0, 46),
            position = UDim2.new(0, x + 2, 0, y + 2),
            cornerradius = UDim.new(0, 4),
            backgroundcolor = Color.new(0, 0, 0, 0.5),
            children = {
                image = imagelabel:new {
                    image = v.img,
                    size = UDim2.new(0, 44, 0, 44),
                    position = UDim2.new(0, 1, 0, 1),
                    backgroundcolor = Color.new(0, 0, 0, 0)
                },
                amount = textlabel:new {
                    position = UDim2.new(1, 0, 1, 0),
                    anchorpoint = Vector2.new(1, 1),
                    size = UDim2.new(1, 0, 0.4, 0),
                    textsize = 14,
                    text = function()
                        return "x" .. tostring(v.amount)
                    end,
                    halign = "right",
                    textcolor = Color.new(1, 1, 1, 1),
                    backgroundcolor = Color.new(0, 0, 0, 0)
                }
            }
        }

        element:setparent(self.screen:get("inventory"))
    end

    self:updateRequirements("pickaxe", TOOLS[1].upgrades[1])
end

return ui
