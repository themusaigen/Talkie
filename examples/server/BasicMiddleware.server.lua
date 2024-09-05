local Talkie = require(game.ReplicatedStorage.Talkie)

local server = Talkie.Server(game.ReplicatedStorage.Services, "BasicMiddlewareExample")

local USE_PLAYER_AS_1ARG = false
local logger
if USE_PLAYER_AS_1ARG then
	logger = function(player, args)
		print("This function uses player as first argument!")
		print(`{player.Name} args:`)

		for k, v in args do
			print(`{k} = {v}`)
		end
	end
else
	logger = function(args)
		print("This function don't uses player as first argument!")

		for k, v in args do
			print(`{k} = {v}`)
		end
	end
end

-- As you can see args passed as table, so you can change/spoof them for all handlers for Event/Function, even Property.

-- You can pass more middlewares: put comma and append another middleware function.
-- Middlewares will called in order they passed.
-- Every middleware can return boolean as first value to mark to continue process remote or cancel it. (true = continue, false = cancel)
-- Middlewares applied to functions can return table as second argument with all return values stored in.
local example = server:Function("ExampleFunction", nil, Talkie.Inbound(logger) + Talkie.Outbound(logger))

--[[
  Cases for Event and Property mostly the same, but...
  ...Property on client will use only Inbound middleware and...
  ...Property on server will use only Outbound middleware
]]

example:Listen(function(player, ...)
  -- Inbound middleware already worked on `...`
	task.spawn(function()
    task.wait(6)
    
    -- Also outbound middleware will work for Invoke
    example:Invoke(player, "hello")
  end)
  -- Outbound middleware will work for this.
  return ...
end)
