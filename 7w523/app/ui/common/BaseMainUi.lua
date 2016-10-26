local dir = "ui/main_ui/"
local PlistRes = {
	btn_back = {normal = ""}
}

local ImageRes = {
	
}

local BaseMainUi = class("BaseMainUi", function() return display.newLayer() end)

function BaseMainUi:ctor()
	self.m_btn_back = nil
	self.m_background = nil

	self:init()
end

function BaseMainUi:init()
	self.m_btn_back = ww.createButton(PlistRes.btn_back)
	self.m_btn_back:addTo(self)
	
end

return BaseMainUi