-- Buffer: class that wrap default `buffer` library.
local Buffer = {}
Buffer.__index = Buffer

-- Default page size of the buffer
local DEFAULT_BUFFER_SIZE = 32

-- Constructs new buffer.
function Buffer.new(data: buffer | string | nil)
  -- Assert data if provided.
	if data then
    -- If got buffer -> translate to string
    if typeof(data) == "buffer" then
      data = buffer.tostring(data)
    end

    -- Verify string is provided.
		assert(typeof(data) == "string", `data is expected to be string, got {typeof(data)}`)
	end

	return setmetatable({
		-- Use 32 bytes as default buffer size.
		_buffer = if data then buffer.fromstring(data) else buffer.create(DEFAULT_BUFFER_SIZE),
		_readPointer = 0,
		_writePointer = 0
	}, Buffer)
end

-- Reallocation function to prevent out-of-bounds error.
function Buffer:Resize(len: number)
	assert(typeof(len) == "number", `len is expected to be number, got {typeof(len)}`)
	assert(len > 0, `len is not expected to be less than zero`)
	assert(len % 1 == 0, `len is not expected to be float`)

	local bufferLen = buffer.len(self._buffer)
	if (self._writePointer + len) < bufferLen then
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
	Buffer[`Read{friendlyName}`] = function(self)
		local value = buffer[`read{bufferMethod}`](self._buffer, self._readPointer)
		self._readPointer += size
		return value
	end

	-- Generate write function.
	Buffer[`Write{friendlyName}`] = function(self, value: number)
		assert(type(value) == "number", `value is expected to be number, got {typeof(value)}`)

		-- Check only for unsigned and signed integers.
		if not floating then
			assert(value % 1 == 0, `value is not expected to be floating point`)
		end

		-- Realloc if needed.
		self:Resize(size)

		-- Write value to the buffer.
		buffer[`write{bufferMethod}`](self._buffer, self._writePointer, value)

		-- Shift to the next position.
		self._writePointer += size
	end
end

-- Add `readstring` and `writestring` manually.

function Buffer:ReadString(len: number)
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
	local str = buffer.readstring(self._buffer, self._readPointer, len)

	-- Shift the read pointer.
	self._readPointer += len

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
	buffer.writestring(self._buffer, self._writePointer, str)

	-- Shift the write pointer.
	self._writePointer += #str
end

function Buffer:WriteBoolean(state: boolean)
	assert(typeof(state) == "boolean", `state is expected to be boolean, got {typeof(state)}`)

	-- Write boolean.
	self:WriteInt8(if state then 1 else 0)
end

function Buffer:ReadBoolean(): boolean
	return self:ReadInt8() == 1
end

function Buffer:GetNumberOfBytesUnread()
	return buffer.len(self._buffer) - self._readPointer
end

function Buffer:GetNumberOfBytesRead()
	return self._readPointer
end

function Buffer:GetNumberOfBytes()
	return self._writePointer
end

function Buffer:GetSize()
	return buffer.len(self._buffer)
end

function Buffer:SetWritePointer(pointer: number)
	assert(typeof(pointer) == "number", `pointer is expected to be number, got {typeof(pointer)}`)
	assert(pointer >= 0, `pointer is not expected to be less or equal zero`)
	assert(pointer % 1 == 0, `pointer is not expected to be float`)

	self._writePointer = pointer
end

function Buffer:SetReadPointer(pointer: number)
	assert(typeof(pointer) == "number", `pointer is expected to be number, got {typeof(pointer)}`)
	assert(pointer >= 0, `pointer is not expected to be less or equal zero`)
	assert(pointer % 1 == 0, `pointer is not expected to be float`)

	self._readPointer = pointer
end

function Buffer:ResetWritePointer()
	self:SetWritePointer(0)
end

function Buffer:ResetReadPointer()
	self:SetReadPointer(0)
end

function Buffer:ResetPointers()
	self:ResetReadPointer()
	self:ResetWritePointer()
end

function Buffer:Reset()
	self:ResetPointers()

	-- Reset the buffer no recreate it!
	buffer.fill(self._buffer, 0, 0x00)
end

function Buffer:SetData(data: buffer | string)
	self:ResetPointers()

	if typeof(data) == "buffer" then
		self._buffer = data
	elseif typeof(data) == "string" then
		self._buffer = buffer.fromstring(data)
	else
		error(`Non-expected data type {typeof(data)} was given!`)
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
