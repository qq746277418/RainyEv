ww = ww or {}

function ww.createShieldTouchLayer(parent_node, touch_listener, alpha)
    local layer = display.newColorLayer(cc.c4b(0, 0, 0, alpha or 125))
    layer:setTouchEnabled(true)
    layer:setPosition(cc.p(-parent_node:getPositionX(),-parent_node:getPositionY()))
    layer:setContentSize(cc.size(display.width, display.height))
    parent_node:addChild(layer,-100)
    if touch_listener then
        layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, touch_listener)
    end

    return layer
end

function ww.createLabel(text, size, color, font)
    return cc.ui.UILabel.new({text = text, size = size, color = color, font = font or FNT_COMMON_JIANTI})
end

function ww.createMultiLabel(text, font_size, size, color, font, align, valign)
	local params = {
    text = text,
    size = font_size,
    color = color,
    font = font or FNT_COMMON_JIANTI,
    align = align or cc.TEXT_ALIGNMENT_CENTER,
    valign = valign or cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    dimensions = size
  }

  return display.newTTFLabel(params)
end

function ww.createButton(images, label)
    local button = cc.ui.UIPushButton.new(images)
    if label then button:setButtonLabel(label) end
    return button
end

function ww.createBackGround(bg_res)
    local background = cc.ui.UIImage.new(bg_res)
    background:setLayoutSize(display.width, display.height)
    return background
end