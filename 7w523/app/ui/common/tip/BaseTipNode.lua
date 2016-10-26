local BaseTipNode = class("BaseTipNode", function() return display.newNode() end)

local dir = "ui/tip/"
-- local plist = dir .. "tip_ui.plist"
-- local image = dir .. "tip_ui.png"

local SpriteRes = {
	bg_tip_first = dir .. "bg_tip_first.png",
	sp_first_down = dir .. "sp_first_down.png",
	sp_first_up = dir .. "sp_first_up.png",
	btn_delete = dir .. "btn_delete.png",
}

local kDelayRemoveTime = 3  --有些提示节点可能不操作自动关闭

function BaseTipNode:ctor(size)
	self.m_size = size or cc.size(600, 300)

	self.m_base_bg = nil
	self.m_delete_btn = nil
	self.m_util_layer = nil
	self.m_delete_listener = nil

	self:setupUi()
end

function BaseTipNode:setupUi()
	self.m_util_layer = ww.createShieldTouchLayer(self)

	self.m_base_bg = display.newScale9Sprite(SpriteRes.bg_tip_first, display.cx, display.cy, self.m_size)
	self.m_base_bg:addTo(self)
	self.m_base_bg:setTouchEnabled(true)
	self.m_base_bg:setTouchSwallowEnabled(true)

	self.m_delete_btn =  ww.createButton(SpriteRes.btn_delete)
	self.m_delete_btn:addTo(self.m_base_bg)
	self.m_delete_btn:pos(self.m_size.width - 25, self.m_size.height - 25)
	self.m_delete_btn:onButtonClicked(handler(self, self._deleteButtonClickListener))

	self.m_title = ww.createLabel("标题", 33, cc.c3b(108, 108, 108))
	self.m_title:align(display.CENTER, self.m_size.width / 2, self.m_size.height - H(self.m_title) / 2 - 40)
	self.m_title:addTo(self.m_base_bg)
end

function BaseTipNode:_deleteButtonClickListener(event)
	if self.m_delete_listener then
		self.m_delete_listener(event)
	end
	self:removeFromParent()
end

function BaseTipNode:setDeleteButtonListener(listenr)
	self.m_delete_listener = listener
end

function BaseTipNode:setTitleString(str)
	self.m_title:setString(str)
end

function BaseTipNode:setShieldListener(listener, alpha)
	self.m_util_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, listener)
	if alpha then
		self.m_util_layer:setOpacity(alpha)
	end
end

function BaseTipNode:openDelayRemove()
	local seq = cc.Sequence:create(cc.DelayTime:create(kDelayRemoveTime), cc.CallFunc:create(handler(self, self._deleteButtonClickListener)))
	self:runAction(seq)
end

return BaseTipNode
