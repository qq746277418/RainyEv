local FightPokersUi = class("FightPokersUi", function() return display.newNode() end)

local fight_poker_width = 30
--玩家、电脑 出牌节点一致
function FightPokersUi:ctor()
	self.m_fight_pokers = {}
	self.m_fight_sprites = {}
end

function FightPokersUi:addFightPokers(pokers)
	self.m_fight_pokers = pokers
	for id,val in pairs(pokers) do
		local poker = display.newSprite(poker_data[val].img)
		poker:addTo(self)
		poker:pos(fight_poker_width * (#self.m_fight_sprites - 1), 0)
		poker:setScale(0.75)

		table.insert(self.m_fight_sprites, #self.m_fight_sprites + 1, poker)
	end

	self:_playPokerSound(pokers)
end

function FightPokersUi:removeAllPokerSprites()
	for _,sp in pairs(self.m_fight_sprites) do
		sp:removeFromParent()
	end
	self.m_fight_sprites = {}
end

function FightPokersUi:_playPokerSound(pokers)

	if #pokers == 1 then
		local str = string.format("sound/poker/%d.mp3", 1000 + pokers[1])
		SoundControl:getInstance():playEffectByFile(str)
	elseif #pokers == 2 and poker_data[pokers[1]].value == poker_data[pokers[2]].value then
		local str = string.format("sound/poker/%d.mp3", 1100 + poker_data[pokers[1]].value)
		SoundControl:getInstance():playEffectByFile(str)
	end
end

--分数要积累出来

return FightPokersUi