--!native
--!optimize 2
--!strict

local RunService = game:GetService("RunService")
local JestGlobals = require(script.Parent.Parent.Parent.DevPackages.JestGlobals)
local Signal = require(script.Parent.Parent)

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it

local function AwaitCondition(predicate: () -> boolean, timeout: number?): boolean
	local trueTimeout = timeout or 10
	local startTime = os.clock()

	while true do
		if predicate() then
			return true
		end

		if os.clock() - startTime > trueTimeout then
			return false
		end

		task.wait()
	end
end

local testSignal: Signal.Signal<(...any) -> (), ...any>

beforeEach(function()
	testSignal = Signal.new()
end)
afterEach(function()
	testSignal:Destroy()
end)

describe("Signal", function()
	describe("Constructor", function()
		it("should create a new signal and fire it", function()
			expect(Signal.Is(testSignal)).toBe(true)

			task.defer(function()
				testSignal:Fire(10, 20)
			end)

			local value0, value1 = testSignal:Wait()
			expect(value0).toBe(10)
			expect(value1).toBe(20)
		end)

		it("should create a proxy signal and connect to it", function()
			local wrappedSignal = Signal.Wrap(RunService.PostSimulation)
			expect(Signal.Is(wrappedSignal)).toBe(true)

			local fired = false
			wrappedSignal:Connect(function()
				fired = true
			end)

			expect(AwaitCondition(function()
				return fired
			end, 2)).toBe(true)

			wrappedSignal:Destroy()
		end)
	end)

	describe("FireDeferred", function()
		it("should be able to fire primitive argument", function()
			local send = 10
			local value: number
			testSignal:Connect(function(sentValue)
				value = sentValue
			end)

			testSignal:FireDeferred(send)
			expect(AwaitCondition(function()
				return send == value
			end, 1)).toBe(true)
		end)

		it("should be able to fire a reference based argument", function()
			local send = {10, 20}
			local value: {number}
			testSignal:Connect(function(sentValue)
				value = sentValue
			end)

			testSignal:FireDeferred(send)
			expect(AwaitCondition(function()
				return send == value
			end, 1)).toBe(true)
		end)
	end)
	describe("FireDeferredUnsafe", function()
		it("should be able to fire primitive argument", function()
			local send = 10
			local value: number
			testSignal:Connect(function(sentValue)
				value = sentValue
			end)

			testSignal:FireDeferredUnsafe(send)
			expect(AwaitCondition(function()
				return send == value
			end, 1)).toBe(true)
		end)

		it("should be able to fire a reference based argument", function()
			local send = {10, 20}
			local value: {number}
			testSignal:Connect(function(sentValue)
				value = sentValue
			end)

			testSignal:FireDeferredUnsafe(send)
			expect(AwaitCondition(function()
				return send == value
			end, 1)).toBe(true)
		end)
	end)
	describe("Fire", function()
		it("should be able to fire primitive argument", function()
			local send = 10
			local value: number
			testSignal:Connect(function(sentValue)
				value = sentValue
			end)

			testSignal:Fire(send)
			expect(value).toBe(send)
		end)

		it("should be able to fire a reference based argument", function()
			local send = {10, 20}
			local value: {number}
			testSignal:Connect(function(sentValue)
				value = sentValue
			end)

			testSignal:Fire(send)
			expect(value).toBe(send)
		end)
	end)

	describe("Once", function()
		it("should only capture the first fire", function()
			local value: number
			local connection = testSignal:Once(function(sentValue)
				value = sentValue
			end)

			expect(connection.Connected).toBe(true)
			testSignal:Fire(10)
			expect(connection.Connected).toBe(false)
			testSignal:Fire(20)
			expect(value).toBe(10)
		end)
	end)

	describe("Wait", function()
		it("should be able to wait for a signal to fire", function()
			task.defer(function()
				testSignal:Fire(10, 20, 30)
			end)

			local n0, n1, n2 = testSignal:Wait()
			expect(n0).toBe(10)
			expect(n1).toBe(20)
			expect(n2).toBe(30)
		end)
	end)

	describe("DisconnectAll", function()
		it("should disconnect all connections", function()
			testSignal:Connect(function() end)
			testSignal:Connect(function() end)

			expect(#testSignal:GetConnections()).toEqual(2)
			testSignal:DisconnectAll()
			expect(#testSignal:GetConnections()).toEqual(0)
		end)
	end)
end)

describe("Connection", function()
	describe("Disconnect", function()
		it("should disconnect connection", function()
			local connection = testSignal:Connect(function() end)
			expect(#testSignal:GetConnections()).toBe(1)
			connection:Disconnect()
			expect(#testSignal:GetConnections()).toBe(0)
		end)

		it("should still work if connections disconnected while firing", function()
			local value = 0
			testSignal:Connect(function()
				value += 1
			end)

			local connection: Signal.Connection
			connection = testSignal:Connect(function()
				connection:Disconnect()
				value += 1
			end)

			testSignal:Connect(function()
				value += 1
			end)

			testSignal:Fire()
			expect(value).toBe(3)
			testSignal:DisconnectAll()
		end)

		it("should still work if connections disconnected while using FireDeferred", function()
			local value = 0
			testSignal:Connect(function()
				value += 1
			end)

			local connection: Signal.Connection
			connection = testSignal:Connect(function()
				connection:Disconnect()
				value += 1
			end)

			testSignal:Connect(function()
				value += 1
			end)

			testSignal:FireDeferred()
			expect(AwaitCondition(function()
				return value == 3
			end)).toBe(true)
			testSignal:DisconnectAll()
		end)

		it("should still work if connections disconnected while using FireDeferredUnsafe", function()
			local value = 0
			testSignal:Connect(function()
				value += 1
			end)

			local connection: Signal.Connection
			connection = testSignal:Connect(function()
				connection:Disconnect()
				value += 1
			end)

			testSignal:Connect(function()
				value += 1
			end)

			testSignal:FireDeferredUnsafe()
			expect(AwaitCondition(function()
				return value == 3
			end)).toBe(true)
			testSignal:DisconnectAll()
		end)
	end)
end)

return false
