-- Load the Talkie.
local Talkie = require(game.ReplicatedStorage.Talkie) -- In your project it might be ReplicatedStorage.Packages.Talkie
-- Or:
-- local Talkie = require(game.ReplicatedStorage.Talkie.Server) IntelliSense only for Server methods

-- Create the instance of Talkie. If you required Talkie directly by your side (Client/Server), you must use `new` method.
local server = Talkie.Server(--[[Package: ReplicatedStorage.SomeFolder/Services/etc...]] --[[, namespace: "MyService"]])
-- Or the same, but IntelliSense will show Client + Server methods
-- local server = Talkie.new(sameArgs as Above)

-- Create `ExampleFunction`.
-- NOTE: On server these methods only creates remotes, not grabs!
local example = server:Function("ExampleFunction")

-- Another remotes creation, like Event, Property, etc...

example:Listen(function(player, arg)
	print(`{player.Name} told us: {arg}`)
end)

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		example:Invoke(player, "Hello, client!")
	end)
end)
