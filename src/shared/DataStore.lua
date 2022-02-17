local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DSS = game:GetService("DataStoreService")
local Inventory = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Inventory"))
local playerStats = DSS:GetDataStore("PlayerStats")

local defaultValues = {
    Cash = "0";
    Tokens = "0";
    Level = "0";
    Inventory = {
        Inventory = {},
        Equipped = nil,
    };
}

local DataStore = {}
DataStore.__index = DataStore

function DataStore:SaveData()
    local dataFolder = self.Folder
    local inventory = Inventory:GetInventory(game.Players:GetNameFromUserIdAsync(self.id))
    local s,r

    local function saveData()
        s,r = pcall(function()
            return playerStats:UpdateAsync(self.id, function(prevInfo)
                return {
                    ["Cash"] = dataFolder.Cash.Value;
                    ["Tokens"] = dataFolder.Tokens.Value;
                    ["Level"] = dataFolder.Level.Value;
                    ["Inventory"] = {
                        ["Inventory"] = inventory.Inventory,
                        ["Equipped"] = inventory.Equipped,
                    };
                }

            end)
        end)
    end
    saveData()
    if not s then
        warn(r)
        wait(.5)
        saveData()
    end
end

function DataStore:GetData()
    local dataFolder = self.Folder
    local s,r

    local function getData()
        s,r = pcall(function()
            local data = playerStats:GetAsync(self.id)
            if data == nil then
                dataFolder.Cash.Value = defaultValues.Cash
                dataFolder.Tokens.Value = defaultValues.Tokens
                dataFolder.Level.Value = defaultValues.Level
                
            else
                dataFolder.Cash.Value = data["Cash"] 
                dataFolder.Tokens.Value = data["Tokens"]
                dataFolder.Level.Value = data["Level"]

                self.Inventory = data["Inventory"]["Inventory"]
                self.Equipped = data["Inventory"]["Equipped"]
                
            end
        end)
        if not s then 
            warn(r)
            wait(.5)
            getData()
        end
    end
    getData()

end

function DataStore.new(player)
    local self = setmetatable({}, DataStore) 

    self.id = player.userId

    self.Folder = Instance.new("Folder")
    self.Folder.Name = player.Name
    self.Folder.Parent = ReplicatedStorage:WaitForChild("Data")

    local Cash = Instance.new("StringValue")
    Cash.Name = "Cash"
    Cash.Parent = self.Folder

    local Tokens = Instance.new("StringValue")
    Tokens.Name = "Tokens"
    Tokens.Parent = self.Folder

    local Level = Instance.new("StringValue")
    Level.Name = "Level"
    Level.Parent = self.Folder

    self.Inventory = {"PL"}
    self.Equipped = "PL"

    return self
end

return DataStore