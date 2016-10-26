--根据座位号控制机器人
local RobotPoker = class("RobotPoker")

function RobotPoker:ctor(game_ui)
	self.m_game_ui = game_ui
	self.m_current_seat = nil
end

function RobotPoker:fightPokers(seat)
	if seat == 1 then return end
	self.m_current_seat = self.m_game_ui:getSeat(seat)   --座位类不是座位号
	self.m_seat_pos = seat

	local time = math.random(0.5, 2)
	local seq = cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(handler(self, self._controlFightingPokers))
	)
	self.m_game_ui:runAction(seq)
end

function RobotPoker:_controlFightingPokers()
	local pokers = self.m_current_seat:getPokerList():getPokerIds()
	local fight_index = PlayingData:getInstance():getRFightIndex()
	if fight_index == 1 then
		self:_firstFightPokers(pokers)
	else
		self:_canFightPokers(pokers)
	end
end

--第一个出牌
function RobotPoker:_firstFightPokers(pokers)
	local table_value = poker_rula.__fightFirst(pokers)--poker_rula.traversePokers(pokers)
	local fight_pokers = table_value.pokers
	local px = table_value.px
	dump(table_value)
	if fight_pokers then
		self.m_current_seat:removePokers(fight_pokers)
		self.m_current_seat:addFightPokers(fight_pokers)
		self.m_game_ui:getRoundControl():resetBuyaoNum()
		self.m_game_ui:setAllSeatsFlags()

		PlayingData:getInstance():updateRScore(poker_manager.countPokersScores(fight_pokers))
		PlayingData:getInstance():autoAddRfightIndex()
		PlayingData:getInstance():setRPx(px)
		PlayingData:getInstance():setRWeg(getCountWegs(fight_pokers))
		PlayingData:getInstance():setRMaxSeat(self.m_seat_pos)

		if self.m_game_ui:checkIsGameOver(self.m_current_seat) then
			PlayingData:getInstance():addNoPokersNum()
			self.m_game_ui:getRoundControl():removeSeat(self.m_seat_pos)
		end

		self.m_game_ui:roundPlaying()
	else
		print("&********ERROR：电脑第一个出牌没有随到要出的牌")
	end
end

function RobotPoker:_canFightPokers(pokers)
	local current_weg = PlayingData:getInstance():getRWeg()
	local current_px = PlayingData:getInstance():getRPx()
	current_px = current_px == 0 and 1 or current_px
	PlayingData:getInstance():setRPx(current_px)
	local table_value = poker_rula.__fightPokerByPx(pokers, current_px, current_weg) or {} --poker_rula.takerPokerByPx(pokers, current_px, current_weg) or {}
	local fight_pokers = table_value.pokers
	if fight_pokers and #fight_pokers > 0 then
		self.m_current_seat:removePokers(fight_pokers)
		self.m_current_seat:addFightPokers(fight_pokers)
		self.m_game_ui:getRoundControl():resetBuyaoNum()
		self.m_game_ui:setAllSeatsFlags()

		PlayingData:getInstance():updateRScore(poker_manager.countPokersScores(fight_pokers))
		PlayingData:getInstance():autoAddRfightIndex()
		PlayingData:getInstance():setRWeg(getCountWegs(fight_pokers))
		PlayingData:getInstance():setRMaxSeat(self.m_seat_pos)

		if self.m_game_ui:checkIsGameOver(self.m_current_seat) then
			PlayingData:getInstance():addNoPokersNum()
			self.m_game_ui:getRoundControl():removeSeat(self.m_seat_pos)
		end

		self.m_game_ui:roundPlaying()
	else
		self.m_current_seat:setBuYaoLabelVisiable(true)
		self.m_game_ui:getRoundControl():giveUp(self.m_seat_pos)
	end
end


return RobotPoker