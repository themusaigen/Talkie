local Function = {}
Function.__index = Function
Function.__call = function(self, ...)
	return self:Invoke(...)
end

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Utility function to process inbound/outbound middleware on bunch of args.
function processMiddleware(middleware: Types.ClientMiddlewareList, args: { any })
	if not middleware then
		return true
	end

	for _, dispatch in middleware do
		-- Call this middleware.
		local result, outValue = dispatch(args)

		-- If we want, to return our value, do it.
		if result == false then
			return false, if outValue then outValue else {}
		end
	end

	-- Continue to process anyways.
	return true
end

-- Grabs `RemoteFunction` from the workspace and returns a wrapper for it.
function Function.new(
	parent: Instance,
	name: string,
	handler: Types.ClientHandler?,
	middleware: Types.ClientMiddleware?
): Types.ClientFunction
	assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
	assert(typeof(name) == "string", `name is expected to be string, got {typeof(name)}`)
	assert(#name > 0, "name is not expected to be empty")

	-- Typecheck handler if present.
	if handler then
		assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)
	end

	-- Typecheck middleware if present.
	if middleware then
		assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
	end

	-- Find remote.
	local remote = parent:FindFirstChild(name) :: RemoteFunction
	assert(remote, `RemoteFunction {name} expected to exist, got nil`)

	-- Create instance.
	local self = setmetatable({
		_remote = remote,
		_middleware = if middleware then middleware else {},
		_handler = nil,
	}, Function)

	-- Attach handler if present.
	if handler then
		self:Listen(handler)
	end

	-- Attach OnClientInvoke.
	remote.OnClientInvoke = function(...)
		-- Don't do anything without handler present.
		if not self._handler then
			return
		end

		-- Pack arguments into the table.
		local args = { ... }

		-- Proccess it with inbound middleware.
		do
			local result, outPack = processMiddleware(self._middleware.Inbound, args)
			if result == false then
				return table.unpack(outPack)
			end
		end

		-- Call our handler.
		local out = { self._handler(table.unpack(args)) }

		-- Process it with onbound middleware.
		do
			local result, outPack = processMiddleware(self._middleware.Outbound, out)
			if result == false then
				return table.unpack(outPack)
			end
		end

		-- Return handler`s out values.
		return table.unpack(out)
	end

	-- Return instance.
	return self
end

--[[
	Assigns new handler that will called then server invokes the remote.
]]
function Function:Listen(handler: Types.ClientHandler)
	-- Typecheck handler if present.
	if handler then
		assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)
	end

	self._handler = handler
end

--[[
	Invokes a function on the server.

	```
	wantEatPizza:Invoke("I am hungry!")
	wantEatPizza("I am hungry!")
	```
]]
function Function:Invoke(...)
	-- Pack arguments into the table.
	local args = { ... }

	-- Process it with our middleware.
	local result, out = processMiddleware(self._middleware.Outbound, args)
	if result then
		return self._remote:InvokeServer(table.unpack(args))
	else
		-- If we want to spoof values returned to client -> do it.
		return table.unpack(out)
	end
end

--[[
	Post-method for setup a middleware

	```
	wantEatPizza:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
	```
]]
function Function:SetMiddleware(middleware: Types.ClientMiddleware)
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

-- Export the module.
return Function
