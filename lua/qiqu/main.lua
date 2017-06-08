--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- A news app
--
require "import"
import "android.widget.*"
import "android.content.*"
import("androlua.LuaWebView")
local Http = luajava.bindClass("androlua.LuaHttp")
local uihelper = require("common.uihelper")
local JSON = require("common.json")
-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    fitsSystemWindows = true,
    {
        TextView,
        layout_width = "fill",
        layout_height = "48dp",
        background = "#F79100",
        gravity = "center",
        text = "奇趣百科",
        textColor = "#FFFFFF",
        textSize = "18sp",
    },
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "fill",
        {
            LuaWebView,
            id = "webview",
            layout_width = "fill",
            layout_height = "fill",
        },
        {
            ProgressBar,
            layout_gravity="center",
            id = "progressBar",
            layout_width = "40dp",
            layout_height = "40dp",
        },
    }
}

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0xFFF79100)
    activity.setContentView(loadlayout(layout))
    webview.setVisibility(8)
    progressBar.setVisibility(0)
    webview.loadUrl('http://hanks.pub/joke/')
    webview.setWebViewClientListener(luajava.createProxy('androlua.LuaWebView$WebViewClientListener', {
        onPageFinished = function(view, url)
            webview.setVisibility(0)
            progressBar.setVisibility(8)
        end
    }))
end

function onDestroy()
    if webview then
        webview.getParent().removeView(webview)
        webview.destroy()
        webview = nil
    end
end