local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Inventory = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Inventory"))

local InvokeInventory = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("InvokeInventory")
local InvokeInventoryReturn = InvokeInventory.Parent.InvokeInventoryReturn

local shopGui = playerGui:WaitForChild("ShopGui"):WaitForChild("Frame")
local shopBorderFrame = shopGui:WaitForChild("MainFrame"):WaitForChild("BorderFrame")
local shopDisplayFrame = shopGui:WaitForChild("MainFrame"):WaitForChild("DisplayFrame")

local invGui = playerGui:WaitForChild("InventoryGui"):WaitForChild("Frame")
local invBorderFrame = invGui:WaitForChild("MainFrame"):WaitForChild("BorderFrame")
local invDisplayFrame = invGui:WaitForChild("MainFrame"):WaitForChild("DisplayFrame")

local openShopGuiPart = workspace.ShopPart

local openInvGuiButton = invGui.Parent.InventoryButton

local itemDescriptions = {
    ["Backpacks"] = {
        ["Rookie Backpack"] = "Old peice of junk. Can only hold up to 10 items.",
        ["Rusty Backpack"] = "At least its better than the rookie. Although its rusty, it holds up to 20 items!",
    };
    ["Wallets"] = {
        ["Basic Wallet"] = "Although it wont do much into protecting your items, its better than nothing!",
    };
    ["Pets"] = {
        ["Common Dog"] = "1.1X boost on cash!",
    };
}

-- Shop Frame

for _,item in pairs(shopBorderFrame:GetDescendants()) do -- Setup cameras for items.
    if item:IsA("ImageButton") then
        local camera = Instance.new("Camera")
        item.ViewportFrame.CurrentCamera = camera
        camera.Parent = item.ViewportFrame
        camera.CFrame = item.ViewportFrame.Part.CFrame * CFrame.new(0,0,7)
    end
end

local shopLatestButton
local shopActiveButtons = {}

for i,button in pairs(shopBorderFrame:GetDescendants()) do -- Display item when pressed on left menu.
    if button:IsA("ImageButton") then
        button.Activated:Connect(function()
            
            shopLatestButton = button
            shopLatestCategory = nil
            if shopDisplayFrame.ImageFrame.ViewportFrame ~= nil then
                shopDisplayFrame.ImageFrame.ViewportFrame:Destroy()
            end
            local clone = button.ViewportFrame:Clone()
            clone.Parent = shopDisplayFrame.ImageFrame
            TweenService:Create(clone.Part, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0), {Orientation = Vector3.new(0,360,0)}):Play()
            for folder,items in pairs(itemDescriptions) do
                for name, description in pairs(items) do
                    if button.Name == name then
                        shopDisplayFrame.MainFrame.TextLabel.Text = description
                        shopLatestCategory = folder
                    end
                end
            end
            shopGui.MainFrame.BuyButton.Visible = true
            shopGui.MainFrame.Price.Text = "Price: $"..button.Price.Value

            if not table.find(shopActiveButtons, button) then -- If not item duplicates, only add to connection if item is not duplicate
                shopGui.MainFrame.BuyButton.MouseButton1Click:Connect(function() -- Buy item
                    if button == shopLatestButton then
                        InvokeInventory:FireServer("Buy", button.Name) 
                        local shopClone = button:Clone()
                        print(tostring(shopLatestCategory).."Folder")
                        shopClone.Parent = invBorderFrame:FindFirstChild(tostring(shopLatestCategory).."Frame")
                    end
                end)
            else
                print(table.find(shopActiveButtons, button))
                table.remove(shopActiveButtons, table.find(shopActiveButtons, button)) -- Delete duplicates so multiple items arent bought accidentally
            end
            
            if button == shopLatestButton then
                table.insert(shopActiveButtons, button) -- Insert into items table. Later checked for duplicates.
            end
        end)
    end
end

for _,button in pairs(shopGui:GetChildren()) do -- Switch page on category.
    if button:IsA("TextButton") then
        if button.Name ~= "Exit" then
            button.MouseButton1Click:Connect(function()

                for i,v in pairs(shopBorderFrame:GetChildren()) do
                    if v:IsA("ScrollingFrame") then
                        if button.Name.."Frame" == v.Name then
                            v.Visible = true
                        else
                            v.Visible = false
                        end
                    end
                end

            end)
        end
    end
end
-- Open/Close Shop
openShopGuiPart.Touched:Connect(function()
    if shopGui.Visible == false then
        shopGui.MainFrame.BuyButton.Visible = false
        shopGui.Visible = true
        invGui.Visible = false
    end
end)

shopGui.Exit.MouseButton1Click:Connect(function()
    shopGui.Visible = false
    player.Character:MoveTo(openShopGuiPart.Position * Vector3.new(5,0,0))
end)

-- Inventory Frame

local invLatestButton
local invActiveButtons = {}

for i,button in pairs(invBorderFrame:GetDescendants()) do -- Display item when pressed on left menu.
    if button:IsA("ImageButton") then
        print(button)
        button.Activated:Connect(function()
            
            invLatestButton = button
            if invDisplayFrame.ImageFrame.ViewportFrame ~= nil then
                invDisplayFrame.ImageFrame.ViewportFrame:Destroy()
            end
            local clone = button.ViewportFrame:Clone()
            clone.Parent = invDisplayFrame.ImageFrame
            TweenService:Create(clone.Part, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0), {Orientation = Vector3.new(0,360,0)}):Play()
            for name,description in pairs(itemDescriptions) do
                if button.Name == name then
                    invDisplayFrame.MainFrame.TextLabel.Text = description
                end
            end
            invGui.MainFrame.BuyButton.Visible = true
            invGui.MainFrame.Price.Text = "Price: $"..button.Price.Value

            if not table.find(invActiveButtons, button) then -- If not item duplicates, only add to connection if item is not duplicate
                invGui.MainFrame.BuyButton.MouseButton1Click:Connect(function() -- Buy item
                    if button == invLatestButton then
                        InvokeInventory:FireServer("Buy", button.Name) 
                    end
                end)
            else
                print(table.find(invActiveButtons, button))
                table.remove(invActiveButtons, table.find(invActiveButtons, button)) -- Delete duplicates so multiple items arent bought accidentally
            end
            
            if button == invLatestButton then
                table.insert(invActiveButtons, button) -- Insert into items table. Later checked for duplicates.
            end
        end)
    end
end

for _,button in pairs(invGui:GetChildren()) do -- Switch page on category.
    if button:IsA("TextButton") then
        if button.Name ~= "Exit" then
            button.MouseButton1Click:Connect(function()

                for i,v in pairs(invBorderFrame:GetChildren()) do
                    if v:IsA("ScrollingFrame") then
                        if button.Name.."Frame" == v.Name then
                            v.Visible = true
                        else
                            v.Visible = false
                        end
                    end
                end

            end)
        end
    end
end

--Open/Close Inventory
openInvGuiButton.MouseButton1Click:Connect(function()
    if invGui.Visible == false then
        invGui.Visible = true
        invGui.MainFrame.UnequipButton.Visible = false
        invGui.MainFrame.EquipButton.Visible = false
    else
        invGui.Visible = false
    end
    if shopGui.Visible == true then
        player.Character:MoveTo(openShopGuiPart.Position * Vector3.new(5,0,0))
        shopGui.Visible = false
    end
end)

invGui.Exit.MouseButton1Click:Connect(function()
    invGui.Visible = false
end)

-- Update InventoryGui with saved data.

local savedInv = InvokeInventoryReturn:InvokeServer("Get", "")
for _,item in ipairs(savedInv.Inventory) do
    for i,v in pairs(shopBorderFrame:GetDescendants()) do
        if v:IsA("ImageButton") then
            if item == v.Name then
                for folder,items in pairs(itemDescriptions) do
                    for name, description in pairs(items) do
                        if v.Name == name then
                            local clone = v:Clone()
                            clone.Parent = invBorderFrame:FindFirstChild(tostring(folder).."Frame")
                        end
                    end
                end
            end
        end
    end
end






