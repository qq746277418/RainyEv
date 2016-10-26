local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local SecondTimer = class("SecondTimer")

function SecondTimer:ctor(times)
	self.m_times = times or 1.0
	self.m_scheduler_handler = nil
	self.m_over_action = nil
	self.m_once_action = nil

	self.m_total_seconds = 0  	--总时间
	self.m_current_seconds = 0  --当前时间
	self.m_left_seconds = 0 --剩余时间
	self.m_is_active = true
end

function SecondTimer:start(total_seconds, once_action, over_action)
	if not self.m_scheduler_handler then
        self.m_scheduler_handler = scheduler.scheduleGlobal(handler(self, self._systemTimeStep), self.m_times)
    end
    self.m_over_action = over_action  --调度结束调用
    self.m_once_action = once_action
    self.m_total_seconds = total_seconds
    self.m_left_seconds = total_seconds
end

-- function SecondTimer:restart()
-- 	self.m_over_action = over_action
-- end

function SecondTimer:_systemTimeStep(dt)
    if self.m_is_active then
        self.m_left_seconds = self.m_left_seconds - self.m_times
        self.m_current_seconds = self.m_current_seconds + self.m_times
        if self.m_once_action then
        	self.m_once_action(self.m_left_seconds)
        end
        if self.m_left_seconds <= 0 then
        	self:stop()
        end
    end
end

function SecondTimer:pause()
	self.m_is_active = false
end

function SecondTimer:resume()
	self.m_is_active = true
end

function SecondTimer:stop()
	if self.m_scheduler_handler then
        scheduler.unscheduleGlobal(self.m_scheduler_handler)
        self.m_scheduler_handler = nil
    end

    self.m_left_seconds = self.m_total_seconds
    self.m_current_seconds = 0
    self.m_is_active = true
    if self.m_over_action then
        self.m_over_action()
    end
end

return SecondTimer
