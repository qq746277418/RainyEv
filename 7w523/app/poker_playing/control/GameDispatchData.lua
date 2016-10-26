GameDispatchData = class("GameDispatchData")
GameDispatchData.instance = nil

function GameDispatchData.getInstance()
	if not GameDispatchData.instance then
		GameDispatchData.instance = GameDispatchData.new()
	end
	return GameDispatchData.instance
end

function GameDispatchData:ctor()
	self.m_dispatch_data = {}
end

function GameDispatchData:addObserver(data_id, observer)
	self.m_dispatch_data[data_id] = observer
end

function GameDispatchData:removeObserver(data_id)
	self:addObserver(data_id)
end

function GameDispatchData:dispatchData(data_id, data)
	if self.m_dispatch_data[data_id] then
		self.m_dispatch_data[data_id](data)
	end
end