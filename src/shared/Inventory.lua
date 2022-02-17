local AllInventories = {}

local gameItems = {
    ["Backpacks"] = {
        "Rookie Backpack",
        "Rusty Backpack",
    };
    ["Wallets"] = {
        "Basic Wallet",
    };
    ["Pets"] = {
        "Common Dog",
    };
}

local Inventory = {}
Inventory.__index = Inventory

function Inventory:Equip()

end

function Inventory:Unequip()

end

function Inventory:Add(item)
    table.insert(self.Inventory.Inventory, item)

    local cloneInv = {
        ["Inventory"] = self.Inventory.Inventory,
        ["Equipped"] = self.Inventory.Equipped
    }
    AllInventories[self.plr.Name] = cloneInv
    print(AllInventories)
end

function Inventory:Delete()

end

function Inventory:GetInventory(playerName)
    for name, inv in pairs(AllInventories) do
        if name == playerName then
            return inv
         end
    end
end

function Inventory.new(plr, data)
    local self = setmetatable({}, Inventory)
    self.plr = plr

    self.Inventory = {}
    self.Inventory.Inventory = data.Inventory
    self.Inventory.Equipped = data.Equipped
    
    local InvBorderFrame = plr.PlayerGui:WaitForChild("InventoryGui"):WaitForChild("Frame"):WaitForChild("MainFrame"):WaitForChild("BorderFrame")
    

    local cloneInv = {
        ["Inventory"] = self.Inventory.Inventory,
        ["Equipped"] = self.Inventory.Equipped
    }

    AllInventories[plr.Name] = cloneInv
    return self
end

return Inventory