--[[

  ____                    _   _               ____                      _ 
 |  _ \  ___  _ __   __ _| |_(_) ___  _ __   | __ )  ___   __ _ _ __ __| |
 | | | |/ _ \| '_ \ / _` | __| |/ _ \| '_ \  |  _ \ / _ \ / _` | '__/ _` |
 | |_| | (_) | | | | (_| | |_| | (_) | | | | | |_) | (_) | (_| | | | (_| |
 |____/ \___/|_| |_|\__,_|\__|_|\___/|_| |_| |____/ \___/ \__,_|_|  \__,_|
                                                                          
                                                                                       
	GitHub Repository: https://github.com/twinrbx/donation-board
	DevForum Thread: https://devforum.roblox.com/quick-donation-board-monetize-in-a-snap
	
	Author @twinqle
	Last updated: 3/4/21
	

--]]

--> Configuration

local DATA_KEY = "#&(DMD!)A!)@$"
local GUI_FACE = "Right"
local DISPLAY_AMOUNT = 25
local REFRESH_RATE = 60
local DONATION_OPTIONS = {
	{
		Amount = 10,
		Id = 1155547783
	},
	{
		Amount = 100,
		Id = 1155547790
	},
	{
		Amount = 500,
		Id = 1155547808
	},
	{
		Amount = 1000,
		Id = 1155547838
	},
	{
		Amount = 5000,
		Id = 1155547848
	},
}








-----------------------------------------------------------------------------------------------------------
--> Code starts here. Only edit if you're an experienced programmer!

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local gui = script.Donations
local face = Enum.NormalId[GUI_FACE]

local eve = Instance.new("RemoteEvent")
eve.Name = "DonationEvent"
eve.Parent = ReplicatedStorage

local cache = {}

local tmType = Enum.ThumbnailType.HeadShot
local tmSize = Enum.ThumbnailSize.Size420x420

local donations = DataStoreService:GetOrderedDataStore("DONATIONS_" .. DATA_KEY)

if not face then error("Invalid GUI_FACE: " .. GUI_FACE) else gui.Face = face end

local function getName(id)
	for cachedId, name in pairs (cache) do
		if cachedId == id then
			return name
		end
	end
	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(id)
	end)
	if success then
		cache[id] = result
		return result
	else
		warn(result .. "\nId: " .. id)
		return "N/A"
	end
end

local function findAmountById(id)
	for _, donationInfo in pairs (DONATION_OPTIONS) do
		if donationInfo.Id == id then
			print(donationInfo.Amount)
			return donationInfo.Amount
		end
	end
	warn("Couldn't find donation amount for product ID " .. id)
	return 0
end

local function clearList(list)
	for _, v in pairs (list:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
end

local function updateAllClients(page)
	eve:FireAllClients("update", page)
end

local function updateInternalBoard(updateClientsAfter)
	local sorted = donations:GetSortedAsync(false, math.clamp(DISPLAY_AMOUNT, 0, 250), 1)
	if sorted then
		local page = sorted:GetCurrentPage()
		local clientDataPacket = {}
		clearList(gui.Main.Leaderboard.List)
		for rank, data in ipairs(page) do
			local userId = data.key
			local username = getName(data.key)
			local icon, isReady = Players:GetUserThumbnailAsync(userId, tmType, tmSize)
			local amountDonated = data.value .. " robux"

			local clone = gui.Main.Leaderboard.Template:Clone()
			clone.Icon.Image = icon
			clone.Rank.Text = "#" .. rank
			clone.Robux.Text = amountDonated
			clone.Username.Text = username
			clone.LayoutOrder = rank
			clone.Visible = true
			clone.Parent = gui.Main.Leaderboard.List
			
			table.insert(clientDataPacket, {
				["name"] = username,
				["icon"] = icon,
				["amount"] = amountDonated,
				["rank"] = rank
			})
		end
		
		if updateClientsAfter then
			updateAllClients(clientDataPacket)
		end
	else
		warn("No data available for leaderboard refresh!")
	end
end

local function createButtonsInternal()
	for pos, donationInfo in pairs (DONATION_OPTIONS) do
		local clone = gui.Main.Donate.Template:Clone()

		clone.Id.Value = donationInfo.Id
		clone.Info.Text = "<b>" .. donationInfo.Amount .. "</b> robux"

		clone.Visible = true
		clone.LayoutOrder = pos

		clone.Parent = gui.Main.Donate.List
	end
end

local function processReceipt(receiptInfo) 
	local donatedAmount = findAmountById(receiptInfo.ProductId)
	local id = receiptInfo.PlayerId

	local success, err = pcall(function()
		donations:UpdateAsync(id, function(previousData)
			if previousData then
				return previousData + donatedAmount
			else
				return donatedAmount
			end
		end)
	end)

	local player = Players:GetPlayerByUserId(id)

	if not success then
		if player then
			eve:FireClient(player, "Error", "There was an error processing your purchase. You have not been charged. Error: " .. err)
		end
		warn("Error handling " .. id .. "'s purchase: " .. err)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if player then
		eve:FireClient(player, "Success", "Thanks for your generous donation!")
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function onPlayerAdded(plr)
	local pGui = plr:WaitForChild("PlayerGui", 5)
	if pGui then
		for _, board in pairs (script.Parent:GetChildren()) do
			if board.Name == "Board" then
				local clone = gui:Clone()
				clone.Adornee = board
				clone.Parent = pGui
			end
		end 
		return true
	end
	warn("Couldn't find PlayerGui for " .. plr.Name .. ":" .. plr.UserId)
end

createButtonsInternal()
updateInternalBoard(false)
MarketplaceService.ProcessReceipt = processReceipt

for _, plr in pairs (Players:GetPlayers()) do
	onPlayerAdded(plr)
end
Players.PlayerAdded:Connect(onPlayerAdded)

while true do
	wait(REFRESH_RATE)
	updateInternalBoard(true)
end
