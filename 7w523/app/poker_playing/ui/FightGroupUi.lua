local FightGroupUi = class("FightGroupUi", function() return display.newNode() end)

function FightGroupUi:ctor(game_ui)
	self.m_game_ui = game_ui
	self.m_fight_button = nil
	self.m_buyao_button = nil
	self.m_current_seat = self.m_game_ui:getSeat(1)
	self.m_seat_pos = 1

	self:_init()
end

function FightGroupUi:_init()
	local fight_label = ww.createLabel("出牌", 24, display.COLOR_BLACK)
	self.m_fight_button = ww.createButton({normal = "ui/playing_ui/btn_run_red_nor.png"}, fight_label)
	self.m_fight_button:addTo(self)
	self.m_fight_button:onButtonClicked(handler(self, self._fightButtonEventListener))

	local buyao_label = ww.createLabel("不要", 24, display.COLOR_BLACK)
	self.m_buyao_button = ww.createButton({normal = "ui/playing_ui/btn_run_red_nor.png"}, buyao_label)
	self.m_buyao_button:addTo(self)
	self.m_buyao_button:pos(-240, 0)
	self.m_buyao_button:onButtonClicked(handler(self, self._buyaoButtonEventListener))
end

function FightGroupUi:_fightButtonEventListener(event)
	local fight_pokers = self.m_game_ui:getSeat(1):getPokerList():getSelectedPokers()
	local px = poker_rula.__fightPokerStyle(fight_pokers)
	local current_px = PlayingData:getInstance():getRPx()
	local current_weg = PlayingData:getInstance():getRWeg()
	if px then
		if current_px == 0 or current_px == px then
			local weg = poker_manager.checkFightingPokers(fight_pokers, current_weg)
			if weg then
				PlayingData:getInstance():setRPx(px)
				PlayingData:getInstance():setRWeg(weg)
				self.m_game_ui:getSeat(1):removePokers(fight_pokers)
				self.m_game_ui:getSeat(1):addFightPokers(fight_pokers)
				self.m_game_ui:getRoundControl():resetBuyaoNum()
				self.m_game_ui:setAllSeatsFlags()

				PlayingData:getInstance():updateRScore(poker_manager.countPokersScores(fight_pokers))
				PlayingData:getInstance():autoAddRfightIndex()
				PlayingData:getInstance():setRMaxSeat(1)

				if self.m_game_ui:checkIsGameOver(self.m_game_ui:getSeat(1)) then
					PlayingData:getInstance():addNoPokersNum()
					self.m_game_ui:getRoundControl():removeSeat(1)
				end

				self.m_game_ui:roundPlaying() --下一个-*
				self:hide()
			end
		end
	end
end

--不要
function FightGroupUi:giveUpFightPoker()
	local current_fight_index = PlayingData:getInstance():getRFightIndex()
	if current_fight_index ~= 1 then
		self.m_game_ui:getRoundControl():giveUp(1)
		self.m_game_ui:getSeat(1):setBuYaoLabelVisiable(true)
	else
		local pokers = self.m_game_ui:getSeat(1):getPokerList():getPokerIds()
		local table_value = poker_rula.__fightFirst(pokers) --poker_rula.traversePokers(pokers) or {}
		local fight_pokers = table_value.pokers
		local px = table_value.px
		if fight_pokers then
			self.m_current_seat:removePokers(fight_pokers)
			self.m_current_seat:addFightPokers(fight_pokers)
			self.m_game_ui:getRoundControl():resetBuyaoNum()
			self.m_game_ui:setAllSeatsFlags()

			PlayingData:getInstance():updateRScore(poker_manager.countPokersScores(fight_pokers))
			PlayingData:getInstance():autoAddRfightIndex()
			PlayingData:getInstance():setRPx(px)
			PlayingData:getInstance():setRWeg(getCountWegs(fight_pokers))
			PlayingData:getInstance():setRMaxSeat(1)

			if self.m_game_ui:checkIsGameOver(self.m_current_seat) then
				PlayingData:getInstance():addNoPokersNum()
				self.m_game_ui:getRoundControl():removeSeat(1)
			end

			self.m_game_ui:roundPlaying()
		else
			print("&********ERROR：自己第一个出牌没有随到要出的牌")
		end
	end
	self:hide()
end

function FightGroupUi:_buyaoButtonEventListener(event)
	self:giveUpFightPoker()
end

function FightGroupUi:showFightGroupUi(ret)
	local current_fight_index = PlayingData:getInstance():getRFightIndex()
	self.m_buyao_button:setVisible(current_fight_index ~= 1)
	self:setVisible(ret)
end

return FightGroupUi
