return function()
	local Packet, Types, Types1

	beforeAll(function(context)
		Packet = require(game.ReplicatedStorage.Talkie.Packet)
		Types = Packet.Types
	end)

	it("0. should work with primitive packets", function()
		local PacketLogin = Packet.new(0, { name = Types.String8 }, { score = Types.UInt32 })

		-- Now serialize this packet.
		local packet
		expect(function()
			packet = PacketLogin:Serialize({
				name = "Player",
				score = 999,
			})
		end).never.to.throw()

		-- We are expecting that valid buf returned.
		expect(packet).to.ok()

		-- Shift the cursor.
		packet:ReadUInt16()

		-- Now deserialize this packet.
		expect(function()
			print(PacketLogin:Deserialize(packet))
		end).never.to.throw()
	end)


end
