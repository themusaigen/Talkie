--!optimize 2
--!native

--- @class Buffer
--- Wrapper over builtin [buffer](https://create.roblox.com/docs/reference/engine/libraries/buffer) library.
local Buffer = {}
Buffer.__index = Buffer
Buffer.__classname = "Buffer"

-- Types for IntelliSense.
local Types = require(script.Parent.Types)

-- Default page size of the buffer
local DEFAULT_BUFFER_SIZE = 32

--- Constructs new buffer.
--- @within Buffer
function Buffer.new(data: Types.Buffer | buffer | string | number | nil): Types.Buffer
  -- Don't create buffer from another buffer.
  if Buffer.Is(data) then
    return data
  end

  -- Assert data if provided.
  local size = DEFAULT_BUFFER_SIZE
  if data then
    -- If got buffer -> translate to string
    if typeof(data) == "buffer" then
      data = buffer.tostring(data)
    elseif typeof(data) == "number" then
      size = data
      data = nil

      -- why not
      if not (size % 2 == 0) then
        size += 1
      end
    elseif not (typeof(data) == "string") then
      error(`data is expected to be string | buffer | number | nil, got {typeof(data)}`)
    end
  end

  return setmetatable({
    -- Use 32 bytes as default buffer size.
    _buffer = if data then buffer.fromstring(data) else buffer.create(size),
    _readOffset = 0,
    _writeOffset = 0,
  }, Buffer)
end

--- Check is value Buffer`s instance.
function Buffer.Is(buf: table)
  return if typeof(buf) == "table" then buf.__classname == "Buffer" else false
end

--- Autoresize method is used to prevent out-of-bounds error.
--- Used for internal Buffer`s methods.
function Buffer:Resize(len: number)
  assert(typeof(len) == "number", `len is expected to be number, got {typeof(len)}`)
  assert(len > 0, `len is not expected to be less than zero`)
  assert(len % 1 == 0, `len is not expected to be float`)

  local bufferLen = buffer.len(self._buffer)
  if (self._writeOffset + len) < bufferLen then
    return
  end

  local newBufferLen

  -- To avoid unnecessary realocations, we will increase the buffer size several times
  if bufferLen > len then
    newBufferLen = bufferLen * 2
  else
    newBufferLen = bufferLen + len + DEFAULT_BUFFER_SIZE

    -- I don't think this useful but why not
    if not (newBufferLen % 2 == 0) then
      newBufferLen += 1
    end
  end

  -- Reallocate buffer.
  self:Realloc(newBufferLen)
end

--- Force reallocation method with specified size.
function Buffer:Realloc(len: number)
  assert(typeof(len) == "number", `len is expected to be number, got {typeof(len)}`)
  assert(len > 0, `len is not expected to be less than zero`)
  assert(len % 1 == 0, `len is not expected to be float`)

  -- Create new buffer.
  local newBuffer = buffer.create(len)

  -- Copy origin bytes.
  buffer.copy(newBuffer, 0, self._buffer)

  -- Reassign buffer.
  self._buffer = newBuffer
end

-- Code generate.
local methods = {
  Int8 = "i8",
  UInt8 = "u8",
  Int16 = "i16",
  UInt16 = "u16",
  Int32 = "i32",
  UInt32 = "u32",
  Float = "f32",
  Float32 = "f32",
  Float64 = "f64",
}

--[=[
  @method ReadInt8
  @return number
  @within Buffer

  Returns a number in range [-128; 127]
]=]

--[=[
  @method ReadUInt8
  @return number
  @within Buffer

  Returns a number in range [0; 255]
]=]

--[=[
  @method ReadInt16
  @return number
  @within Buffer

  Returns a number in range [-32768; 32767]
]=]

--[=[
  @method ReadUInt16
  @return number
  @within Buffer

  Returns a number in range [0; 65535].
]=]

--[=[
  @method ReadInt32
  @return number
  @within Buffer

  Returns a number in range [-2'147'483'648; 2'147'483'647]
]=]

--[=[
  @method ReadUInt32
  @return number
  @within Buffer

  Returns a number in range [0; 4'294'967'295]
]=]

--[=[
  @method ReadFloat
  @return number
  @within Buffer

  Returns a floating point (32 bits) number.
]=]

--[=[
  @method ReadFloat32
  @return number
  @within Buffer

  Returns a floating point (32 bits) number.
]=]

--[=[
  @method ReadFloat64
  @return number
  @within Buffer

  Returns a floating point (64 bits) number.
]=]

--[=[
  @method WriteInt8
  @param value number -- Integer. Floating point will throw the error.
  @within Buffer

  Writes a number in range [-128; 127]
]=]

--[=[
  @method WriteUInt8
  @param value number -- Integer. Floating point will throw the error.
  @within Buffer

  Writes a number in range [0; 255]
]=]

--[=[
  @method WriteInt16
  @param value number -- Integer. Floating point will throw the error.
  @within Buffer

  Writes a number in range [-32768; 32767]
]=]

--[=[
  @method WriteUInt16
  @param value number -- Integer. Floating point will throw the error.
  @within Buffer

  Writes a number in range [0; 65535]
]=]

--[=[
  @method WriteInt32
  @param value number -- Integer. Floating point will throw the error.
  @within Buffer

  Writes a number in range [-2'147'483'648; 2'147'483'647]
]=]

--[=[
  @method WriteUInt32
  @param value number -- Integer. Floating point will throw the error.
  @within Buffer

  Writes a number in range [0; 4'294'967'295]
]=]

--[=[
  @method WriteFloat
  @param value number
  @within Buffer

  Writes a floating point (32 bits) value.
]=]

--[=[
  @method WriteFloat32
  @param value number
  @within Buffer

  Writes a floating point (32 bits) value.
]=]

--[=[
  @method WriteFloat64
  @param value number
  @within Buffer

  Writes a floating point (64 bits) value.
]=]

-- Generate numeric methods.
for friendlyName, bufferMethod in pairs(methods) do
  -- In order not to add unnecessary data about the size of each type, we will calculate it dynamically
  local size = tonumber(bufferMethod:sub(2)) / 8

  -- To add floating point check for integer methods.
  local floating = (bufferMethod:sub(1, 1)) == "f"

  -- Generate read function.
  Buffer[`Read{friendlyName}`] = function(self: Types.Buffer): number
    local value = buffer[`read{bufferMethod}`](self._buffer, self._readOffset)
    self._readOffset += size
    return value
  end

  -- Generate write function.
  Buffer[`Write{friendlyName}`] = function(self: Types.Buffer, input: number)
    assert(type(input) == "number", `value is expected to be number, got {typeof(input)}`)

    -- Check only for unsigned and signed integers.
    if not floating then
      assert(input % 1 == 0, `input is not expected to be floating point`)
    end

    -- Realloc if needed.
    self:Resize(size)

    -- Write value to the buffer.
    buffer[`write{bufferMethod}`](self._buffer, self._writeOffset, input)

    -- Shift to the next position.
    self._writeOffset += size
  end
end

--- Reads the string from buffer.
function Buffer:ReadString(len: number): string
  assert(typeof(len) == "number", `len is expected to be number, got {typeof(len)}`)
  assert(len > 0, `len is not expected to be less than zero`)
  assert(len % 1 == 0, `len is not expected to be float`)

  -- If len > bufferLen, cut it.
  local bufferLen = buffer.len(self._buffer)
  if len > bufferLen then
    warn("Length of the required string is greater than buffer length!")

    len = bufferLen - 1
  end

  -- Read the string.
  local str = buffer.readstring(self._buffer, self._readOffset, len)

  -- Shift the read pointer.
  self._readOffset += len

  -- And return string.
  return str
end

--- Writes the string in buffer.
function Buffer:WriteString(str: string)
  assert(typeof(str) == "string", `str is expected to be string, got {typeof(str)}`)

  if #str <= 0 then
    return
  end

  -- Resize.
  self:Resize(#str)

  -- Write.
  buffer.writestring(self._buffer, self._writeOffset, str)

  -- Shift the write pointer.
  self._writeOffset += #str
end

--- Writes other buffer into self.
function Buffer:WriteBuffer(input: Types.Buffer | buffer | string)
  if Buffer.Is(input) then
    self:WriteString(input:Serialize())
  elseif typeof(input) == "buffer" then
    self:WriteString(buffer.tostring(input))
  elseif typeof(input) == "string" then
    self:WriteString(input)
  else
    error(`Non-expected data type {typeof(input)} was provided to Buffer::WriteBuffer`)
  end
end

--- Reads wrapper class from [buffer](https://create.roblox.com/docs/reference/engine/libraries/buffer)
function Buffer:ReadBuffer(size: number): Types.Buffer
  return Buffer.new(self:ReadString(size))
end

--- Writes a boolean.
function Buffer:WriteBoolean(state: boolean)
  assert(typeof(state) == "boolean", `state is expected to be boolean, got {typeof(state)}`)

  -- Write boolean.
  self:WriteUInt8(if state then 1 else 0)
end

--- Reads a boolean.
function Buffer:ReadBoolean(): boolean
  return self:ReadUInt8() == 1
end

--- Returns number of unread bytes.
function Buffer:GetNumberOfUnreadBytes(): number
  return buffer.len(self._buffer) - self._readOffset
end

--- Returns number of bytes already written.
function Buffer:GetNumberOfBytesUsed(): number
  return self._writeOffset
end

--- Ignore specific amount of bytes. Useful then you want to ignore packetId or unnecessary data.
function Buffer:IgnoreBytes(count: number)
  assert(typeof(count) == "number", `count is expected to be number, got {typeof(count)}`)
  assert(count > 0, "count is not expected to be less or equal zero")
  assert(count % 1 == 0, "count is not expected to be float")

  self._readOffset += count
end

--- Returns the length of buffer. [buffer.len](https://create.roblox.com/docs/reference/engine/libraries/buffer#len) used underhood.
function Buffer:GetSize(): number
  return buffer.len(self._buffer)
end

--- Shifts the write cursor.
function Buffer:SetWriteOffset(offset: number)
  assert(typeof(offset) == "number", `offset is expected to be number, got {typeof(offset)}`)
  assert(offset >= 0, `offset is not expected to be less or equal zero`)
  assert(offset % 1 == 0, `offset is not expected to be float`)

  self._writeOffset = offset
end

--- Shifts the read cursor.
function Buffer:SetReadOffset(offset: number)
  assert(typeof(offset) == "number", `pointoffseter is expected to be number, got {typeof(offset)}`)
  assert(offset >= 0, `offset is not expected to be less or equal zero`)
  assert(offset % 1 == 0, `offset is not expected to be float`)

  self._readOffset = offset
end

--- Resets write cursor by setting it to 0.
function Buffer:ResetWriteOffset()
  self:SetWriteOffset(0)
end

--- Resets read cursor by setting it to 0.
function Buffer:ResetReadOffset()
  self:SetReadOffset(0)
end

--- Resets all offsets.
function Buffer:ResetOffsets()
  self:ResetReadOffset()
  self:ResetWriteOffset()
end

--- Resets all offsets and fill buffer as 0x00 for all length.
function Buffer:Reset()
  self:ResetOffsets()

  -- Reset the buffer no recreate it!
  buffer.fill(self._buffer, 0, 0x00)
end

--- Sets new data.
function Buffer:SetData(data: Types.Buffer | buffer | string)
  self:ResetOffsets()

  if Buffer.Is(data) then
    self._buffer = data:GetData()
  elseif typeof(data) == "string" then
    self._buffer = buffer.fromstring(data)
  elseif typeof(data) == "buffer" then
    self._buffer = data
  else
    error(`Non-expected data type {typeof(data)} was provided to Buffer::SetData`)
  end
end

--- Returns [buffer](https://create.roblox.com/docs/reference/engine/libraries/buffer) to network replicate.
function Buffer:GetData(): buffer
  return self._buffer
end

--- Serializes buffer. [buffer.tostring](https://create.roblox.com/docs/reference/engine/libraries/buffer#tostring) used underhood.
function Buffer:Serialize(): string
  return buffer.tostring(self._buffer)
end

-- Export the module
return Buffer
