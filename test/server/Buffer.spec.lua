return function()
	beforeAll(function(context)
		context.Buffer = require(game.ReplicatedStorage.Talkie.Buffer)
	end)

	it("0. should represent same data as original buffer", function(context)
		local buf0 = context.Buffer.new()
		local buf1 = buffer.create(32)

		buf0:WriteInt8(64)

		buffer.writei8(buf1, 0, 64)

		expect(buf0:Serialize()).to.equal(buffer.tostring(buf1))
	end)

	it("1. should correctly reallocate", function(context)
		local buf0 = context.Buffer.new("")

		expect(buf0:GetSize()).to.equal(0)
		buf0:WriteUInt8(2)
		expect(buf0:GetSize()).to.equal(34) -- 1 + DEFAULT_BUFFER_SIZE (+ 1 to % of 2)
	end)

	it("2. should read the same data as original buffer", function(context)
		local buf0 = context.Buffer.new("@") -- 64
		local buf1 = buffer.fromstring("@")

		expect(buf0:ReadInt8()).to.equal(buffer.readi8(buf1, 0))
	end)

	it("3. should correctly write the string", function(context)
		local buf0 = context.Buffer.new()
		local buf1 = buffer.create(32)

		buf0:WriteString("test")
		buffer.writestring(buf1, 0, "test")

		expect(buf0:Serialize()).to.equal(buffer.tostring(buf1))
	end)

	it("4. should correctly read the string", function(context)
		local buf0 = context.Buffer.new("test")
		local buf1 = buffer.fromstring("test")

		expect(buf0:ReadString(4)).to.equal(buffer.readstring(buf1, 0, 4))
	end)

	it("5. should throw error if float in integer methods", function(context)
		local buf0 = context.Buffer.new()
		expect(function()
			buf0:WriteInt8(3.3)
		end).to.throw("input is not expected to be floating point")
	end)

	it("6. should not to throw error if float in float methods", function(context)
		local buf0 = context.Buffer.new()
		expect(function()
			buf0:WriteFloat(3.3)
		end).never.to.throw("input is not expected to be floating point")
	end)
end
