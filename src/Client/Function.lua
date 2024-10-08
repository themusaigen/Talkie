--- @class Client.Function
--- @client
--- Clientside wrapper over [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction)
local Function = {}
Function.__index = Function
Function.__call = function(self, ...)
  return self:Invoke(...)
end

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Utility for processing middlewares.
local ProcessMiddleware = require(script.Parent.Parent.Shared.MiddlewareProcessor)

--[=[
  Grabs [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction) from the workspace and returns a wrapper for it.

  ```lua
  local fun = client:Function("MyFunction")

  fun(42) -- or fun:Invoke
  ```

  @within Client.Function
]=]
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
      local result, outPack = ProcessMiddleware(self._middleware.Inbound, args)
      if result == false then
        return table.unpack(outPack)
      end
    end

    -- Call our handler.
    local out = { self._handler(table.unpack(args)) }

    -- Process it with onbound middleware.
    do
      local result, outPack = ProcessMiddleware(self._middleware.Outbound, out)
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

--- Assigns new handler that will called then server invokes the remote.
--- @within Client.Function
function Function:Listen(handler: Types.ClientHandler)
  -- Typecheck handler if present.
  if handler then
    assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)
  end

  self._handler = handler
end

--[=[
  Invokes a function on the server.

  ```lua
  event:Invoke("I am hungry!")
  event("I am hungry!")
  ```

  @within Client.Function
]=]
function Function:Invoke(...: any): any
  -- Pack arguments into the table.
  local args = { ... }

  -- Process it with our middleware.
  local result, out = ProcessMiddleware(self._middleware.Outbound, args)
  if result then
    return self._remote:InvokeServer(table.unpack(args))
  else
    -- If we want to spoof values returned to client -> do it.
    return table.unpack(out)
  end
end

--[=[
  Post-method for setup a middleware

  ```lua
  event:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
  ```

  @within Client.Function
]=]
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
      `middleware.Inbound is expected to be table, got {typeof(middleware.Inbound)}`
    )

    -- Assign new middleware.
    self._middleware.Inbound = middleware.Inbound
  end
end

-- Export the module.
return Function
