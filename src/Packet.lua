--!optimize 2
--!native

--[=[
  @class Packet

  Packets are used to reduce network bandwidth while not losing the readability of the data for the developer.
  Packets uses `BufferIO` API to read & write more complex types like Vector2\3d, CFrame and other.
  Using packets will add 2 bytes overhead for each data to store their ID.

  ```lua
  -- 2 is the ID of the packet, while serializing Packet will add it automatically.
  local PacketShoot = Packet.new(2, {
    {origin = Packet.Types.Vector3},
    {target = Packet.Types.Vector3},
    {weaponId = Packet.Types.UInt8}
  })
  ```
]=]
local Packet = {}
Packet.__index = Packet

-- Types for IntelliSense.
local Types = require(script.Parent.Types)

-- Buffer for serialize/deserialize
local Buffer = require(script.Parent.Buffer)

-- Types-helper for creating model of packet
Packet.Types = require(script.Parent.BufferIO)

--- Creates new packet by provided model and ID.
function Packet.new(id: number, ...: {[string]: Types.TrivialType<any>}): Types.Packet
	assert(typeof(id) == "number", `id is expected to be number, got {typeof(id)}`)
	assert(id >= 0, "id is not expected to be less than zero")
	assert(id % 1 == 0, "id is not expected to be float")
	return setmetatable({ _id = id, _model = { ... } }, Packet)
end

-- Utility function to serialize data.
local function processSerialize(packet: Types.Buffer, model: Types.TypeList<any>, pack: {[string]: any})
	for _, value in ipairs(model) do
		local key, t = next(value)
		if t.write then
			t.write(packet, pack[key])
		else
			processSerialize(t, pack[key])
		end
	end
end

-- Utility to deserialize packet.
local function processDeserialize(packet: Types.Buffer, model: Types.TypeList<any>, skipId: boolean): {[string]: any}
	if skipId then
		packet:IgnoreBytes(2)
	end

	local out = {}
	for _, value in ipairs(model) do
		local key, t = next(value)
		if t.read then
			out[key] = t.read(packet)
		else
			out[key] = processDeserialize(t)
		end
	end
	return out
end

--- Serializes the packet to Talkie`s Buffer instance.
function Packet:Serialize(data: table): Types.Buffer
	-- Create new buffer.
	local packet = Buffer.new()

	-- Add id to buffer.
	packet:WriteUInt16(self._id)

	-- Process.
	processSerialize(packet, self._model, data)

	-- Return serialized packet.
	return packet
end

--- Deserializes the buffer or string to readable data structure.
function Packet:Deserialize(data: Types.Buffer | buffer | string): {[string]: any}
	return processDeserialize(Buffer.new(data), self._model, not Buffer.Is(data))
end

-- Export the module
return Packet
