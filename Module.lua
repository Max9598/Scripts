if getgenv().m_cons then
	for i,v in next, getgenv().m_cons do
		v:Disconnect()
	end
end
getgenv().m_cons = {}

local MsgReq = RS.DefaultChatSystemChatEvents.SayMessageRequest
local Trade = RS.Trade
local Functions = {}
local Events = {}
local ItemsTable = {}

local Items = RS.GetSyncData:InvokeServer()
for GameName,Info in next, Items.Item do
	ItemsTable[GameName] = {Type = Info.ItemType, Rarity = Info.Rarity, Category = "Weapons", Name = Info.ItemName, Id = tonumber(Info.Image) and Info.Image or string.find(Info.Image, "http") and string.split(Info.Image, "d=")[2] or string.split(Info.Image, "//")[2]}
end;ItemsTable.Ghosty = nil
for GameName,Info in next, Items.Pets do
	ItemsTable[GameName] = {Type = "Pet", Rarity = Info.Rarity, Category = "Pets", Name = Info.Name, Id = tonumber(Info.Image) and Info.Image or string.find(Info.Image, "http") and string.split(Info.Image, "d=")[2] or string.split(Info.Image, "//")[2]}
end
task.spawn(function()
	while task.wait(5) do
		INV = RS.Remotes.Extras.GetData2:InvokeServer()
	end
end)

Functions.Message = function(Text)
	MsgReq:FireServer(Text, 'normalchat')
end

Functions.TradeAdd = function(Item, Count)
	local inv_item = INV[ItemsTable[Item].Category].Owned[Item] or 0
	if inv_item >= Count then
		for i = 1, Count do
			Trade.OfferItem:FireServer(Item, ItemsTable[Item].Category)
		end
	end
end
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
	getgenv().m_cons[#getgenv().m_cons+1] = Trade.StartTrade.OnClientEvent:connect(function(_,Player)
		if not PL[Player] then
			Functions.DeclineTrade()
			return
		end
		CurrentTrader = PL[Player]
		callback(Player)
	end)
end
Events.OnTradeUpdated = function(callback)
	getgenv().m_cons[#getgenv().m_cons+1] = Trade.UpdateTrade.OnClientEvent:connect(function(trade)
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
	getgenv().m_cons[#getgenv().m_cons+1] = Trade.AcceptTrade.OnClientEvent:connect(function(Accept, Items)
		if Accept then
			callback(MyOffer, Items, CurrentTrader)
		end
	end)
end
Events.OnTradeAccepted = function(callback)
	getgenv().m_cons[#getgenv().m_cons+1] = Trade.AcceptTrade.OnClientEvent:connect(function(Accept, Items)
		if not Accept then
			callback(TheirOffer, CurrentTrader)
		end
	end)
end

return {["Events"] = Events, ["Functions"] = Functions, ["ItemsTable"] = ItemsTable}
