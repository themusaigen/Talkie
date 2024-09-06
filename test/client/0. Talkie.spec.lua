return function()
	local TEST_FOLDER = "TestFolder"

	describe("0. Initialize", function()
		it("0. should basically construct", function(context)
			expect(context.Talkie.Client()).to.ok()
		end)

		it("1. should throw error on non instance parent", function(context)
			expect(function()
				context.Talkie.Client(123)
			end).to.throw()
		end)

		it("2. should throw error on non string namespace", function(context)
			expect(function()
				context.Talkie.Client(game.ReplicatedStorage, 123)
			end).to.throw()
		end)

		it("3. should throw error on empty namespace", function(context)
			expect(function()
				context.Talkie.Client(game.ReplicatedStorage, "")
			end).to.throw()
		end)

		it("4. should throw error on non existing namespace", function(context)
			expect(function()
				context.Talkie.Client(game.ReplicatedStorage, "Test")
			end).to.throw()
		end)

		it("5. should throw error on non folder namespace", function(context)
			expect(function()
				context.Talkie.Client(game.ReplicatedStorage, "Talkie")
			end).to.throw()
		end)
	end)

	describe("1. Grabbing", function()
		it("0. should grab functions properly", function(context)
			local client = context.Talkie.Client(game.ReplicatedStorage, TEST_FOLDER)

			expect(client:Function("TestFunction")).to.ok()
		end)

		it("1. should grab events properly", function(context)
			local client = context.Talkie.Client(game.ReplicatedStorage, TEST_FOLDER)

			expect(client:Event("TestEvent")).to.ok()
			expect(client:Event("TestUnreliableEvent")).to.ok()
		end)

		it("2. should grab properties properly", function(context)
			local client = context.Talkie.Client(game.ReplicatedStorage, TEST_FOLDER)

			expect(client:Property("TestProperty"))
		end)

    it("3. should parse properly", function(context)
      local client = context.Talkie.Client(game.ReplicatedStorage, TEST_FOLDER)

      expect(function()
        client:Parse()
      end).never.to.throw()

      local remotes = client:Parse()
      expect(remotes).to.ok()
      expect(remotes.TestFunction).to.ok()
      expect(remotes.TestEvent).to.ok()
      expect(remotes.TestUnreliableEvent).to.ok()
      expect(remotes.TestProperty).to.ok()
    end)
	end)

  describe("2. Misc", function()
    it("0. should middleware exist", function(context)
      expect(context.Talkie.Inbound).to.ok()
      expect(context.Talkie.Outbound).to.ok()
    end)
  end)
end
