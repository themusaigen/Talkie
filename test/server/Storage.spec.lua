return function()
	it("0. should return same entity", function(context)
		local server = context.Talkie.Server(game.ReplicatedStorage, "StorageTest")
		local fun0 = server:Function("Function0")
		local fun1 = server:Function("Function1")
		local fun0copy = server:Function("Function0")

    print(fun0, fun1, fun0copy)

		expect(fun0copy).to.equal(fun0)
    expect(fun1).never.to.equal(fun0)
	end)
end
