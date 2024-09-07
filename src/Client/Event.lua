local Event = {}
Event.__index = Event

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Shared.Types)

-- Signal module required to easily implement middlewares.
local Signal = require(script.Parent.Parent.Shared.Signal)

-- Utility function to process inbound/outbound middleware on bunch of args.
function processMiddleware(middleware: Types.ClientMiddlewareList, args: { any })
	if not middleware then
		return true
	end

	for _, dispatch in middleware do
		-- Call this middleware.
		local result: boolean?, outValue: table? = dispatch(args)

		-- If we want to return our value -> do it.
		if result == false then
			return false, if outValue then outValue else {}
		end
	end

	-- Continue to process anyways.
	return true
end

-- Grabs `RemoteEvent` or `UnreliableRemoteEvent` instance and return wrapper for it.
function Event.new(parent: Instance, name: string, middleware: Types.ClientMiddleware?): Types.ClientEvent
	assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
	assert(typeof(name) == "string", `name is expected to be string, got {typeof(name)}`)
	assert(#name > 0, "name is not expected to be empty")

	-- Typecheck middleware if present.
	if middleware then
		assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
	end

	-- Find remote.
	local remote = parent:FindFirstChild(name) :: RemoteEvent | UnreliableRemoteEvent
	assert(remote, `RemoteEvent {name} expected to exist, got nil`)

	-- Create new instance.
	local self = setmetatable({
		_remote = remote,
		_signal = Signal.new(),
		_middleware = if middleware then middleware else {},
	}, Event)

	-- Handle OnServerEvent.
	self._remote.OnClientEvent:Connect(function(...)
		-- Pack arguments as always.
		local args = { ... }

		-- Process middleware on them.
		do
			local success = processMiddleware(self._middleware.Inbound, args)
			if not success then
				return
			end
		end

		-- Call signal.
		self._signal:Fire(table.unpack(args))
	end)

	-- And return it.
	return self
end

-- Appends new connection to the event.
function Event:Connect(handler: Types.ClientHandler): Signal.Connection
	-- Signal don't checks handler param.
	assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)

	return self._signal:Connect(handler)
end

-- Appends new connection that will fired only once.
function Event:Once(handler: Types.ClientHandler): Signal.Connection
	-- Signal don't checks handler param.
	assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)

	return self._signal:Once(handler)
end

-- Yields the current thread until the signal is fired, and returns the arguments fired from the signal.
function Event:Wait()
	return self._signal:Wait()
end

-- Fires the event on server with middlewares applied.
function Event:Fire(...: any)
	-- Packing arguments to pass them into middleware.
	local args = { ... }

	-- Process middleware.
	local success = processMiddleware(self._middleware.Outbound, args)

	-- If allowed to continue
	if success then
		self._remote:FireServer(table.unpack(args))
	end
end

--[[
	Post-method for setup a middleware

	```
	giveWeaponEvent:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
	```
]]
function Event:SetMiddleware(middleware: Types.ClientMiddleware)
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
	self._signal:Destroy()
end

-- Export the module.
return Event
