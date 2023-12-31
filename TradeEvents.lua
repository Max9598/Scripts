if m_cons then
	print("Disconnected",#getgenv().m_cons,"connections")
	for i,v in next, m_cons do
		v:Disconnect()
	end
end
getgenv().m_cons = {}

local Trade = RS.Trade
local Events = {}

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
	m_cons[#m_cons+1] = Trade.StartTrade.OnClientEvent:connect(function(_,Player)
		if not PL[Player] then
			TradeFunctions.DeclineTrade()
			return
		end
		CurrentTrader = PL[Player]
		callback(Player)
	end)
end

Events.OnTradeDeclined = function(callback)
	m_cons[#m_cons+1] = Trade.DeclineTrade.OnClientEvent:connect(function()
		callback(CurrentTrader)
	end)
end

Events.OnTradeUpdated = function(callback)
	m_cons[#m_cons+1] = Trade.UpdateTrade.OnClientEvent:connect(function(trade)
		if callback then
			callback(trade)
		end
		if trade.Player1.Player == LP then
			MyOffer = trade.Player1.Offer
			TheirOffer = trade.Player2.Offer
			if CurrentTrader ~= trade.Player2.Player then
				TradeFunctions.DeclineTrade()
				return
			end
		else
			MyOffer = trade.Player2.Offer
			TheirOffer = trade.Player1.Offer
			if CurrentTrader ~= trade.Player1.Player then
				TradeFunctions.DeclineTrade()
				return
			end
		end
	end)
end;Events.OnTradeUpdated(false)

Events.OnTradeCompleted = function(callback)
	m_cons[#m_cons+1] = Trade.AcceptTrade.OnClientEvent:connect(function(Accept, Items)
		if Accept then
			callback(MyOffer, Items, CurrentTrader)
		end
	end)
end
Events.OnTradeAccepted = function(callback)
	m_cons[#m_cons+1] = Trade.AcceptTrade.OnClientEvent:connect(function(Accept, Items)
		if not Accept then
			callback(TheirOffer, CurrentTrader, MyOffer)
		end
	end)
end

return Events
