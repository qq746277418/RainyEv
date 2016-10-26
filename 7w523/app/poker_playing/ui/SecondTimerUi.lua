local SecondTimer = require("app.ui.common.SecondTimer")
local SecondTimeUi = class("SecondTimerUi", function() return display.newNode() end)

local res_clock = "ui/playing_ui/gs_clock_1.png"

function SecondTimeUi:ctor()
	self.m_second_timer = nil
	self.m_timer_label = nil

	self:_init()
end

function SecondTimeUi:_init()
	if not self.m_second_timer then
		self.m_second_timer = SecondTimer.new()
	end

	self.m_sp_clock = display.newSprite(res_clock)
	:addTo(self)
	:hide()

	self.m_timer_label = cc.ui.UILabel.new({text = "", size = 26, color = cc.c3b(255, 0, 0)})
	:addTo(self.m_sp_clock)
	:align(display.CENTER, W(self.m_sp_clock) / 2, H(self.m_sp_clock) / 2 - 10)
end

function SecondTimeUi:start(total_seconds, over_action)
	self.m_second_timer:start(total_seconds, handler(self, self._updateTimerLabel), over_action)
end

function SecondTimeUi:stop()
	self:stop()
end

function SecondTimeUi:_updateTimerLabel(time)
	self.m_timer_label:setString(time)
	self.m_sp_clock:show()
end

return SecondTimeUi 