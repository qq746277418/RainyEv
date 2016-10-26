local Poker = class("Poker", function() return display.newSprite() end)

function Poker:ctor()
	self.m_is_touch = false
	self.m_is_selected = false
	self.m_touch_listener = nil
	self.m_id = 0
	self.m_value = 0
	self.m_color = 0
	self.m_img = nil

	self:_init()
end

function Poker:_init()
	self:align(display.LEFT_BOTTOM)
	self:setTouchEnabled(true)
end

--========================================
function Poker:setId(id)
	self.m_id = id or 0
	local params = poker_data[id]
	self.m_value = params.value
	self.m_color = params.color
	self.m_img = params.img
	self.m_weg = params.weg

	self:setTexture(self.m_img)
	self.m_posY = Y(self) + 20
	self.m_posY_ = Y(self)
end

function Poker:setTouchListener(listener)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) 
		listener(self, event)
		end)
end

function Poker:setIsTouch(ret)
	self:setTouchEnabled(ret)
end

function Poker:setIsSelected(ret)
	self:stopAllActions()
	if self.m_is_selected then
		self:pos(X(self), self.m_posY)
	else
		self:pos(X(self), self.m_posY_)
	end
	self.m_is_selected = ret
	if ret then
		self:runAction(cca.moveTo(0.2, X(self), self.m_posY))
	else
		self:runAction(cca.moveTo(0.2, X(self), self.m_posY_))
	end
end

--------------------------get-------------------
function Poker:getId()
	return self.m_id
end

function Poker:getIsSelected()
	return self.m_is_selected
end

function Poker:getWeg()
	return self.m_weg
end

return Poker