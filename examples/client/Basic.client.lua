-- Load the Talkie.
local Talkie = require(game.ReplicatedStorage.Talkie) -- In your project it might be ReplicatedStorage.Packages.Talkie
-- Or:
-- local Talkie = require(game.ReplicatedStorage.Talkie.Client) IntelliSense only for client methods

-- Create the instance of Talkie. If you required Talkie directly by your side (Client/Server), you must use `new` method.
local client =
	Talkie.Client(--[[Package: ReplicatedStorage.SomeFolder/Services, etc...]] --[[, namespace: "MyService"]])
-- Or the same, but IntelliSense will show Client + Server methods
-- local client = Talkie.new(sameArgs as Above)

-- Grab the RemoteFunction from storage.
-- NOTE: On client these methods only grabs remotes, not create!
local example = client:Function("ExampleFunction")

-- Another remotes, like Event, Property, etc...
--[[ Or auto-parse method.
  local remotes = client:Parse()
  local example = remotes.ExampleFunction
]]

example:Listen(function(arg)
	print(`Server told us: {arg}`)
end)

example:Invoke("Hello, server!")
