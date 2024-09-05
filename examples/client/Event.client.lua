local Talkie = require(game.ReplicatedStorage.Talkie)

local client = Talkie.Client(game.ReplicatedStorage.Services, "EventExample")

-- name: string, middleware
local coolEvent = client:Event("MyCoolEvent")

coolEvent:Connect(function(arg)
  print(`Server triggered the event with arg {arg}`)
end)

coolEvent:Fire("Client triggered you, haha!")
