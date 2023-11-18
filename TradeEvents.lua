if getgenv().m_cons then
	for i,v in next, getgenv().m_cons do
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
	getgenv().m_cons[#getgenv().m_cons+1] = Trade.StartTrade.OnClientEvent:connect(function(_,Player)
		if not PL[Player] then
			TradeFunctions.DeclineTrade()
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

return Events