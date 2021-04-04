local TILT_TIME = 0.05
local TWEEN_TIME = 0.3
local NOTIFICATION_TWEEN_TIME = 0.5

local player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local eve = ReplicatedStorage:WaitForChild("DonationEvent")
local gui = script.Parent
local debounce = false

local lb = gui:WaitForChild("Leaderboard")
local lbTemplate = lb.Template
local lbList = lb.List
local lbSwitch = lb.SwitchFrame.Button

local donate = gui:WaitForChild("Donate")
local donateList = donate.List
local donateSwitch = donate.SwitchFrame.Button

local black = gui:WaitForChild("Black")
local blackTweens = {
	opaque = TweenService:Create(black, TweenInfo.new(NOTIFICATION_TWEEN_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency = .7}),
	transparent = TweenService:Create(black, TweenInfo.new(NOTIFICATION_TWEEN_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
}

local notification = gui:WaitForChild("Notification")
local notificationSwitch = notification:WaitForChild("SwitchFrame").Button

local notifSwitchTweens = {
	normal = TweenService:Create(notificationSwitch.Parent, TweenInfo.new(TILT_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 0}),
	slant = TweenService:Create(notificationSwitch.Parent, TweenInfo.new(TILT_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 2})
}

local current = "lb"

local style = Enum.EasingStyle.Sine
local inDir = Enum.EasingDirection.InOut
local outDir = Enum.EasingDirection.InOut

local udm = UDim2.new
local leftPos = udm(-1,0,0,0)
local centPos = udm(0,0,0,0)
local rightPos = udm(1,0,0,0)

local upPos = udm(.5,0,-0.5,0)
local anchorPos = udm(.5,0,.5,0)
local downPos = udm(.5,0,1.5,0)

local function notify(head, body)
	debounce = true
	notification.Title.Text = head
	notification.Body.Text = body

	blackTweens.opaque:Play()
	notification:TweenPosition(anchorPos, inDir, style, NOTIFICATION_TWEEN_TIME, true)
end

local function toggle(choice)
	if choice == "lb" then
		lb.Position = leftPos
		donate.Position = centPos

		lb:TweenPosition(centPos, inDir, style, TWEEN_TIME, true)
		donate:TweenPosition(rightPos, outDir, style, TWEEN_TIME, true)
	elseif choice == "donate" then
		donate.Position = leftPos
		lb.Position = centPos

		donate:TweenPosition(centPos, inDir, style, TWEEN_TIME, true)
		lb:TweenPosition(rightPos, outDir, style, TWEEN_TIME, true)
	else
		warn("Invalid choice: " .. choice)
	end
end

local function clearList(list)
	for _, v in pairs (list:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
end

local function updateBoardWithData(page)
	clearList(lbList)
	for _, data in ipairs(page) do

		local username = data.name
		local amountDonated = data.amount
		local rank = data.rank
		local icon = data.icon

		local clone = lbTemplate:Clone()
		clone.Icon.Image = icon
		clone.Rank.Text = "#" .. rank
		clone.Robux.Text = amountDonated
		clone.Username.Text = username
		clone.LayoutOrder = rank
		clone.Visible = true
		clone.Parent = lbList
	end
end

for _, option in pairs (donateList:GetChildren()) do
	if option:IsA("Frame") then
		option.Button.MouseButton1Click:Connect(function()
			if not debounce then
				MarketplaceService:PromptProductPurchase(player, option.Id.Value)
			end
		end)
		option.MouseEnter:Connect(function()
			if not debounce then
				option:TweenSize(udm(1,0,0,79), inDir, style, .1, true)
			end
		end)
		option.MouseLeave:Connect(function()
			option:TweenSize(udm(1,0,0,69), inDir, style, .1, true)
		end)
	end
end

donateSwitch.MouseButton1Click:Connect(function()
	if not debounce then
		toggle("lb")
	end
end)
lbSwitch.MouseButton1Click:Connect(function()
	if not debounce then
		toggle("donate")
	end
end)

notificationSwitch.MouseButton1Click:Connect(function()
	blackTweens.transparent:Play()
	notification:TweenPosition(downPos, inDir, style, NOTIFICATION_TWEEN_TIME, true, function()
		notification.Position = upPos
		debounce = false
	end)
end)
notificationSwitch.MouseEnter:Connect(function()
	print("Enter")
	notifSwitchTweens.slant:Play()
end)
notificationSwitch.MouseLeave:Connect(function()
	notifSwitchTweens.normal:Play()
end)

eve.OnClientEvent:Connect(function(event, data)
	if event == "update" then
		updateBoardWithData(data)
	else
		notify(event, data)
	end
end)

notification.Position = upPos
toggle("lb")