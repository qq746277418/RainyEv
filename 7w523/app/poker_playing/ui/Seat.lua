local dir = "ui/playing_ui/"
local PlistRes = {
	sp_seat_empty = dir .. "sp_seat_empty.png",	
}

local PokerList = import(".PokerList")
local FightPokersUi = import(".FightPokersUi")
local Seat = class("Seat", function() return display.newNode() end)

function Seat:ctor(game_ui, seat_params)
	self.m_game_ui = game_ui
	self.m_pos = seat_params.pos --位置
	self.m_poker_pos = seat_params.poker_pos --手牌位置（相对）
	self.m_fight_pos = seat_params.fight_pos
	self.m_poker_is_right = seat_params.is_right

	self.m_seat_id = 0 --座位号
	self.m_is_robot = false
	self.m_score = 0  --记录这个座位玩家得到的分

	--ui
	self.m_poker_list = nil  --座位牌节点
	self.m_fight_poker_list = nil
	self.m_buyao_label = nil   --“不要”要不起

	self:pos(self.m_pos.x, self.m_pos.y)
	self:init()
end

function Seat:init()
	self.m_head_back = display.newSprite(PlistRes.sp_seat_empty)
	self.m_head_back:addTo(self)

	self.m_head_image = display.newSprite()
	self.m_head_image:addTo(self)

	--self.m_state_image = display.newSprite()

	self.m_fight_poker_list = FightPokersUi.new()
	:addTo(self)
	:pos(self.m_fight_pos.x, self.m_fight_pos.y)

	self.m_buyao_label = ww.createLabel("不要", 26, cc.c3b(255, 0, 0))
	:addTo(self)
	:hide()

	self.m_score_label = ww.createLabel("0", 26, cc.c3b(0, 0, 255))
	:addTo(self.m_head_image)
	:align(display.CENTER, -35, -35)
end

function Seat:setSeatId(id)
	self.m_seat_id = id
	self.m_is_robot = id ~= 1

	self.m_poker_list = PokerList.new(self):addTo(self)
	self.m_poker_list:pos(self.m_poker_pos.x, self.m_poker_pos.y)
end

-----------要不起
function Seat:setBuYaoLabelVisiable(ret)
	self.m_buyao_label:setVisible(ret)
end

--手牌
function Seat:addPokers(poker_ids)
	if self.m_poker_list then
		self.m_poker_list:addPokers(poker_ids)
	end
end

--失去手牌
function Seat:removePokers(pokers)
	self.m_poker_list:removePokers(pokers)
end

--游戏结束清理手牌区
function Seat:removeAllPokers()
	self.m_poker_list:removeAllPokers()
end

--上牌
function Seat:upPokers()
	self.m_poker_list:upPokers()
end

--出牌
function Seat:addFightPokers(pokers)
	self.m_fight_poker_list:addFightPokers(pokers)
end

--回合结束清理出牌区
function Seat:removeFightPokers()
	self.m_fight_poker_list:removeAllPokerSprites()
end

---------------------------------------------
function Seat:getPokerList()
	return self.m_poker_list
end

function Seat:getIsRobot()
	return self.m_is_robot
end

function Seat:getPokerIsRight()
	return self.m_poker_is_right
end

function Seat:getId()
	return self.m_seat_id
end

--手牌list调用（）
function Seat:getGameUi()
	return self.m_game_ui
end

-- function Seat:getScore()
-- 	return self.m_score
-- end
function Seat:updateScore(score)
	self.m_score = self.m_score + score
	self.m_score_label:setString(self.m_score)
	if self.m_score > 0 then
		self.m_score_label:show()
	end
end

function Seat:resetScore()
	self.m_score = 0
	self.m_score_label:hide()
end

return Seat