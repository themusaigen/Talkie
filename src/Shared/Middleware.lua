local Middleware = {}
Middleware.__index = Middleware
Middleware.__call = function(self, ...: (...any) -> ...any)
	-- Append list of functions to our middleware list.
	self[self._name] = { ... }
	return self
end
Middleware.__add = function(self, middleware)
	assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
	assert(middleware.ToString, `middleware is expected to be instance of Middleware class`)

	-- Append another list of functions to our middleware.
	self[middleware._name] = middleware[middleware._name]
	return self
end

-- Constructs new middleware instance.
function Middleware.new(name: string)
	assert(typeof(name) == "string", `name is expected to be string, got {typeof(name)}`)

	-- Return new middleware.
	return setmetatable({ _name = name }, Middleware)
end

-- Returns the name of parent middleware. Used to check is it middleware.
function Middleware:ToString()
	return self._name
end

-- Export the module.
return { Inbound = Middleware.new("Inbound"), Outbound = Middleware.new("Outbound") }
