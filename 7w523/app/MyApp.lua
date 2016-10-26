
require("config")
require("cocos.init")
require("framework.init")
require("app.const.require_file")
require("app.ui.require_file")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")
end

return MyApp
