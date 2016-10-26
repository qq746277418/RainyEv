PlayingData = class("PlayingData")
PlayingData.instance = nil

function PlayingData.getInstance()
	if not PlayingData.instance then
		PlayingData.instance = PlayingData.new()
	end
	return PlayingData.instance
end

function PlayingData:ctor()
	self.m_surplus_pokers = {}
	self.m_base_seconds = 30
	self.m_player_num = 0
	self.m_poker_zorder = 0  --手牌要重新排序、上牌等（zorder）
	self.m_nosurplus_poker = false

	self.m_game_over = false

	self.m_rmax_seat = 1
	self.m_rpx = 0
	self.m_rweg = 0

	math.randomseed(os.time())

	self:set()
end

function PlayingData:set(game_params)
	game_params = game_params or {}
	self.m_surplus_pokers = {}
	for i=1,54 do
		table.insert(self.m_surplus_pokers, #self.m_surplus_pokers + 1, i)
	end
	self.m_base_seconds = game_params.base_seconds or 15
	self.m_player_num = game_params.player_num or 3
	
	self.m_poker_zorder = 0
	self.m_nosurplus_poker = false
	self.m_game_over = false
	self.m_nopokers_num = 0  --没有手牌的玩家数+1等于总人数，游戏结束

	self.m_rmax_seat = 0
	self.m_racitve_seat = 0
	self.m_rpx = 0
	self.m_rweg = 0
	self.m_rscore = 0  --当前回合产生的分（回合结束加到对应的玩家上）
	self.m_rfight_index = 1  --当前回合第几个出牌
end

--======================================
--初始发牌data
function PlayingData:randPokers(num)
	local poker_ids = {}  --暂存随机出来的
	for i=1,num do
		local id = math.random(1, #self.m_surplus_pokers)
		poker_ids[i] = self.m_surplus_pokers[id]
		table.remove(self.m_surplus_pokers, id)
		if #self.m_surplus_pokers <= 0 then
			self.m_nosurplus_poker = true
		end
	end
	GameDispatchData:getInstance():dispatchData(GameDataIds.kGameSurplusPokers, #self.m_surplus_pokers)

	return poker_ids
end

function PlayingData:randDealPokers()
	local deal_pokers = {}
	for i=1,self.m_player_num do
		table.insert(deal_pokers, {seat_pos = i, pokers = self:randPokers(5)})
	end
	return deal_pokers
end

---------------------------------------------------
function PlayingData:getBaseSecond()
	return self.m_base_seconds
end

function PlayingData:getNormalPokers()
	return self.m_surplus_pokers
end

function PlayingData:getPlayerNum()
	return self.m_player_num
end

function PlayingData:getRMaxSeat()
	return self.m_rmax_seat
end

function PlayingData:setRMaxSeat(seat)
	self.m_rmax_seat = seat
end

function PlayingData:getRActiveSeat()
	return self.m_racitve_seat
end

function PlayingData:setRActiveSeat(seat)
	self.m_racitve_seat = seat
end

function PlayingData:getRPx()
	return self.m_rpx
end

function PlayingData:setRPx(px)
	self.m_rpx = px
end

function PlayingData:getRWeg()
	return self.m_rweg
end

function PlayingData:setRWeg(weg)
	self.m_rweg = weg
end

function PlayingData:getPokerZorder(sub)
	sub = sub or 1
	local zorder = self.m_poker_zorder
	self.m_poker_zorder = self.m_poker_zorder + sub
	return zorder
end

function PlayingData:getNoSurplusPoker()
	return self.m_nosurplus_poker
end

function PlayingData:getGameOverFlag()
	return self.m_game_over
end

function PlayingData:setGameOverFlag(ret)
	self.m_game_over = ret
end

function PlayingData:addNoPokersNum()
	self.m_nopokers_num = self.m_nopokers_num + 1
	if self.m_nopokers_num + 1 == self.m_player_num then
		--游戏结束
		GameDispatchData:getInstance():dispatchData(GameDataIds.kGameOver, true)
	end
end

function PlayingData:updateRScore(score)
	self.m_rscore = self.m_rscore + score
end

function PlayingData:resetRScore()
	self.m_rscore = 0
end

function PlayingData:getRScore()
	return self.m_rscore
end

function PlayingData:getRFightIndex()
	return self.m_rfight_index
end

function PlayingData:resetRFightIndex()
	self.m_rfight_index = 1
end

function PlayingData:autoAddRfightIndex()
	self.m_rfight_index = self.m_rfight_index + 1
end