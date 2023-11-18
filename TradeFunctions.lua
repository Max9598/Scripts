local Trade = RS.Trade
local Functions = {}
local ItemsTable = {}
local INV = {}

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

Functions.TradeAdd = function(Item, Count)
	local inv_item = INV[ItemsTable[Item].Category].Owned[Item] or 0
	if inv_item >= Count then
		for i = 1, Count do
			Trade.OfferItem:FireServer(Item, ItemsTable[Item].Category)
		end
	else
		warn(Item.." Amount is less than "..Count)
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
Functions.BotInventory = function()
	return INV
end

return {["Functions"] = Functions, ["ItemsTable"] = ItemsTable}
