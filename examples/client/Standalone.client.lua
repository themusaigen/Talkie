-- Same code from Standalone.server.lua will work good.

-- Standalone version of Function, outside of Talkie`s class.
local Function = require(game.ReplicatedStorage.Talkie.Function)

-- Useful then you use only one entity in service/controller/module/etc
local someCoolFun = Function.new(game.ReplicatedStorage, "SomeFun")

-- Same working with other modules
local Event = require(game.ReplicatedStorage.Talkie.Event)

-- Use standalone version of Event
local someCoolEvent = Event.new(game.ReplicatedStorage, "SomeEvent")