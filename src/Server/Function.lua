--- @class Server.Function
--- @server
--- Serverside wrapper over [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction)
local Function = {}
Function.__index = Function
Function.__call = function(self, player: Player, ...: any): any
  return self:Invoke(player, ...)
end

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Utility for processing middlewares.
local ProcessMiddleware = require(script.Parent.Parent.Shared.MiddlewareProcessor)

--[=[
  Creates new [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction) and returns wrapper over it.

  ```lua
  local function typecheckForNumber(args)
    for k, v in args do
      if not (typeof(v) == "number") then
        -- Cancel other middleware and RemoteFunction handler.
        return false
      end
    end
  end

  local function logger(args)
    for k, v in args do
      print(`{k} = {v}`)
    end
  end

  local function doubleArgs(args)
    for k, v in args do
      if typeof(v) == "number" then
        args[k] *= 2
      end
    end
  end

  -- Only numbers allowed.
  local fun = server:Function("MyFunction", function(player, arg)
    print(`Player {player.Name} send us arg: {arg}`)
    return 42
  end, Talkie.Inbound(typecheckForNumber, logger) + Talkie.Outbound(doubleArgs))
  ```
  @within Server.Function
]=]
function Function.new(
  parent: Instance,
  name: string,
  handler: Types.ServerCallback?,
  middleware: Types.ServerMiddleware?
): Types.ServerFunction
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

  -- No duplicates.
  assert(not parent:FindFirstChild(name), `{name} is not expected to exist, choose another name`)

  -- Create remote.
  local remote = Instance.new("RemoteFunction")
  remote.Name = name
  remote.Parent = parent

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

  -- Attach onServerInvoke
  remote.OnServerInvoke = function(player: Player, ...)
    -- Don't do anything without handler present.
    if not self._handler then
      return
    end

    -- Pack arguments into the table.
    local args = { ... }

    -- Proccess it with inbound middleware.
    do
      local result, outPack = ProcessMiddleware(player, self._middleware.Inbound, args)
      if result == false then
        return table.unpack(outPack)
      end
    end

    -- Call our handler.
    local out = { self._handler(player, table.unpack(args)) }

    -- Process it with onbound middleware.
    do
      local result, outPack = ProcessMiddleware(player, self._middleware.Outbound, out)
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

--[=[
  Assigns new handler that will called then client invokes the remote.

  ```lua
  fun:Listen(function(player, arg1, arg2)
    -- If middleware present, they also will be applied to this handler.
    print(`{player.Name} called us with arg1 {arg1} and {arg2}`)
  end)
  ```

  @within Server.Function
]=]
function Function:Listen(handler: Types.ServerCallback)
  -- Typecheck handler if present.
  if handler then
    assert(typeof(handler) == "function", `handler is expected to be function, got {typeof(handler)}`)
  end

  self._handler = handler
end

--[=[
  Invokes a function on the player with bunch of args.

  ```lua
  game.Players.PlayerAdded:Connect(function(player)
    fun:Invoke(player, ...)

    -- You can also use this variant.
    fun(player, ...)
  end)
  ```

  @within Server.Function
]=]
function Function:Invoke(player: Player, ...: any): ...any
  -- Pack arguments into the table.
  local args = { ... }

  -- Process it with our middleware.
  local result, out = ProcessMiddleware(player, self._middleware.Outbound, args)
  if result then
    return self._remote:InvokeClient(player, table.unpack(args))
  else
    -- If we want to spoof values returned to server -> do it.
    return table.unpack(out)
  end
end

--[=[
  Post-method for setup a middleware.

  ```lua
  fun:SetMiddleware(Talkie.Inbound(...) + Talkie.Outbound(...))
  ```

  @within Server.Function
]=]
function Function:SetMiddleware(middleware: Types.ServerMiddleware)
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

--[=[
  Destroys the [RemoteFunction](https://developer.roblox.com/en-us/api-reference/class/RemoteFunction).

  @within Server.Function
]=]
function Function:Destroy()
  self._remote:Destroy()
end

-- Export module.
return Function
