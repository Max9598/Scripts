local Trade = RS.Trade
local Functions = {}
local Events = {}

Functions.AcceptRequest = function()
	Trade.AcceptRequest:FireServer()
end
Functions.AcceptTrade = function()
	Trade.AcceptTrade:FireServer()
end
Functions.DeclineRequest = function()
	Trade.DeclineRequest:FireServer()
end
Functions.DeclineTrade = function()
	Trade.DeclineTrade:FireServer()
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
print(Functions.JsonEncode({["a"] = "dd"}))
Functions.Request = function(...)
	local success, response = pcall(request, ...)
	if success and response.StatusCode == 200 then
		return response
	else
		warn("Request failed, error:", response.StatusCode and response.StatusCode or response)
	end
end

local is_accepting = false
Events.OnRequest = function(callback)
	Trade.SendRequest.OnClientInvoke = function(Player)
		if not is_accepting then
			is_accepting = true
			spawn(callback, Player)
			task.wait()
			is_accepting = false
			return true
		end
		return false
	end
end

local CurrentTrader = LP
local MyOffer = {}
local TheirOffer = {}
Events.OnTradeStarted = function(callback)
	Trade.StartTrade.OnClientEvent:connect(function(_,Player)
		if CurrentTrader ~= PL[Player] then
			Functions.DeclineTrade()
			return
		end
		callback(Player)
	end)
end
Events.OnTradeUpdated = function(callback)
	Trade.UpdateTrade.OnClientEvent:connect(function(trade)
		if callback then
			callback(trade)
		end
		if trade.Player1.Player == LP then
			MyOffer = trade.Player1.Offer
			TheirOffer = trade.Player2.Offer
			if CurrentTrader ~= trade.Player2.Player then
				Functions.DeclineTrade()
				return
			end
		else
			MyOffer = trade.Player2.Offer
			TheirOffer = trade.Player1.Offer
			if CurrentTrader ~= trade.Player1.Player then
				Functions.DeclineTrade()
				return
			end
		end
	end)
end;Events.OnTradeUpdated(false)
Events.OnTradeCompleted = function(callback)
	Trade.AcceptTrade.OnClientEvent:connect(function(Accept, Items)
		if Accepted then
			callback(MyOffer, Items, CurrentTrader)
		end
	end)
end
Events.OnTradeAccepted = function(callback)
	Trade.AcceptTrade.OnClientEvent:connect(function(Accept, Items)
		if not Accepted then
			callback(TheirOffer, CurrentTrader)
		end
	end)
end

return {["Events"] = Events, ["Functions"] = Functions}
