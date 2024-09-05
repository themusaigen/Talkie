local Talkie = require(game.ReplicatedStorage.Talkie)

local server = Talkie.Server(game.ReplicatedStorage.Services, "EventExample")

-- name: string, unreliable: boolean (default = false), middleware
local coolEvent = server:Event("MyCoolEvent")

coolEvent:Connect(function(player, arg)
  print(`{player.Name} triggered the event with arg {arg}`)
end)

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		coolEvent:Fire(player, "Server triggered you, haha!")
	end)
end)

