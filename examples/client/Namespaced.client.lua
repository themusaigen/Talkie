-- Load the Talkie.
local Talkie = require(game.ReplicatedStorage.Talkie) -- In your project it might be ReplicatedStorage.Packages.Talkie
-- Or:
-- local Talkie = require(game.ReplicatedStorage.Talkie.Client) IntelliSense only for client methods

-- Create the instance of Talkie. If you required Talkie directly by your side (Client/Server), you must use `new` method.
local client =
	Talkie.Client(game.ReplicatedStorage.Services, "MyCoolService")
-- Or the same, but IntelliSense will show Client + Server methods
-- local client = Talkie.new(sameArgs as Above)

-- Grab the RemoteFunction from storage we specified.
local example = client:Function("ExampleFunction")

-- Do something.