--!native
--!optimize 2
--!strict

local cached: boolean = nil

local function IsDeferred()
	if cached ~= nil then
		return cached
	end

	local bindableEvent = Instance.new("BindableEvent")
	local handlerRun = false
	bindableEvent.Event:Once(function()
		handlerRun = true
	end)
	bindableEvent:Fire()
	bindableEvent:Destroy()

	cached = not handlerRun
	return cached
end

return IsDeferred
