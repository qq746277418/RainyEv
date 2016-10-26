local TipLabel = import(".TipLabel")
TipBox = class("TipBox")
TipBox.instance = nil

function TipBox.getInstance()
	if not TipBox.instance then
		TipBox.instance = TipBox.new()
	end
	return TipBox.instance
end

function TipBox:setRootScene(scene)
	self.m_scene = scene
end

function TipBox:createTipLabel(title, message)
	TipLabel.new(title, message):addTo(self.m_scene, zorder_manager.tip_node)
end