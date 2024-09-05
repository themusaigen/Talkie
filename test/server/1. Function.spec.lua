return function()
	beforeAll(function(context)
		context.server = context.Talkie.Server(game.ReplicatedStorage, "TestFolder_2")

		-- Create function for client`s tests.
		context.test = context.server:Function("TestFunction_0", function()
			return 1337
		end)
		context.test1 = context.server:Function("TestFunction_1")

		context.dummy = function() end
	end)

	describe("0. Create", function()
		it("0. should throw error if not string provided as name", function(context)
			expect(function()
				context.server:Function(123)
			end).to.throw()
		end)

		it("1. should throw error if empty name provided", function(context)
			expect(function()
				context.server:Function("")
			end).to.throw()
		end)

		it("2. should throw error if duplicate", function(context)
			expect(function()
				local temp = context.server:Function("DuplicateTest")
				context.server:Function("DuplicateTest") -- got error.

				temp:Destroy()
			end).to.throw()
		end)

		it("3. should throw error if not function provided as handler", function(context)
			expect(function()
				context.server:Function("TestFunction", 123)
			end).to.throw()
		end)

		it("4. should throw error if not table provided as middleware", function(context)
			expect(function()
				context.server:Function("TestFunction", context.dummy, 123)
			end).to.throw()
		end)
	end)

	describe("1. Listen", function()
		it("0. should throw error if not function provided", function(context)
			local fun = context.server:Function("TestFunction")

			expect(function()
				fun:Listen(123)
			end).to.throw()

			fun:Destroy()
		end)
	end)

	describe("2. Middleware", function()
		it("0. should throw error if not table provided", function(context)
			local fun = context.server:Function("TestFunction")

			expect(function()
				fun:SetMiddleware(123)
			end).to.throw()

			fun:Destroy()
		end)

		it("1. should throw error if not table provided in inbound", function(context)
			local fun = context.server:Function("TestFunction")

			expect(function()
				fun:SetMiddleware({ Inbound = 123 })
			end).to.throw()

			fun:Destroy()
		end)

		it("2. should throw error if not table provided in outbound", function(context)
			local fun = context.server:Function("TestFunction")

			expect(function()
				fun:SetMiddleware({ Outbound = 123 })
			end).to.throw()

			fun:Destroy()
		end)
	end)

	-- Due of nature AwaitCondition that yields main therad some tests not will work if run them at once, bc based on PlayerAdded.
	-- So unskip some tests once by once if needed. Or mb i fix that later.
	describeSKIP("3. Invoke", function()
		it("0. should properly invoke", function(context)
			local success = false
			game.Players.PlayerAdded:Connect(function(player)
				expect(function()
					context.test:Invoke(player, 123)
				end).never.to.throw()
				success = true
			end)

			expect(context.AwaitCondition(function()
				return (success == true)
			end)).to.equal(true)
		end)
	end)

	describeSKIP("4. Handle", function()
		it("0. should properly handle player invokes", function(context)
			local output

			context.test1:Listen(function(player, arg)
				output = arg
			end)

			expect(context.AwaitCondition(function()
				return (output == 123)
			end)).to.equal(true)
		end)

		-- As I mentioned above:
		-- Bugged due nature of AwaitCondition that yields main thread so PlayerAdded:Connect never be called here.
		-- Anyways, Remotes working good and return values handles properly.
		it("1. should properly handle return values", function(context)
			local value
			game.Players.PlayerAdded:Connect(function(player)
				value = context.test1(player)
			end)

			expect(context.AwaitCondition(function()
				return (value == 1337)
			end)).to.equal(true)
		end)
	end)
end
