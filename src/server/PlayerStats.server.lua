local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local DataStore = require(RS:WaitForChild("Common"):WaitForChild("DataStore"))
local Inventory = require(RS:WaitForChild("Common"):WaitForChild("Inventory"))

local InvokeInventory = RS:WaitForChild("Remotes"):WaitForChild("InvokeInventory")
local InvokeInventoryReturn = InvokeInventory.Parent.InvokeInventoryReturn

Players.PlayerAdded:Connect(function(player)
    local character = player.Character or player.CharacterAdded:Wait()

    -- Get and save data values.

    local Data = DataStore.new(player)
    
    Data:GetData()
    local plrInv = Inventory.new(player, Data) -- Setup inventory.
    Data:SaveData()
    
    local plrGui = player:WaitForChild("PlayerGui")
    local devTest = plrGui.DevTest
    for i,v in pairs(devTest:GetChildren()) do
        if v:IsA("TextButton") then
            v.MouseButton1Click:Connect(function()
                if v.Name == "GetData" then
                    Data:GetData()
                elseif v.Name == "SaveData" then
                    Data:SaveData()
                end
            end)
        end
        
        if v:IsA("TextLabel") then -- Change text when value changed.
            for _,o in pairs(Data.Folder:GetChildren()) do
                if o:IsA("IntValue") or o:IsA("StringValue") then
                    o:GetPropertyChangedSignal("Value"):Connect(function()
                        if v.Name == o.Name then
                            v.Text = v.Name..": "..o.Value
                        end
                    end)
                end
            end
        end
    end

    devTest.Cash.Text = "Cash: "..Data.Folder.Cash.Value
    devTest.Tokens.Text = "Tokens: "..Data.Folder.Tokens.Value
    devTest.Level.Text = "Level: "..Data.Folder.Level.Value

    -- Inventory Events

    InvokeInventory.OnServerEvent:Connect(function(plr, type, item)
        if plr == player then
            if type == "Buy" then
                plrInv:Add(item)
            elseif type == "Equip" then
                plrInv:Equip(item)
            elseif type == "Unequip" then
                plrInv:Unequip(item)
            end
        end
    end)

    InvokeInventoryReturn.OnServerInvoke = function(plr, type, item)
        if plr == player then
            if type == "Get" then
                local result = plrInv:GetInventory(plr.Name)
                return result
            end
        end
    end


    game.Players.PlayerRemoving:Connect(function()
        Data:SaveData()
    end)
end)
