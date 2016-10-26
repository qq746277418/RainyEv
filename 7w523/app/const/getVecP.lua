SIZE = function(node)
	if not node then return nil end
	local size = node:getContentSize()
	if size.width == 0 and size.height == 0 then
		local w,h = node:getLayoutSize()
		return cc.size(w,h)
	else
		return size
	end
end
--获取坐标位置函数
X = function (node) if not node then return nil end return node:getPositionX(); end
Y = function (node) if not node then return nil end return node:getPositionY(); end
W = function(node) if not node then return nil end  return SIZE(node).width; end
H = function(node) if not node then return nil end  return SIZE(node).height; end