local RoundControl = class("RoundControl")

--每一局游戏一致
function RoundControl:ctor(game_ui)
	self.m_game_ui = game_ui
	
	self:set()
end

function RoundControl:set()
	self.m_seat_num = PlayingData:getInstance():getPlayerNum()
	self.m_seat_pos = {}  --人数座位号
	self.m_seat_const_pos = {}

	self.m_current_index = 0
	self.m_current_seat = 0
	self.m_buyao_num = 0  --连续两家不要 结束

	for i=1,self.m_seat_num do
		table.insert(self.m_seat_const_pos, #self.m_seat_const_pos + 1, i)
	end
end

function RoundControl:_seatOrderChange1(seat)
	self.m_seat_pos = {}
	--if seat > 1 then
		local tmp = {}
			for id,val in pairs(self.m_seat_const_pos) do
				if val >= seat then
					table.insert(tmp, #tmp + 1, val)
				end
			end

			for id,val in pairs(self.m_seat_const_pos) do
				if val < seat then
					table.insert(tmp, #tmp + 1, val)
				end
			end

		self.m_seat_pos = tmp
	-- else
	-- 	for i=1,self.m_seat_num do
	-- 		table.insert(self.m_seat_pos, #self.m_seat_pos + 1, i)
	-- 	end
	-- end
end

function RoundControl:giveUp(seat)
	self.m_buyao_num = self.m_buyao_num + 1
	if self.m_buyao_num == self.m_seat_num - 1 then
		local max_seat = PlayingData:getInstance():getRMaxSeat()
		self.m_game_ui:getSeat(max_seat):updateScore(PlayingData:getInstance():getRScore())
		self.m_game_ui:getRoundControl():setBeganFightSeat1(max_seat)
		self.m_game_ui:roundCount() 
	else
		self.m_game_ui:roundPlaying() --下一个出牌
	end
end

--最后回合，有人出完牌了
function RoundControl:removeSeat(seat)
	for i,val in pairs(self.m_seat_const_pos) do
		if val == seat then
			table.remove(self.m_seat_const_pos, i)
			self.m_seat_num = self.m_seat_num - 1
			self.m_current_index = self.m_current_index - 1
		end
	end
	for i,val in pairs(self.m_seat_pos) do
		if val == seat then
			table.remove(self.m_seat_pos, i)
		end
	end
	dump(self.m_seat_const_pos)
	dump(self.m_seat_pos)
end

--获取当前活动的位置
function RoundControl:getFightingSeat()
	if self.m_current_index > self.m_seat_num then
		self.m_current_index = 1
	end
	local seat = self.m_seat_pos[self.m_current_index]
	self.m_current_index = self.m_current_index + 1
	if not seat then
		dump(self.m_seat_pos)
		print("_________not seat_______", self.m_current_index)
	end
	self.m_current_seat = seat
	return seat
end

function RoundControl:resetBuyaoNum()
	self.m_buyao_num = 0
end

function RoundControl:getSeatPos()
	return self.m_seat_pos
end

--顺序出牌---------------
function RoundControl:setBeganFightSeat1(seat)
	self.m_current_index = 1
	self.m_current_seat = 0
	self:_seatOrderChange1(seat)
end

return RoundControl