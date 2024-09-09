local Packet = {}
Packet.__index = Packet

-- Buffer for serialize/deserialize
local Buffer = require(script.Parent.Buffer)

-- Types-helper for creating model of packet
Packet.Types = require(script.Parent.BufferIO)

-- Creates new packet by provided model.
function Packet.new(model: table)
  assert(typeof(model) == "table", `model is expected to be table, got {typeof(model)}`)
  return setmetatable({_model = model}, Packet)
end

function Packet:Serialize(data: table)
  -- Create new buffer to serializing.
  local buf = Buffer.new()

  local function process(model, pack)
    for key, value in pairs(pack) do
      -- Need to check is it not a IO object.
      if  not (model[key].write == nil) then
        model[key].write(buf, value)
      else
        process(model[key], pack[key])
      end
    end
  end

  -- Serialize this data.
  process(self._model, data)

  -- Return the buffer.
  return buf
end

function Packet:Deserialize(data: buffer | string)
  -- Create new buffer to deserializing.
  local buf = Buffer.new(data)

  -- Deserialize this data.
  local function process(model)
    local out = {}
    for key, io in pairs(model) do
      -- Need to check is it not a IO object.
      if io.read then
        out[key] = io.read(buf)
      else
        out[key] = process(io)
      end
    end
    return out
  end

  -- Return result
  return process(self._model)
end

-- Export the module
return Packet