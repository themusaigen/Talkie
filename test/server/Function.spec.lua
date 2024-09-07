return function()
	beforeAll(function(context)
		context.parent = context.Talkie.Server(game.ReplicatedStorage, "TestFolder_2")._parent
		context.dummy = function() end
	end)

	describe("0. Create", function()
		it("0. should throw error if not string provided as name", function(context)
			expect(function()
				context.Function.new(context.parent, 123)
			end).to.throw()
		end)

		it("1. should throw error if empty name provided", function(context)
			expect(function()
				context.Function.new(context.parent, "")
			end).to.throw()
		end)

		it("2. should throw error if duplicate", function(context)
			expect(function()
				local temp = context.Function.new(context.parent, "DuplicateTest")
				context.Function.new(context.parent, "DuplicateTest") -- got error.

				temp:Destroy()
			end).to.throw()
		end)

		it("3. should throw error if not function provided as handler", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction", 123)
			end).to.throw()
		end)

		it("4. should throw error if not table provided as middleware", function(context)
			expect(function()
				context.Function.new(context.parent, "TestFunction", context.dummy, 123)
			end).to.throw()
		end)
	end)

	describe("1. Listen", function()
		it("0. should throw error if not function provided", function(context)
			local fun = context.Function.new(context.parent, "TestFunction")

			expect(function()
				fun:Listen(123)
			end).to.throw()

			fun:Destroy()
		end)
	end)

	describe("2. Middleware", function()
		it("0. should throw error if not table provided", function(context)
			local fun = context.Function.new(context.parent, "TestFunction")

			expect(function()
				fun:SetMiddleware(123)
			end).to.throw()

			fun:Destroy()
		end)

		it("1. should throw error if not table provided in inbound", function(context)
			local fun = context.Function.new(context.parent, "TestFunction")

			expect(function()
				fun:SetMiddleware({ Inbound = 123 })
			end).to.throw()

			fun:Destroy()
		end)

		it("2. should throw error if not table provided in outbound", function(context)
			local fun = context.Function.new(context.parent, "TestFunction")

			expect(function()
				fun:SetMiddleware({ Outbound = 123 })
			end).to.throw()

			fun:Destroy()
		end)
	end)
end
