return function()
	beforeAll(function(context)
		context.server = context.Talkie.Server(game.ReplicatedStorage, "TestFolder_2")

		-- Create function for client`s tests.
		context.TestFun0 = context.server:Function("TestFunction_0", function()
			return 1337
		end)
		context.TestFun1 = context.server:Function("TestFunction_1")

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

	describe("3. Invoke", function()
		it("0. should properly invoke", function(context)
			expect(function()
				-- This test will be run more faster than client can start handling this function, so delay this moment.
				task.wait(1.5)

				context.TestFun0:Invoke(context.Player, 123)
			end).never.to.throw()
		end)
	end)

	describe("4. Handle", function()
		it("0. should properly handle player invokes", function(context)
			local output

			context.TestFun1:Listen(function(player, arg)
				output = arg
			end)

			expect(context.AwaitCondition(function()
				return (output == 123)
			end)).to.equal(true)
		end)

		it("1. should properly handle return values", function(context)
			local value = context.TestFun1(context.Player)

			expect(context.AwaitCondition(function()
				return (value == 1337)
			end)).to.equal(true)
		end)
	end)
end
