return function()
  beforeAll(function(context)
    context.Talkie = require(game.ReplicatedStorage.Talkie)
    context.Function = require(game.ReplicatedStorage.Talkie.Client.Function)
		context.Event = require(game.ReplicatedStorage.Talkie.Client.Event)
		context.Property = require(game.ReplicatedStorage.Talkie.Client.Property)
  end)
end