
local Talkie = require(game.ReplicatedStorage.Talkie)
local client =
	Talkie.Client(game.ReplicatedStorage.Services, "BasicMiddlewareExample")

-- You can also pass middlewares on client, watch BasicMiddleware.server.lua example
local example = client:Function("ExampleFunction")

--[[
  Cases for Event and Property mostly the same, but...
  ...Property on client will use only Inbound middleware and...
  ...Property on server will use only Outbound middleware
]]

example:Invoke(1, 2, 4, "string", {key = "table given!"})

