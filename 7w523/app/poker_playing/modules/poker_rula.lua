--todo:提取牌型优先级
--单牌提取优先级(value){7、大王、5、k、10、小王、2、3 ...}
--[[
	特殊：
	1.手上有制大牌时，【k、10】优先级在正常位置
]]
single_poker_nolarge_priority = {7,15,5,13,10,14,2,3, 1,4,6,8,9,11,12}
single_poker_large_priority = {7,15,14,5,2,3,1,13,12,11,10,9,8,6,4}
--单张的打牌（被认为打分可以抓）  --todo:这里可能要做一个特殊牌统计,先简单处理（只要存在以下牌，视为大牌）
local sigle_poker_large = {7,15,14,5}


local single_poker_10score = {20, 33, 46}  --分数不大于10，留着不打
local single_poker_5score = {7, 53, 54}  --分数不大于5，留着不打

local function checkSinglePokerNo10Score(id)
	if not id then return false end
	for _,val in pairs(single_poker_10score) do
		if id == val then
			return true
		end
	end
end

local function checkSinglePokerNo5Score(id)
	if not id then return false end
	for _,val in pairs(single_poker_5score) do
		if id == val then
			return true
		end
	end
end


--暂时不需要特殊判断的值
local double_pokers_nomal_priority = {1,4,6,8,9,11,12}
--需要做特殊判断
local double_pokers_priority = {7,15,14,5,2,3}
--单子对子（如果是以下牌值可做相应保留）
local double_pokers_onlyone = {7,15,14,2, 13, 10}  --对5比较逆天了 可以直接出掉，很高概率那分

-------------------------------------------------------------
local function checkLargePoker(ids)
	for _,id in pairs(ids) do
		for _,val in pairs(sigle_poker_large) do
			if getPokerValue(id) == val then
				return true  --有可以做大的牌(估值)
			end
		end		
	end
	return false
end

local function checkOnlyOneDoublePoekrs(value)
	for _,val in pairs(double_pokers_onlyone) do
		if val == value then
			return true
		end
	end
	return false
end

--对子提取优先级(value)
--[[
	普通情况下，跟单牌提取规则一样；且优先对子
	1. 【7、王、5、2、3】这里面的对子存在时，如果有两对，则出掉一个小对
	2. 【k、10】
]]

--第一个出牌（当前没有牌型）第一个出牌不需要判断当前是否需要抓分
--遍历手牌的各种牌型并找出最合适的一种牌型
--三带一 三带二 三个 暂时被排除
poker_rula = {}

poker_rula.card_type = {
	single_card = 1,
	double_card = 2,
	three_card  = 3,
	bomb_card = 4,
	three_one_card = 5,
	three_two_card = 6,
	error_card = 7
}

--[[
	自动出牌，根据牌型检测对应的牌，
	1.单牌 找出所有能出的牌，有可大的牌，顺序出；否则剃掉分数牌，再出
	2.对子（能出的对子） 【找出一个对子且是特殊大对子，有分出，无分不出； 
	找出两个对子，1.无分对，出小对；2.有分对，】

	--和第一个出牌相同过程：检测所有能出的对子（根据权重），检测是否有大牌
]]

---局部函数----
--找出所有能出的单牌
local function kickoffWegMinPokers(pokers, weg)
	local pokerIds = {}
	for _,val in pairs(pokers) do
		if getPokerWeg(val) > weg then
			table.insert(pokerIds, #pokerIds + 1, val)
		end
	end
	pokerIds = poker_manager.countPokerWegUp(pokerIds)
	return pokerIds
end

local function checkPokerIdRepeat(pokers)
	local pokers_ = {}
	for _,val in pairs(pokers) do
		table.insert(pokers_, {id = val, value = getPokerValue(val)})
	end
	local tmp = {}
	for _,val in pairs(pokers_) do
		if not tmp[val.value] then
			tmp[val.value] = {value = val.value, rep = 1, id = val.id, ids = {val.id}}
		else
			tmp[val.value].rep = tmp[val.value].rep + 1
			table.insert(tmp[val.value].ids,#tmp[val.value].ids+1, val.id)
		end
	end
	return tmp
end

--获取两对中权重小的那个
local function getTwoDoubleMin(pokers)
	return getCountWegs(pokers[1]) > getCountWegs(pokers[2]) and pokers[2] or pokers[1]
end

--只提供接口
--取牌
function poker_rula.__takePokerByBoom(pokers)
	if #pokers >= 4 then
		local tmp_table = checkPokerIdRepeat(pokers)
		for _,val in pairs(tmp_table) do
			if val.rep == 4 then
				return {pokers = val.ids, weg = getCountWegs(val.ids)}
			end
		end
	end
	return
end

function poker_rula.__takePokerBySanZ(pokers)
	if #pokers >= 3 then
		local tmp_table = checkPokerIdRepeat(pokers)
		local isTip = false
		for _,val in pairs(tmp_table) do
			if val.rep >= 3 then
				if val.value == 7 then
					isTip = true
				end
				return {pokers = val.ids, weg = getCountWegs(val.ids), is_tip = isTip}
			end
		end
	end
	return
end

function poker_rula.__takePokerBySanDaiYi(pokers)
	--带的这一张有什么规则(优先分，其次从小到大，只有带到7时才提示) 提示作用：根据当前分值判断要不要带出去抓分
	--炸弹 当成拿不出三张处理（可以直接炸呀 傻X， 极其特殊四个七除外）
	if #pokers < 4 then return end
	local poker_table = checkPokerIdRepeat(pokers)
	local pokerIds = {}
	local compares = {}
	local isTip = false
	local Weg = 0
	for _,val in pairs(poker_table) do
		if val.rep == 3 then
			pokerIds = val.ids
			Weg = getCountWegs(val.ids)
		elseif val.rep == 2 then
			table.insert(pokerIds, #pokerIds+1, val.id)
			if val.value == 7 then
				isTip = true
			end
		elseif val.rep == 1 then
			table.insert(compares, val)
		end
	end
	--取三带一 只有一张后者两张选一张的情况
	if #compares == 2 then
		--todo:以后再想，这两个数如果是分的话，优先选分
		local value =  getPokerWeg(compares[1].id) > getPokerWeg(compares[2].id) and compares[2] or compares[1]
		table.insert(pokerIds, #pokerIds+1, value.id)
		if value.value == 7 then
			isTip = true
		end
	elseif #compares == 1 then
		table.insert(pokerIds, #pokerIds+1, compares[1].id)
		if compares[1].value == 7 then
			isTip = true
		end
	end

	if #pokerIds < 4 then
		return 
	end
	dump(pokerIds)
	return {pokers = pokerIds, is_tip = isTip, weg = Weg}
end

function poker_rula.__takePokerBySanDaiEr(pokers)
	if #pokers < 5 then return end
	local poker_table = checkPokerIdRepeat(pokers)
	local pokerIds = {}
	local compares = {}
	local Weg = 0
	local isTip = false
	for _,val in pairs(poker_table) do
		if val.rep == 3 then
			pokerIds = val.ids
			Weg = getCountWegs(val.ids)
		elseif val.rep == 2 then
			table.insert(pokerIds, #pokerIds+1, val.id)
			if val.value == 7 then
				isTip = true
			end
		elseif val.rep == 1 then
			table.insert(compares, val)
		end
	end
	--取三带一 只有一张后者两张选一张的情况
	if #compares == 2 then
		for _,val in pairs(compares) do
			table.insert(pokerIds, #pokerIds+1, val.id)
			if val.value == 7 then
				isTip = true
			end
		end
	end

	if #pokerIds < 5 then
		return 
	end
	dump(pokerIds)
	return {pokers = pokerIds, is_tip = isTip, weg = Weg}
end

function poker_rula.__takePokerByDouble(pokers)
	--对子可能有两个
	if #pokers < 2 then return end
	local poker_table = checkPokerIdRepeat(pokers)
	local pokerIds = {}
	local isTip = false
	for _,val in pairs(poker_table) do
		if val.rep == 2 or val.rep == 3 or val.rep == 4 then
			local tmp = {}
			for i=1,2 do
				table.insert(tmp, val.ids[i])
			end
			table.insert(pokerIds, #pokerIds+1, tmp)
		end
	end
	if #pokerIds > 0 then
		return {pokers = pokerIds}
	end
end

function poker_rula.__takePokerBySingle(pokers)
	return pokers
end

--剔除所有重复的牌
function poker_rula.__kickoffAllRepeatPoker(pokers)
	local tmp_table = checkPokerIdRepeat(pokers)
	local pokerIds = {}
	for _,val in pairs(tmp_table) do
		if val.rep == 1 then
			table.insert(pokerIds, val.id)
		end
	end
	return pokerIds
end

--剔除掉所有分牌

--=====================================================
---AI: 根据牌型取得要出的牌
function poker_rula.__fightPokerByPx(pokers, px, weg)
	local weg = weg or 0
	local check_handlers = {}
	check_handlers[poker_rula.card_type.single_card] = poker_rula.__checkSinglePokerByWeg
	check_handlers[poker_rula.card_type.double_card] = poker_rula.__checkDoublePokerByWeg
	check_handlers[poker_rula.card_type.three_card] = poker_rula.__checkThreePokers
	check_handlers[poker_rula.card_type.bomb_card] = poker_rula.__checkBoomPokers
	check_handlers[poker_rula.card_type.three_one_card] = poker_rula.__checkThreeOnePokers
	check_handlers[poker_rula.card_type.three_two_card] = poker_rula.__checkThreeTwoPokers

	print("当前牌型____________________________", px)
	local table_value = check_handlers[px](pokers, weg)
	return table_value
end
--=============================================================
function poker_rula.singlePokerStyleAI()

end

function poker_rula.doublePokerStyleAI()

end
--=============================================================

--两点：：：：：出牌当张逻辑
function poker_rula.__checkSinglePokerByWeg(pokers, weg)
	local pokerIds = poker_rula.__kickoffAllRepeatPoker(pokers)  --这里会除开双牌
	pokerIds = kickoffWegMinPokers(pokerIds, weg)
	if #pokerIds == 0 then

	elseif #pokerIds == 1 then

	else

	end
	local fight_poker = pokerIds[1]
	local current_score = PlayingData:getInstance():getRScore()
	local no_surplus = PlayingData:getInstance():getNoSurplusPoker()  --没有剩余的牌了

	--还不是最后的回合
	--如果只有一张零散的牌，这个时候就要拆对出
	--如果一张令牌都没有呢
	if not no_surplus then
		if checkSinglePokerNo5Score(fight_poker) then
			if current_score < 5 then
				fight_poker = nil
			end
		elseif checkSinglePokerNo10Score(fight_poker) then
			if current_score < 10 then
				fight_poker = nil
			end
		end
	end

	return {pokers = {fight_poker}}
end

function poker_rula.__checkDoublePokerByWeg(pokers, weg)
	local table_value = poker_rula.__takePokerByDouble(pokers)
	if table_value then
		local pokers = table_value.pokers
		local Weg = getCountWegs(pokers[1])
		if Weg > weg then
			return {pokers = pokers[1]}
		end
	end
end

function poker_rula.__checkThreePokers(pokers, weg)
	local table_value = poker_rula.__takePokerBySanZ(pokers)
	if table_value then
		local Weg = table_value.weg
		local pokers = table_value.pokers
		local is_tip = table_value.is_tip
		if Weg > weg then
			return table_value
		end
	end
end

function poker_rula.__checkThreeOnePokers(pokers, weg)
	local table_value = poker_rula.__takePokerBySanDaiYi(pokers)
	if table_value then
		local Weg = table_value.weg
		local pokers = table_value.pokers
		local is_tip = table_value.is_tip
		if Weg > weg then
			return table_value
		end
	end
end

function poker_rula.__checkThreeTwoPokers(pokers, weg)
	local table_value = poker_rula.__takePokerBySanDaiEr(pokers)
	if table_value then
		local Weg = table_value.weg
		local pokers = table_value.pokers
		local is_tip = table_value.is_tip
		if Weg > weg then
			return table_value
		end
	end
end

function poker_rula.__checkBoomPokers(pokers, weg)
	local table_value = poker_rula.__takePokerByBoom(pokers) 
	if table_value then
		local Weg = table_value.weg
		local pokers = table_value.pokers
		 if Weg > weg then
			return table_value
		end
	end
end

--AI: 第一个出牌的时候
poker_rula.card_type = {
	single_card = 1,
	double_card = 2,
	three_card  = 3,
	bomb_card = 4,
	three_one_card = 5,
	three_two_card = 6,
	error_card = 7
}
function poker_rula.__fightFirst(pokers)
	local boom_table = poker_rula.__takePokerByBoom(pokers)
	local three_two_table = poker_rula.__takePokerBySanDaiEr(pokers)
	local three_one_table = poker_rula.__takePokerBySanDaiYi(pokers)
	local three_table = poker_rula.__takePokerBySanZ(pokers)
	local double_table = poker_rula.__takePokerByDouble(pokers)
	if three_two_table then
		if not three_two_table.is_tip then
			return {pokers = three_two_table.pokers, px = poker_rula.card_type.three_two_card}
		end
	end
	if three_one_table then
		if not three_one_table.is_tip then
			return {pokers = three_one_table.pokers, px = poker_rula.card_type.three_one_card}
		end
	end
	if three_table then
		if not three_table.is_tip then
			return {pokers = three_table.pokers, px = poker_rula.card_type.three_card}
		end
	end

	if double_table then
		--最后一个回合 有对就出
		if #double_table.pokers == 2 then
			pokers = getTwoDoubleMin(double_table.pokers)
		elseif #double_table.pokers == 1 then
			pokers = double_table.pokers[1]
		end
		return {pokers = pokers, px = poker_rula.card_type.double_card}
	end
	--执行到这里只剩单牌了(第一个出 出最小的一个)
	local pokers = poker_manager.countPokerWegUp(pokers)
	return {pokers = {pokers[1]}, px = poker_rula.card_type.single_card}
end

--============检测玩家出牌的牌型是否符合规则===================
function poker_rula.__fightPokerStyle(pokers)
	if #pokers == 1 then return poker_rula.card_type.single_card end
	if #pokers == 2 and getPokerValue(pokers[1]) == getPokerValue(pokers[2]) then
		return poker_rula.card_type.double_card
	end
	if #pokers == 3 and getPokerValue(pokers[1]) == getPokerValue(pokers[2]) and
		getPokerValue(pokers[2]) == getPokerValue(pokers[3]) then
		return poker_rula.card_type.three_card
	end

	local px = poker_rula.__checkStyleBoom(pokers)
	if px then return px end
	px = poker_rula.__checkStyleSanDaiY(pokers)
	if px then return px end
	px = poker_rula.__checkStyleSanDaiEr(pokers)
	if px then return px end
	print("----任何一种牌型都不是----傻叉了不是----")
	dump(pokers)
end

function poker_rula.__checkStyleBoom(pokers)
	if #pokers == 4 then
		local first_value = getPokerValue(pokers[1]) 
		local ret = true
		for _,val in pairs(pokers) do
			if getPokerValue(val) ~= first_value then
				ret = true
			end
		end
		if ret then
			return poker_rula.card_type.bomb_card
		end
	end
	return
end

function poker_rula.__checkStyleSanDaiY(pokers)
	if #pokers == 4 then
		local tmp_table = checkPokerIdRepeat(pokers)
		for _,val in pairs(tmp_table) do
			if val.rep == 3 then
				return poker_rula.card_type.three_one_card
			end
		end
	end
	return
end

function poker_rula.__checkStyleSanDaiEr(pokers)
	if #pokers == 5 then
		local tmp_table = checkPokerIdRepeat(pokers)
		for _,val in pairs(tmp_table) do
			if val.rep == 3 then
				return poker_rula.card_type.three_two_card
			end
		end
	end
end
--=============================================================