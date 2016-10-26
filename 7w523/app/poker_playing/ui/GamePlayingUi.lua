--data
import("..data.poker_data")
import("..data.seat_positions")
--modules
import("..modules.PlayingData")
import("..modules.poker_manager")
import("..modules.poker_rula")
import("..modules.PlayingConst")
--contorl
import("..control.GameDataId")
import("..control.GameDispatchData")
local RoundControl = import("..control.RoundControl")
local RobotPoker = import("..control.RobotPoker")
--ui
local Seat = import(".Seat")
local DealPokerUi = import(".DealPokerUi")
local FightGroupUi = import(".FightGroupUi")
local SecondTimerUi = import(".SecondTimerUi")

local GamePlayingUi = class("GamePlayingUi", function() return display.newLayer() end)

function GamePlayingUi:ctor(game_params)  --game_params 游戏参数
	self.m_game_params = game_params
	PlayingData:getInstance():set(self.m_game_params)
	self:setNodeEventEnabled(true)
	self.m_seat_list = {}
	self.m_game_stage = PlayingConst.GameStage.normal
	self.m_fight_group_ui = nil
	self.m_round_control = nil
	self.m_robot_control = nil
	self.m_second_timer_ui = nil

	--阶段性节点(重新开始需要初始化)
	self.m_deal_ui = nil

	self:_init()
	self:_connectObserver()
end

function GamePlayingUi:_init()
	local background = ww.createBackGround(CommonRes.bg_0001)
	background:addTo(self)

	--根据人数初始化座位（游戏开始不可改动）
	local positions = seat_positions[PlayingData:getInstance():getPlayerNum()]
	for id,val in pairs(positions) do
		self.m_seat_list[id] = Seat.new(self, val):addTo(self)
		self.m_seat_list[id]:setSeatId(id)
	end

	self.m_fight_group_ui = FightGroupUi.new(self)
	self.m_fight_group_ui:addTo(self)
	self.m_fight_group_ui:pos(display.right - 150, 100)
	self.m_fight_group_ui:hide()

	self.m_round_control = RoundControl.new(self)
	self.m_round_control:setBeganFightSeat1(1) --第一回合先从玩家开始

	self.m_robot_control = RobotPoker.new(self)

	self.m_second_timer_ui = SecondTimerUi.new()
	self.m_second_timer_ui:retain()

	self:stageControl(PlayingConst.GameStage.deal_poker)
	--local boom_array = poker_rula.__takePokerByDouble({1,2, 2,4, 6}, 0)
	--self.m_round_control:_seatOrderChange1(3)

	local tip_label = ww.createLabel("大小牌序:7、王、5、2、3")
	---------------------------------------------------------
	local back_label = ww.createLabel("返回", 24, display.COLOR_BLACK)
	self.m_back_btn = ww.createButton({normal = "ui/playing_ui/btn_run_red_nor.png"}, back_label)
	self.m_back_btn:addTo(self)
	self.m_back_btn:hide()
	self.m_back_btn:pos(display.cx, 200)
	self.m_back_btn:onButtonClicked(function() 
		self:removeFromParent()
		end)
	local restart_label = ww.createLabel("重新开始", 24, display.COLOR_BLACK)
	self.m_restart_btn = ww.createButton({normal = "ui/playing_ui/btn_run_red_nor.png"}, restart_label)
	self.m_restart_btn:addTo(self)
	self.m_restart_btn:hide()
	self.m_restart_btn:pos(display.cx + W(self.m_back_btn) + 30, 200)
	self.m_restart_btn:onButtonClicked(function() 
		self:restart()
		end)
end

function GamePlayingUi:_connectObserver()
	GameDispatchData:getInstance():addObserver(GameDataIds.kGameStage, handler(self, self.stageControl))
	GameDispatchData:getInstance():addObserver(GameDataIds.kGameOver, handler(self, self._gameOver))
	GameDispatchData:getInstance():addObserver(GameDataIds.kGameRoundBegan, handler(self, self._newRoundBegan))
	
end

function GamePlayingUi:_unconnectObserver()
	GameDispatchData:getInstance():removeObserver(GameDataIds.kGameStage)
	GameDispatchData:getInstance():removeObserver(GameDataIds.kGameOver)
	GameDispatchData:getInstance():removeObserver(GameDataIds.kGameRoundBegan)
end

function GamePlayingUi:onExit()
	self:_unconnectObserver()
	self:reset()
end

function GamePlayingUi:stageControl(stage)
	self.m_stage_handlers = {}
	self.m_stage_handlers[PlayingConst.GameStage.deal_poker] = handler(self, self._dealingStage)
	self.m_stage_handlers[PlayingConst.GameStage.fighting] = handler(self, self._fightingStage)
	self.m_game_stage = stage
	if self.m_stage_handlers[stage] then
		self.m_stage_handlers[stage]()
	end
end

function GamePlayingUi:_gameOver(data)
	self:stageControl(PlayingConst.GameStage.counting)
	PlayingData:getInstance():setGameOverFlag(true)
	TipBox:getInstance():createTipLabel("提示", "游戏结束")

	self:overReset()
end

--(游戏结束重置)
function GamePlayingUi:overReset()
	--需要重置一些节点
	if self.m_deal_ui then
		self.m_deal_ui:removeFromParent()
		self.m_deal_ui = nil
	end

	self.m_second_timer_ui:hide()
	for _,seat in pairs(self.m_seat_list) do
		seat:removeAllPokers()
		seat:removeFightPokers()
		seat:resetScore()
		seat:setBuYaoLabelVisiable(false)
	end
	
	self.m_back_btn:show()
	self.m_restart_btn:show()
end

function GamePlayingUi:reset()
	PlayingData:getInstance():set(self.m_game_params)
end

function GamePlayingUi:restart()
	self:reset()
	self.m_back_btn:hide()
	self.m_restart_btn:hide()
	self.m_round_control:set()
	self.m_round_control:setBeganFightSeat1(1) --第一回合先从玩家开始
	self:stageControl(PlayingConst.GameStage.deal_poker)
end

----------------------------------------------------------------------
--timer ui
function GamePlayingUi:showTimerUi(seat_pos)
	self.m_second_timer_ui:show()
	self.m_second_timer_ui:removeFromParent()
	self.m_second_timer_ui:addTo(self.m_seat_list[seat_pos])
	self.m_second_timer_ui:start(PlayingData:getInstance():getBaseSecond(), handler(self, self._timerListeners))
end

function GamePlayingUi:_timerListeners()
	local current_seat = PlayingData:getInstance():getRActiveSeat()
	if current_seat == 1 and self.m_fight_group_ui then
		self.m_fight_group_ui:giveUpFightPoker()
	end
end

function GamePlayingUi:_dealingStage()
	if not self.m_deal_ui then
		local deal_pokers = PlayingData:getInstance():randDealPokers()
		self.m_deal_ui = DealPokerUi.new(self.m_seat_list, deal_pokers)
		:addTo(self)
	end
end

--============================================
--出牌阶段(回合)
function GamePlayingUi:_resetSeatFlags()
	local pokerid_table = {}
	local nosurplus_index = 0
	for seat_pos = 1, PlayingData:getInstance():getPlayerNum() do
		local seat = self.m_seat_list[seat_pos]
		seat:setBuYaoLabelVisiable(false)
		seat:removeFightPokers()
	end

	for _,seat_pos in pairs(self.m_round_control:getSeatPos()) do
		local seat = self.m_seat_list[seat_pos]
		local num = 5 - #seat:getPokerList():getPokerList()
		local rand_pokers = PlayingData:getInstance():randPokers(num)
		table.insert(pokerid_table, {seat_pos = seat_pos, pokers = rand_pokers})
	end

	self.m_deal_ui:resetDealPokers(pokerid_table)
end

--单独重置“不要”标记 (每有一个人出牌就重置)
function GamePlayingUi:setAllSeatsFlags()
	for _,seat in pairs(self.m_seat_list) do
		seat:setBuYaoLabelVisiable(false)
	end
end

--(回合)
function GamePlayingUi:roundCount()
	--[在roundcontrol里有调用 只剩下最后一个人时，回合结束]
	--回合结算(结算完下一回合开始) 保证顺序走完结算延迟5s
	--重置掉座位的一些显示设置（要不起标记）
	--桌上没有余牌切两家没有手牌（游戏结束）
	self.m_second_timer_ui:hide()
	PlayingData:getInstance():setRWeg(0)
	PlayingData:getInstance():setRPx(0)
	PlayingData:getInstance():resetRScore()
	PlayingData:getInstance():resetRFightIndex()

	local seq = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() 
		self:_resetSeatFlags()
		end))
	self:runAction(seq)
end

--检测牌局是否结束
function GamePlayingUi:checkIsGameOver(seat)
	local nosurplus = PlayingData:getInstance():getNoSurplusPoker()
	if nosurplus then
		if #seat:getPokerList():getPokerList() == 0 then
			--self.m_round_control:removeRandSeat(seat:getId())
			return true
		end
	end
end

--新回合开始
function GamePlayingUi:_newRoundBegan()
	self:roundPlaying()
end

--[[
	电脑不会超时，玩家超时按要不起处理
]]

function GamePlayingUi:roundPlaying()
	if not PlayingData:getInstance():getGameOverFlag() then
		local seat = self.m_round_control:getFightingSeat()
		if seat ~= 0 then
			PlayingData:getInstance():setRActiveSeat(seat)
			if #self.m_seat_list[seat]:getPokerList():getPokerList() > 0 then
				--self:showTimerUi(seat)
				self.m_fight_group_ui:showFightGroupUi(seat == 1)
			end
			self:showTimerUi(seat)
			self.m_robot_control:fightPokers(seat)
		end
	end
end

function GamePlayingUi:_fightingStage()
	TipBox:getInstance():createTipLabel("提示", "游戏开始")
	self:roundPlaying()
end

----------------------------------------
function GamePlayingUi:getSeat(seat_pos)
	return self.m_seat_list[seat_pos]
end

function GamePlayingUi:getRoundControl()
	return self.m_round_control
end

function GamePlayingUi:getDealUi()
	return self.m_deal_ui
end

return GamePlayingUi