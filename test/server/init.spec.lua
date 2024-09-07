return function()
	beforeAll(function(context)
		context.Talkie = require(game.ReplicatedStorage.Talkie)
		context.Function = require(game.ReplicatedStorage.Talkie.Server.Function)
		context.Event = require(game.ReplicatedStorage.Talkie.Server.Event)
		context.Property = require(game.ReplicatedStorage.Talkie.Server.Property)
	end)
end
