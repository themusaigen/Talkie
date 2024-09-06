return function()
  beforeAll(function(context)
    context.Talkie = require(game.ReplicatedStorage.Talkie)
    context.AwaitCondition = function(predicate, timeout)
      local begin = os.clock()
      ---@diagnostic disable-next-line: redefined-local
      local timeout = if timeout then timeout else 5

      while true do
        if predicate() then
					return true
				end

				if (os.clock() - begin) > timeout then
					return false
				end

        task.wait()
      end
    end

    -- Wait until PlayerAdded on server will be called.
    game.Players.LocalPlayer.CharacterAdded:Wait()
  end)
end