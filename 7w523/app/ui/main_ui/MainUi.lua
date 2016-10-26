local dir = "ui/main_ui/"
local PlistRes = {
	sp_achieve = dir .. "sp_achieve.png",
	sp_knapsack = dir .. "sp_knapsack.png",
	sp_mall = dir .. "sp_mall.png",
	sp_system_set = dir .. "sp_system_set.png",
}

local ImageRes = {
	
}

local GamePlayingUi = require("app.poker_playing.ui.GamePlayingUi")
local MainUi = class("MainUi", function() return display.newLayer() end)

function MainUi:ctor()

	self:init()
	self:bottom()
end

function MainUi:init()
	local background = ww.createBackGround(CommonRes.bg_0001)
	background:addTo(self)

	local began_label = ww.createLabel("2人牌局")
	ww.createButton(CommonButtons.btn_run_red, began_label)
	:addTo(self)
	:pos(display.cx, display.cy + 110)
	:onButtonClicked(function()
		GamePlayingUi.new({player_num = 2}):addTo(self)
	 end)

	local began_label = ww.createLabel("3人牌局")
	ww.createButton(CommonButtons.btn_run_red, began_label)
	:addTo(self)
	:pos(display.cx, display.cy - 100)
	:onButtonClicked(function()
		GamePlayingUi.new({player_num = 3}):addTo(self)
	 end)
end

function MainUi:bottom()
	local node = cc.Node:create()
	node:addTo(self)

	local button_images = {}
	button_images[1] = PlistRes.sp_achieve
	button_images[2] = PlistRes.sp_knapsack
	button_images[3] = PlistRes.sp_mall
	button_images[4] = PlistRes.sp_system_set

	local dis_width = 220
	for id,val in pairs(button_images) do
		local button = ww.createButton(val)
		button:addTo(node)
		button:pos((id - 0.5) * dis_width, 0)
	end

	node:pos(display.cx - #button_images / 2 * dis_width, 60)
end



return MainUi