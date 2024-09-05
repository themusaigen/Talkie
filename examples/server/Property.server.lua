local Talkie = require(game.ReplicatedStorage.Talkie)

local server = Talkie.Server(game.ReplicatedStorage.Services, "PropertyExample")

-- name: string, initial: any, middleware
local coolProperty = server:Property("MyCoolProperty", 0)

game.Players.PlayerAdded:Connect(function(player)
  player.CharacterAdded:Connect(function()
    coolProperty:SetFor(player, 1337 / 2)

    task.wait(3)

    coolProperty:SetFor(player, 1337)
  end)
end)
