getgenv().RS = game:GetService("ReplicatedStorage")
getgenv().HS = game:GetService("HttpService")
getgenv().PL = game:GetService("Players")
getgenv().LP = PL.LocalPlayer

local MsgReq = RS.DefaultChatSystemChatEvents.SayMessageRequest
local Functions = {}

Functions.Message = function(Text, Arg)
	if Text then
		if string.find(Text, "$") then
			Text = string.gsub(Text, "$", Arg)
		end
		MsgReq:FireServer(Text, 'normalchat')
	end
end

Functions.JsonDecode = function(...)
	local success, response = pcall(function(...) return HS:JSONDecode(...) end, ...)
	if success then
		return response
	else
		warn("Json decoding failed, error:", response)
	end
end
Functions.JsonEncode = function(...)
	local success, response = pcall(function(...) return HS:JSONEncode(...) end, ...)
	if success then
		return response
	else
		warn("Json encoding failed, error:", response)
	end
end
Functions.Request = function(...)
	local success, response = pcall(request, ...)
	if success and response.StatusCode == 200 then
		return response
	else
		warn("Request failed, error:", response.StatusCode and response.StatusCode or response)
	end
end

vu=game:GetService("VirtualUser")
LP.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

return Functions
