poker_manager = {}
poker_manager.card_type = {
	single_card = 1,
	double_card = 2,
	three_card  = 3,
	bomb_card = 4,
	three_one_card = 5,
	three_two_card = 6,
	error_card = 7
}

--用计算排序手牌权重
-- poker_manager.countPokerWeight = function(poker_ids) 
-- 	--手牌ids
-- 	local tmp = {}
-- 	for _,val in pairs(poker_ids) do
-- 		table.insert(tmp, #tmp + 1, poker_data[val])
-- 	end
-- 	poker_ids = {}
-- 	local sortFunc = function(a, b) return a.weg > b.weg end
-- 	table.sort(tmp, sortFunc)

-- 	for _,val in pairs(tmp) do
-- 		table.insert(poker_ids, #poker_ids + 1, val.id)
-- 	end
-- 	return poker_ids
-- end

poker_manager.countPokersScores = function(poker_ids)
	local tscore = 0
	for _,id in pairs(poker_ids) do
		local score = getPokerScore(id)
		tscore = tscore + score
	end
	return tscore
end

poker_manager.countPokerWegUp = function(poker_ids)
	--手牌ids
	local tmp = {}
	for _,val in pairs(poker_ids) do
		table.insert(tmp, #tmp + 1, poker_data[val])
	end
	poker_ids = {}
	local sortFunc = function(a, b) return a.weg < b.weg end
	table.sort(tmp, sortFunc)

	for _,val in pairs(tmp) do
		table.insert(poker_ids, #poker_ids + 1, val.id)
	end
	return poker_ids
end

poker_manager.kickoffScorePoker = function(poker_ids)
	local pokerIds = {}
	for _,val in pairs(poker_ids) do
		if getPokerScore(val) == 10 or getPokerScore(val) == 5 then
		else
			table.insert(pokerIds, #pokerIds + 1, val)
		end
	end
	return pokerIds
end

--fighting(这里可能不需要检测牌型是否一致， 只检测权重)
poker_manager.checkFightingPokers = function(poker_ids, fight_weg)
	local fight_weg = fight_weg or 0
	local weg = getCountWegs(poker_ids)
	if weg > fight_weg then
		return weg
	end
end



--========检查是否合法================================================
poker_manager.checkPokersStyle = function(pokers)
	local px = nil
	if #pokers == 1 then
		px = poker_manager.card_type.single_card
	elseif #pokers == 2 then
		px = poker_manager._checkPairsPokers(pokers)
	elseif #pokers == 3 then
		px = poker_manager._threePokers(pokers)
	elseif #pokers == 4 then
		px = poker_manager._checkBoomPokers(pokers)
	end
	return px
end

poker_manager._checkPairsPokers = function(pokers) 
	if getPokersValueEqual(pokers) then
		return poker_manager.card_type.double_card
	end
end

poker_manager._threePokers = function(pokers)
	if getPokersValueEqual(pokers) then
		return poker_manager.card_type.three_card
	end
end

poker_manager._checkBoomPokers = function(pokers)
	if getPokersValueEqual(pokers) then
		return poker_manager.card_type.bomb_card
	end
end
--====================================================================
--ai(托管, 牌型提取)
--提取牌型 对应的牌且权重能大（这个是根据牌型提取）
poker_manager.takePokersByPx = function(pokers, px, weg)
	local weg = weg or 0
	local check_handlers = {}
	check_handlers[poker_manager.card_type.single_card] = poker_manager._takeSinglePoker
	check_handlers[poker_manager.card_type.double_card] = poker_manager._takeDoublePokers
	check_handlers[poker_manager.card_type.three_card] = poker_manager._tableThreePokers
	check_handlers[poker_manager.card_type.bomb_card] = poker_manager._takeBombPokers
	check_handlers[poker_manager.card_type.three_one_card] = poker_manager._takeThreeOnePoker
	check_handlers[poker_manager.card_type.three_two_card] = poker_manager._takeThreeTwoPokers

	if check_handlers[px] then
		return check_handlers[px](pokers, weg)
	end
end

poker_manager._takeSinglePoker = function(pokers, weg) 
	local weg = weg or 0
	local pokers = poker_manager.countPokerWegUp(pokers)
	--取最小的
	for _,val in pairs(pokers) do
		if poker_data[val].weg > weg then
			PlayingData:getInstance():setRWeg(poker_data[val].weg)
			return {val}
		end
	end
end

--对子
poker_manager._takeDoublePokers = function(pokers, weg)
	local weg = weg or 0
	local pokers = poker_manager.countPokerWegUp(pokers)
	local double_pokers = {}
	for id,val in pairs(pokers) do
		if id > 1 then
			if poker_data[pokers[id -1]].value == poker_data[val].value and
				(poker_data[pokers[id -1]].weg + poker_data[val].weg) > weg then
				PlayingData:getInstance():setRWeg(poker_data[pokers[id -1]].weg + poker_data[val].weg)
				return {pokers[id -1], val}
			end
		end
	end
end

--三张
poker_manager._tableThreePokers = function(pokers, weg)
	local pokers = poker_manager.countPokerWegUp(pokers)
	if #pokers < 3 then return end
	if getPokerValue(pokers[1]) == getPokerValue(pokers[2]) and 
		getPokerValue(pokers[2]) == getPokerValue(pokers[3]) and
		getCountWegs(pokers) > weg then
		return pokers
	end
end

--炸弹(四张）
poker_manager._takeBombPokers = function(pokers, weg)
	if getPokersValueEqual(pokers) and #pokers == 4 and getCountWegs(pokers) > weg then
		return pokers
	end
end

--重复度

--三带一
poker_manager._takeThreeOnePoker = function(pokers, weg)
	
end

--三带二
poker_manager._takeThreeTwoPokers = function(pokers, weg)
	
end

--=============出牌优先查找========================================