-- Buffer: class that wrap default `buffer` library.
local Buffer = {}
Buffer.__index = Buffer
Buffer.__classname = "Buffer"

-- Types for IntelliSense.
local Types = require(script.Parent.Types)

-- Default page size of the buffer
local DEFAULT_BUFFER_SIZE = 32

-- Constructs new buffer.
function Buffer.new(data: buffer | string | number | nil): Types.Buffer
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
		elseif not (typeof(data) == "string") then
			error(`data is expected to be string | buffer | number | nil, got {typeof(data)}`)
		end
	end

	return setmetatable({
		-- Use 32 bytes as default buffer size.
		_buffer = if data then buffer.fromstring(data) else buffer.create(size),
		_readPointer = 0,
		_writePointer = 0
	}, Buffer)
end

function Buffer.Is(buf: table)
	return if typeof(buf) == "table" then buf.__classname == "Buffer" else false
end

-- Reallocation function to prevent out-of-bounds error.
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

	-- Create new buffer.
	local newBuffer = buffer.create(newBufferLen)

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

-- Generate numeric methods.
for friendlyName, bufferMethod in pairs(methods) do
	-- In order not to add unnecessary data about the size of each type, we will calculate it dynamically
	local size = tonumber(bufferMethod:sub(2)) / 8

  -- To add floating point check for integer methods.
	local floating = (bufferMethod:sub(1, 1)) == "f"

	-- Generate read function.
	Buffer[`Read{friendlyName}`] = function(self: Types.Buffer): number
		local value = buffer[`read{bufferMethod}`](self._buffer, self._readPointer)
		self._readPointer += size
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
		buffer[`write{bufferMethod}`](self._buffer, self._writePointer, input)

		-- Shift to the next position.
		self._writePointer += size
	end
end

-- Add `readstring` and `writestring` manually.

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

function Buffer:ReadBuffer(size): Types.Buffer
	return Buffer.new(self:ReadString(size))
end

function Buffer:WriteBoolean(state: boolean)
	assert(typeof(state) == "boolean", `state is expected to be boolean, got {typeof(state)}`)

	-- Write boolean.
	self:WriteUInt8(if state then 1 else 0)
end

function Buffer:ReadBoolean(): boolean
	return self:ReadUInt8() == 1
end

function Buffer:GetNumberOfUnreadBytes(): number
	return buffer.len(self._buffer) - self._readOffset
end

function Buffer:GetNumberOfBytesUsed(): number
	return self._writeOffset
end

function Buffer:IgnoreBytes(count: number)
	assert(typeof(count) == "number", `count is expected to be number, got {typeof(count)}`)
	assert(count > 0, "count is not expected to be less or equal zero")
	assert(count % 1 == 0, "count is not expected to be float")

	self._readOffset += count
end

function Buffer:GetSize()
	return buffer.len(self._buffer)
end

function Buffer:SetWriteOffset(offset: number)
	assert(typeof(offset) == "number", `offset is expected to be number, got {typeof(offset)}`)
	assert(offset >= 0, `offset is not expected to be less or equal zero`)
	assert(offset % 1 == 0, `offset is not expected to be float`)

	self._writeOffset = offset
end

function Buffer:SetReadOffset(offset: number)
	assert(typeof(offset) == "number", `pointoffseter is expected to be number, got {typeof(offset)}`)
	assert(offset >= 0, `offset is not expected to be less or equal zero`)
	assert(offset % 1 == 0, `offset is not expected to be float`)

	self._readOffset = offset
end

function Buffer:ResetWriteOffset()
	self:SetWriteOffset(0)
end

function Buffer:ResetReadOffset()
	self:SetReadOffset(0)
end

function Buffer:ResetOffsets()
	self:ResetReadOffset()
	self:ResetWriteOffset()
end

function Buffer:Reset()
	self:ResetOffsets()

	-- Reset the buffer no recreate it!
	buffer.fill(self._buffer, 0, 0x00)
end

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

function Buffer:GetData(): buffer
  return self._buffer
end

function Buffer:Serialize(): string
	return buffer.tostring(self._buffer)
end

-- Export the module
return Buffer
