local MainUi = require("app.ui.main_ui.MainUi")
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	TipBox:getInstance():setRootScene(self)

	-- local background = ww.createBackGround(CommonRes.bg_0001)
	-- background:addTo(self)

	self:init()
end

function MainScene:init()
	MainUi.new():addTo(self)
	-- local t = Test.new()
	-- t:printString()
end

return MainScene
