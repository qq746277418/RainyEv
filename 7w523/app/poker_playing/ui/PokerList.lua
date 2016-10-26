local Poker = import(".Poker")
local PokerList = class("PokerList", function() return display.newNode() end)

function PokerList:ctor(seat_ui)
	self.m_seat_ui = seat_ui
	self.m_is_robot = seat_ui:getIsRobot()
	self.m_is_right = seat_ui:getPokerIsRight()

	self.m_poker_num = 0

	--ui
	self.m_poker_list = {}
end

function PokerList:addPokers(pokers)
	for _,val in pairs(pokers) do
		local poker = Poker.new()
		poker:addTo(self, PlayingData:getInstance():getPokerZorder())
		poker:align(display.LEFT_BOTTOM)
		poker:setId(val)
		poker:pos(#self.m_poker_list * PlayingConst.POKER_WIDTH_DISTANCE, 0)
		table.insert(self.m_poker_list, #self.m_poker_list + 1, poker)
		if not self.m_is_robot then
			poker:setTouchListener(handler(self, self._pokerTouchListener))
		else
			poker:setTexture("poker/0.png")
		end
	end
end

function PokerList:setDerectionVertical()
	self:setRotation(90)
end

--整理（大小顺序）
function PokerList:_sortPokersDownByWeg()
	local sortFunc = function(a, b) return a:getWeg() > b:getWeg() end
	table.sort(self.m_poker_list, sortFunc)
end

--手牌顺序整理
function PokerList:madePokerList()
	self:_sortPokersDownByWeg()
	if not self.m_is_right then
		for id,poker in pairs(self.m_poker_list) do
			poker:pos(PlayingConst.POKER_WIDTH_DISTANCE * (id-1), 0)
			poker:setIsSelected(false)
			poker:setLocalZOrder(PlayingData:getInstance():getPokerZorder())
		end
	else
		for id,poker in pairs(self.m_poker_list) do
			poker:pos(self.m_is_right-PlayingConst.POKER_WIDTH_DISTANCE * id, 0)
			poker:setIsSelected(false)
			poker:setLocalZOrder(PlayingData:getInstance():getPokerZorder(-1))
		end
	end
end

--失去手牌
function PokerList:removePokers(pokers)
	for _,val in pairs(pokers) do
		for id,poker in pairs(self.m_poker_list) do
			if val == poker:getId() then
				poker:removeFromParent()
				table.remove(self.m_poker_list, id)
			end
		end
	end
	self:madePokerList()
end

function PokerList:removeAllPokers()
	for _,val in pairs(self.m_poker_list) do
		val:removeFromParent()
	end
	self.m_poker_list = {}
end

--上牌
function PokerList:upPokers()
	local num = 5 - #self.m_poker_list
	local seqActions = {}
	if num > 0 then
		local poker_ids = PlayingData:getInstance():randPokers(num)
		self:addPokers(poker_ids)
		self:madePokerList()
	end
end

function PokerList:_pokerTouchListener(poker, event)
	if event.name == "began" then
		poker:setIsSelected(not poker:getIsSelected())
		return true
	elseif event.name == "moved" then
	elseif event.name == "ended" then
	end
end

function PokerList:getSelectedPokers()
	local selected = {}
	for _,poker in pairs(self.m_poker_list) do
		if poker:getIsSelected() then
			table.insert(selected, #selected + 1, poker:getId())
		end
	end
	return selected
end

function PokerList:getPokerList()
	return self.m_poker_list
end

--手牌列表Id
function PokerList:getPokerIds()
	local tmp = {}
	for _, val in pairs(self.m_poker_list) do
		table.insert(tmp, #tmp + 1, val:getId())
	end
	return tmp
end

return PokerList