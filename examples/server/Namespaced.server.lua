-- Load the Talkie.
local Talkie = require(game.ReplicatedStorage.Talkie) -- In your project it might be ReplicatedStorage.Packages.Talkie
-- Or:
-- local Talkie = require(game.ReplicatedStorage.Talkie.Server) IntelliSense only for Server methods

-- Create the instance of Talkie. If you required Talkie directly by your side (Client/Server), you must use `new` method.
local server = Talkie.Server(game.ReplicatedStorage.Services, "MyCoolService")
-- Or the same, but IntelliSense will show Client + Server methods
-- local server = Talkie.new(sameArgs as Above)

-- Create `ExampleFunction` in storage we specified.
local example = server:Function("ExampleFunction")

-- Do something.