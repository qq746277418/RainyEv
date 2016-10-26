--直接覆盖（发牌）
local DealPokerUi = class("DealPokerUi", function() return display.newNode() end)

function DealPokerUi:ctor(seat_list, pokers)
	self.m_seat_list = seat_list
	self.m_pokers = pokers

	self.m_poker_num = 10
	self.m_first_began = true

	self.m_pokers_ui = {}
	self.m_deal_poker_nums = {}

	self:init()
end

function DealPokerUi:destroy()
	GameDispatchData:getInstance():removeObserver(GameDataIds.kGameSurplusPokers)
end

function DealPokerUi:init()
	for i=1,self.m_poker_num do
		local poker0 = display.newSprite("poker/0.png")
		poker0:addTo(self)
		poker0:pos(display.cx, display.cy + 3 * i)
		self.m_pokers_ui[i] = poker0
	end

	self.m_surple_pokers_label = ww.createLabel("剩余:54", 30, cc.c3b(255, 0, 0))
	:addTo(self)
	:align(display.CENTER, display.cx, display.cy + 35)

	GameDispatchData:getInstance():addObserver(GameDataIds.kGameSurplusPokers, handler(self, self._updateSurplusPokers))
	GameDispatchData:getInstance():dispatchData(GameDataIds.kGameSurplusPokers, #PlayingData:getInstance():getNormalPokers())

	self:beganDealPokers()
end

function DealPokerUi:_updateSurplusPokers(data)
	if self.m_surple_pokers_label then
		if data > 0 then
			self.m_surple_pokers_label:setString("剩余:" .. data)
		else
			self.m_surple_pokers_label:hide()
		end
	end
	if data < 10 then
		for id,val in pairs(self.m_pokers_ui) do
			if id >= data and val then
				val:removeFromParent()
				val = nil
				table.remove(self.m_pokers_ui, id)
			end
		end
	end
end

--开始发牌
function DealPokerUi:beganDealPokers()
	local seq = {}
	for id, pokers_value in pairs(self.m_pokers) do
		local seat = self.m_seat_list[pokers_value.seat_pos]
		self.m_deal_poker_nums[id] = seat:getPokerIsRight() and 0 or #seat:getPokerList():getPokerList()
		for _,poker in pairs(pokers_value.pokers) do
			local function listener()
				self:upPokerAction(pokers_value.seat_pos, function() 
					self.m_seat_list[pokers_value.seat_pos]:addPokers({poker}) 
					self.m_seat_list[pokers_value.seat_pos]:getPokerList():madePokerList()
					 end)
			end
			local tem_seq = cc.Sequence:create(cc.CallFunc:create(listener), cc.DelayTime:create(0.1))
			table.insert(seq, #seq + 1, tem_seq)
		end
	end

	table.insert(seq, #seq + 1, cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() 
		self.m_seat_list[1]:getPokerList():madePokerList()
		self.m_deal_poker_nums = {}
		if self.m_first_began then
			self.m_first_began = false
			GameDispatchData:getInstance():dispatchData(GameDataIds.kGameStage, PlayingConst.GameStage.fighting)
		else
			GameDispatchData:getInstance():dispatchData(GameDataIds.kGameRoundBegan, nil)
		end
		end)))
	self:runAction(cc.Sequence:create(seq))
end

function DealPokerUi:resetDealPokers(pokers)
	self.m_pokers = pokers
	self:beganDealPokers()
end

function DealPokerUi:upPokerAction(seat, listener) 
	local seat_ui = self.m_seat_list[seat]
	--local poker_num = #seat_ui:getPokerList():getPokerList()
	local position_x = seat_ui.m_pos.x + seat_ui.m_poker_pos.x + PlayingConst.POKER_WIDTH_DISTANCE * (self.m_deal_poker_nums[seat] - 1)
	local position_y = seat_ui.m_pos.y + seat_ui.m_poker_pos.y
	self.m_deal_poker_nums[seat] = self.m_deal_poker_nums[seat] + 1

	local sp = display.newSprite("poker/0.png")
	sp:addTo(self)
	sp:pos(display.cx, display.cy + 26)
	sp:align(display.LEFT_BOTTOM)

	local seq = cc.Sequence:create(
		cca.moveTo(0.5, position_x, position_y),
		cc.CallFunc:create(listener),
		cc.CallFunc:create(function() sp:removeFromParent() end)
		)
	sp:runAction(seq)
end

return DealPokerUi