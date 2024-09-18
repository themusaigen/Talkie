--- @class Server.Property
--- @server
local Property = {}
Property.__index = Property

-- Types for IntelliSense.
local Types = require(script.Parent.Parent.Types)

-- Property based on reliable Event module.
local Event = require(script.Parent.Event)

-- None constant used for understanding return nil or initial value.
local NONE = newproxy()

--[=[
  Creates new `RemoteEvent` on workspace and returns property wrapper over it.

  ```lua
  -- All players will have 0 by default.
  local property = server:Property("MyScoreProperty", 0)

  game.Players.PlayerAdded:Connect(function(player)
    -- Getting score from our real and cool database.
    local score = MagicDatabase:GetProperty("game.score", player)

    -- Set only for this player his score.
    -- Everything will be automatically handled by Talkie on Server and Client.
    property:SetFor(player, score)
  end)
  ```

  @within Server.Property
]=]
function Property.new(
  parent: Instance,
  name: string,
  initial: any,
  middleware: Types.ServerMiddleware?
): Types.ServerProperty
  assert(typeof(parent) == "Instance", `parent is expected to be Instance, got {typeof(parent)}`)
  assert(typeof(name) == "string", `name is expected to be string, got {typeof(name)}`)
  assert(#name > 0, `name is not expected to be empty`)

  -- Typecheck middleware if present.
  if middleware then
    assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)
  end

  -- Check for duplicates
  assert(not parent:FindFirstChild(name), `{name} is not expected to exist, got duplicate`)

  -- Create new instance
  local self = setmetatable({
    _initial = initial,
    _perPlayer = {},
    _middleware = {
      Outbound = if middleware then if middleware.Outbound then middleware.Outbound else {} else {},
    },
  }, Property)

  -- Create event.
  self._event = Event.new(parent, name, false, self._middleware)

  -- Handle player remove.
  self._playerRemoving = game.Players.PlayerRemoving:Connect(function(player)
    self:ClearFor(player)
  end)

  -- Add tag for client`s `Parse` method implementation.
  self._event._remote:AddTag("TalkieProperty")

  -- Synchronize with any player their values in any conditions.
  self._event:Connect(function(player)
    local outValue
    local playerValue = self._perPlayer[player]
    if playerValue == nil then
      outValue = self._initial
    elseif playerValue == NONE then
      outValue = nil
    else
      outValue = playerValue
    end

    -- Event will be fired with middleware applied.
    self._event:Fire(player, outValue)
  end)

  -- Return this instance.
  return self
end

-- Deep clone util implementation
local function deepclone(list: { ["string"]: any } | any)
  if not (typeof(list) == "table") then
    return list
  end

  local clone = table.clone(list)
  for key, value in pairs(list) do
    clone[key] = deepclone(value)
  end
  return clone
end

--[[
  SetX functions used for apply new initial value on all player or specific one.

  ```lua
  property:Set(2) -- Will set 2 for all players as base value and clear the custom one.
  property:SetFor(player22, 24) -- Will set 24 only for player22.
  property:SetTop(24) -- Will set 24 only for players that don't have custom data was set by `SetFor`.
  property:SetByFilter(filter, 24) -- Will set 24 only for playrs that pass the filter.
  ```
]]

--[=[
  Set new value for all players and clear all custom one.

  ```lua
  property:Set(2) -- Will set 2 for all players as base value and clear the custom one.
  ```

  @within Server.Property
]=]
function Property:Set(value: any)
  -- Assign new value.
  self._initial = value

  -- Remove any custom data.
  table.clear(self._perPlayer)

  -- Notify players about that.
  self._event:FireAll(value)
end

--[=[
  Set new value only for specific player or players.

  ```lua
  property:SetFor(player22, 24) -- Will set 24 only for player22.

  -- Or for players.
  property:SetFor({player22, player34}, 24) -- Will set 24 only for player22 and player34.
  ```

  @within Server.Property
]=]
function Property:SetFor(player: Player | { Player }, value: any)
  -- If table was given.
  if typeof(player) == "table" then
    for _, player0 in player do
      self:SetFor(player0, value)
    end
    return
  end

  -- Check this player.
  assert(typeof(player) == "Instance", `player is expected to be Player, got {typeof(player)}`)
  assert(player.ClassName == "Player", `player is expected to be instance of Player, got {player.ClassName}`)

  -- Assign new value for this player.
  self._perPlayer[player] = if value == nil then NONE else value
  self._event:Fire(player, value)
end

--[=[
  Set new value for new players or players that don't have custom one.

  ```lua
  -- Will set 24 only for players that don't have custom data was set by `SetFor`.
  property:SetTop(24)
  ```

  @within Server.Property
]=]
function Property:SetTop(value: any)
  self._initial = value

  -- Set and avoid custom data.
  for _, player in ipairs(game.Players:GetPlayers()) do
    if self._perPlayer[player] == nil then
      self._event:Fire(player, value)
    end
  end
end

--[=[
  Sets the value only for players passed the filter.

  ```lua
  local function filter(player: Player, value: number): boolean
    return not (player.Name == "SayMyName")
  end

  -- Set 24 as value for all players if their nickname is not `SayMyName`
  property:SetByFilter(filter, 24)
  ```

  @within Server.Property
]=]
function Property:SetByFilter(filter: Types.ServerSetFilter, value: any)
  assert(typeof(filter) == "function", `filter is expected to be function, got {typeof(filter)}`)

  -- Assign new data
  for _, player in ipairs(game.Players:GetPlayers()) do
    if filter(player, value) then
      self:SetFor(player, value)
    end
  end
end

--- Returns the value for specific player.
--- @within Server.Property
function Property:GetFor(player: Player): any
  assert(typeof(player) == "Instance", `player is expected to be Player, got {typeof(player)}`)
  assert(player.ClassName == "Player", `player is expected to be instance of Player, got {player.ClassName}`)

  -- Get value for this player.
  local value = self._perPlayer[player]
  if value == nil then
    -- In this case, we must return cloned table to prevent writing in initial...
    -- ...table that will affect other players while them connected.
    if typeof(self._initial) == "table" then
      self._perPlayer[player] = deepclone(self._initial)
      return self._perPlayer[player]
    else
      return self._initial
    end
  else
    return value
  end
end

--[[
  ClearX methods used for removing player data for specific players. (or ClearAll)
]]

--[=[
  Clears custom data for specific player or players.

  ```lua
  property:ClearFor(player2)
  property:ClearFor({player2, player3, ...})
  ```

  @within Server.Property
]=]
function Property:ClearFor(player: Player | { Player })
  -- If table was given.
  if typeof(player) == "table" then
    for _, player0 in player do
      self:ClearFor(player0)
    end
    return
  end

  assert(typeof(player) == "Instance", `player is expected to be Player, got {typeof(player)}`)
  assert(player.ClassName == "Player", `player is expected to be instance of Player, got {player.ClassName}`)

  -- Check if any value exist.
  if self._perPlayer[player] == nil then
    return
  end

  -- Value exist, remove it.
  self._perPlayer[player] = nil
  self._event:Fire(player, self._initial)
end

--- Clear custom data for all players.
--- @within Server.Property
function Property:ClearAll()
  for player in pairs(self._perPlayer) do
    self:ClearFor(player)
  end
end

--[=[
  Clear custom data for players passed the filter.

  ```lua
  local function filter(player: Player): boolean
    return player.Name == "SayMyName"
  end

  -- Clear data for player with nickname `SayMyName`
  property:ClearByFilter(filter)
  ```

  @within Server.Property
]=]
function Property:ClearByFilter(filter: Types.ServerFilter)
  assert(typeof(filter) == "function", `filter is expected to be function, got {typeof(filter)}`)

  -- Clear now.
  for player in pairs(self._perPlayer) do
    if filter(player) then
      self:ClearFor(player)
    end
  end
end

--[=[
  Post-method for setup a middleware.
  Only outbound middleware is used bc of nature of ServerProperty.

  ```lua
  property:SetMiddleware(Talkie.Outbound(...))
  ```

  @within Server.Property
]=]
function Property:SetMiddleware(middleware: Types.ServerMiddleware)
  assert(typeof(middleware) == "table", `middleware is expected to be table, got {typeof(middleware)}`)

  if middleware.Outbound then
    assert(
      typeof(middleware.Outbound) == "table",
      `middleware.Outbound is expected to be table, got {typeof(middleware.Outbound)}`
    )

    -- Assign new middleware.
    self._middleware.Outbound = middleware.Outbound
  end
end

--- Destroys the property.
--- @within Server.Property
function Property:Destroy()
  self._event:Destroy()
  self._playerRemoving:Disconnect()
end

-- Export the module
return Property
