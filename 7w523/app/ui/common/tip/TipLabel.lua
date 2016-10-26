--文字提示框
local TipLabel = class("TipLabel", import(".BaseTipNode"))

function TipLabel:ctor(title, message)
	self.m_title_str = title or "提示"
	self.m_size = cc.size(600, 300)
	self.m_message = message

	TipLabel.super.ctor(self, self.m_size)

	self:setTitleString(self.m_title_str)
	self:openDelayRemove()
	self:initView()
end

function TipLabel:initView()
	local size = cc.size(self.m_size.width - 100, self.m_size.height - 35)
	local label = ww.createMultiLabel(self.m_message, 26, size, cc.c3b(108, 108, 108))
	label:addTo(self.m_base_bg)
	label:pos(self.m_size.width / 2, self.m_size.height / 2)
end

return TipLabel