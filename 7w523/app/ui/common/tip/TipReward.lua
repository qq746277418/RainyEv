local TipReward = class("TipReward", import(".BaseTipNode"))

function TipReward:ctor(title)
	self.m_title = title or ""
	TipReward.super.ctor(self, cc.size(700, 400))

	self:initView()
end

function TipReward:initView()
	self:setTitleString(self.m_title)


end

return TipReward