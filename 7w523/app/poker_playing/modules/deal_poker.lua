-------------------
--发牌阶段 取手牌
------------------
deal_poker = {}

deal_poker._randFivePoker = function()
	local poker_ids = {}  --暂存随机出来的
	local pokers = PlayingData:getInstance():getNormalPokers()
	for i=1,5 do
		local id = math.random(1, #pokers)
		poker_ids[i] = pokers[id]
		table.remove(pokers, id)
	end
	return poker_ids
end

--interface：根据人数随机发好扑克牌
deal_poker.randDealPoker = function(num)
	math.randomseed(os.time())
	local deal_pokers = {}
	for i=1,num do
		deal_pokers[i] = deal_poker._randFivePoker(poker_values)
	end
	return deal_pokers
end

