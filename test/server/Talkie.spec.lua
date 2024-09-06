return function()
	local TEST_FOLDER = "TestFolder"

	describe("0. Initialize", function()
		it("0. should basically construct", function(context)
			expect(context.Talkie.Server()).to.ok()
		end)

		it("1. should throw error on non instance parent", function(context)
			expect(function()
				context.Talkie.Server(123)
			end).to.throw()
		end)

		it("2. should throw error on non string namespace", function(context)
			expect(function()
				context.Talkie.Server(game.ReplicatedStorage, 123)
			end).to.throw()
		end)

		it("3. should throw error on empty namespace", function(context)
			expect(function()
				context.Talkie.Server(game.ReplicatedStorage, "")
			end).to.throw()
		end)

		it("4. should throw error on non folder namespace", function(context)
			expect(function()
				context.Talkie.Server(game.ReplicatedStorage, "Talkie")
			end).to.throw()
		end)

		it("5. should create folder if don't exist", function(context)
			do
				local folder = game.ReplicatedStorage:FindFirstChild(TEST_FOLDER)

				expect(folder).never.to.ok()
			end

			context.Talkie.Server(game.ReplicatedStorage, TEST_FOLDER)

			local folder = game.ReplicatedStorage:FindFirstChild(TEST_FOLDER)

			expect(folder).to.ok()
			expect(folder.ClassName).to.equal("Folder")
		end)
	end)

	describe("1. Create", function()
		it("0. should create function properly", function(context)
			local server = context.Talkie.Server(game.ReplicatedStorage, TEST_FOLDER)

			local fun = server:Function("TestFunction")

			expect(fun).to.ok()
			
			local folder = game.ReplicatedStorage:FindFirstChild(TEST_FOLDER)
			local remote = folder:FindFirstChild("TestFunction")

			expect(remote).to.ok()
			expect(remote.ClassName).to.equal("RemoteFunction")
		end)

		it("1. should create event properly", function(context)
			local server = context.Talkie.Server(game.ReplicatedStorage, "TestFolder")

			local event = server:Event("TestEvent")

			expect(event).to.ok()
			
			local folder = game.ReplicatedStorage:FindFirstChild(TEST_FOLDER)
			local remote = folder:FindFirstChild("TestEvent")

			expect(remote).to.ok()
			expect(remote.ClassName).to.equal("RemoteEvent")
		end)

		it("2. should create unreliable event properly", function(context)
			local server = context.Talkie.Server(game.ReplicatedStorage, "TestFolder")

			local event = server:Event("TestUnreliableEvent", true)

			expect(event).to.ok()
			
			local folder = game.ReplicatedStorage:FindFirstChild(TEST_FOLDER)
			local remote = folder:FindFirstChild("TestUnreliableEvent")

			expect(remote).to.ok()
			expect(remote.ClassName).to.equal("UnreliableRemoteEvent")
		end)

		it("3. should create property properly", function(context)
			local server = context.Talkie.Server(game.ReplicatedStorage, "TestFolder")

			local property = server:Property("TestProperty", 0)

			expect(property).to.ok()
			
			local folder = game.ReplicatedStorage:FindFirstChild(TEST_FOLDER)
			local remote = folder:FindFirstChild("TestProperty")

			expect(remote).to.ok()
			expect(remote.ClassName).to.equal("RemoteEvent")
		end)
	end)

	describe("2. Misc", function()
		it("0. should middleware exist", function(context)
			expect(context.Talkie.Inbound).to.ok()
			expect(context.Talkie.Outbound).to.ok()
		end)
	end)
end
