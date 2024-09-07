local Event = {}
Event.__index = Event

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Signal module required to easily implement middlewares.
local Signal = require(script.Parent.Parent.Shared.Signal)

-- Utility for processing middlewares.
local ProcessMiddleware = require(script.Parent.Parent.Shared.MiddlewareProcessor)

-- Creates new `RemoteEvent` or `UnreliableRemoteEvent` instance and return wrapper for it.
function Event.new(parent: Instance, name: string, unreliable: boolean?, middleware: Types.ServerMiddleware?): Types.ServerEvent
	assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
	assert(typeof(name) == "string", `name is expected to be string, got {typeof(name)}`)
	assert(#name > 0, "name is not expected to be empty")

	-- Typecheck unreliable if present.
	if not (unreliable == nil) then
		assert(typeof(unreliable) == "boolean", `unreliable is expected to be boolean, got {typeof(unreliable)}`)
	end

	-- Typecheck middleware if present.
	if middleware then
		assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
	end

	-- Check for duplicates.
	assert(not parent:FindFirstChild(name), `{name} is not expected to exist, got duplicate`)

	-- Create new remote.
	local remote: RemoteEvent | UnreliableRemoteEvent =
		Instance.new(unreliable and "UnreliableRemoteEvent" or "RemoteEvent")
	remote.Name = name
	remote.Parent = parent

	-- Create new instance.
	local self = setmetatable({
		_remote = remote,
		_signal = Signal.new(),
		_middleware = if middleware then middleware else {},
	}, Event)

	-- Handle OnServerEvent.
	self._remote.OnServerEvent:Connect(function(player, ...)
		-- Pack arguments as always.
		local args = { ... }

		-- Process middleware on them.
		do
			local success = ProcessMiddleware(player, self._middleware.Inbound, args)
			if not success then
				return
			end
		end

		-- Call signal.
		self._signal:Fire(player, table.unpack(args))
	end)

	-- And return it.
	return self
end

-- Appends new connection to the event.
function Event:Connect(handler: Types.ServerHandler): Signal.Connection
	-- Signal don't checks handler param.
	assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)

	return self._signal:Connect(handler)
end

-- Appends new connection that will fired only once.
function Event:Once(handler: Types.ServerHandler): Signal.Connection
	-- Signal don't checks handler param.
	assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)

	return self._signal:Once(handler)
end

-- Yields the current thread until the signal is fired, and returns the arguments fired from the signal.
function Event:Wait(): any
	return self._signal:Wait()
end

--[[
	Fires the event on player or bunch of players with bunch of args.

	```
	game.Players.PlayerAdded:Connect(function(player)
		event:Fire(player, "Hello")
	end)

	event:Fire({player1, player2, player3, ...}, "Hello")
	```
]]
function Event:Fire(player: Player | {Player}, ...: any)
  if typeof(player) == "table" then
    for _, value in player do
      self:Fire(value, ...)
    end
    return
  end

  -- Check this player.
  assert(typeof(player) == "Instance", `player is expected to be Player, got {typeof(player)}`)
  assert(player.ClassName == "Player", `player is expected to be instance of Player, got {player.ClassName}`)

	-- Packing arguments to pass them into middleware.
	local args = { ... }

	-- Process middleware.
	local success = ProcessMiddleware(player, self._middleware.Outbound, args)

	-- If allowed to continue
	if success then
		self._remote:FireClient(player, table.unpack(args))
	end
end

-- Fires all clients on server with bunch of args
function Event:FireAll(...: any)
	-- Packing arguments to pass them into middleware.
	local args = { ... }

	-- Process middleware.
	local success = ProcessMiddleware(nil, self._middleware.Outbound, args)

	-- If allowed to continue
	if success then
		self._remote:FireAllClients(table.unpack(args))
	end
end

-- Fires only clients that passed filter function.
function Event:FireByFilter(filter: (player: Player) -> boolean, ...)
	assert(typeof(filter) == "function", `predicate is expected to be function, got {typeof(filter)}`)

	-- Pass through all players on place.
	for _, player in game.Players:GetPlayers() do
		if filter(player) then
			self:Fire(player, ...)
		end
	end
end

-- Fires all clients expect specific ones.
-- Can pass one player or table of players.
function Event:FireExcept(players: Player | {Player}, ...)
	if typeof(players) == "table" then
		for index, player in players do
			assert(typeof(player) == "Instance", `player is expected to be Instance/Player, got {typeof(player)}`)
			assert(player.ClassName == "Player", `player is expected to be instance of Player, got {player.ClassName}`)

			-- Convert to Set.
			players[player] = true
			players[index] = nil
		end
	else
		assert(typeof(players) == "Instance", `player is expected to be Instance/Player, got {typeof(players)}`)
		assert(players.ClassName == "Player", `player is expected to be instance of Player, got {players.ClassName}`)

		-- Make it as table.
		players = { [players] = true }
	end

	-- Fire.
	self:FireByFilter(function(player)
		return not players[player]
	end, ...)
end

--[[
	Post-method for setup a middleware

	```
	giveWeaponEvent:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
	```
]]
function Event:SetMiddleware(middleware: Types.ServerMiddleware)	
	assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)


	if middleware.Outbound then
		assert(
			typeof(middleware.Outbound) == "table",
			`middleware.Outbound is expected to be table, got {typeof(middleware.Outbound)}`
		)

		-- Assign new middleware.
		self._middleware.Outbound = middleware.Outbound
	end

	if middleware.Inbound then
		assert(
			typeof(middleware.Inbound) == "table",
			`middleware.Inbound is expected to be table, got {typeof(middleware.Outbound)}`
		)

		-- Assign new middleware.
		self._middleware.Inbound = middleware.Inbound
	end
end

-- Destroys the event.
function Event:Destroy()
	self._remote:Destroy()
	self._signal:Destroy()
end

-- Export the module.
return Event
