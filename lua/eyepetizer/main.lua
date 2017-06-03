--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- A news app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaHttp"
import "androlua.LuaAdapter"
import "androlua.widget.video.VideoPlayerActivity"
import ("androlua.LuaImageLoader")

local uihelper = require("common.uihelper")
local JSON = require("common.json")

-- create view table
local layout = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "fill",
    fitsSystemWindows = true,
    {
        ListView,
        id = "listview",
        paddingTop = "48dp",
        clipToPadding = false,
        dividerHeight = 0,
        layout_width = "fill",
        layout_height = "fill",
    },
    {
        LinearLayout,
        layout_width = "fill",
        layout_height = "48dp",
        background = "#F0000000",
        gravity = "center",
        {
            TextView,
            text="Eyepetizer",
            textColor="#FFFFFF",
            textSize="14sp",
        }
    },
}

local item_view = {
    FrameLayout,
    layout_widht = "fill",
    layout_height = "240dp",
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "fill",
        scaleType = "centerCrop",
    },
    {
        View,
        layout_width = "fill",
        layout_height = "fill",
        background = "#88000000",
    },
    {
        TextView,
        id = "tv_title",
        layout_margin = "16dp",
        layout_widht = "fill",
        layout_gravity = "center",
        maxLines = "5",
        lineSpacingMultiplier = '1.2',
        textSize = "14sp",
        textColor = "#aaffffff",
    },
}


local data = {
    dailyList={}
}
local adapter

function getData()
    -- http://baobab.kaiyanapp.com/api/v1/feed
    local url = data.nextPageUrl
    if url == nil then url = 'http://baobab.kaiyanapp.com/api/v1/feed' end
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            print('fetch data error')
            return
        end
        local str = JSON.decode(body)
        data.nextPageUrl = str.nextPageUrl
        local list = str.dailyList[1].videoList
        for i=1, #list do
            data.dailyList[#data.dailyList+1] = list[i]
        end
        uihelper = runOnUiThread(activity, function()
            adapter.notifyDataSetChanged()
        end)
    end)
end
local log = require('common.log')
function launchDetail(item)
    local json = { url = item.playInfo[#item.playInfo].url, poster = item.coverForDetail}
    VideoPlayerActivity.start(activity,JSON.encode(json))
end


function onCreate(savedInstanceState)
    activity.setStatusBarColor(0xF0000000)
    activity.setContentView(loadlayout(layout))
    adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #data.dailyList end,
        getItem = function(position) return nil end,
        getItemId = function(position) return position end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始
            if position == #data.dailyList then
                getData()
            end
            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                if parent then
                    local params = convertView.getLayoutParams()
                    params.width = parent.getWidth()
                end
                convertView.setTag(views)
            end
            local views = convertView.getTag()
            local item = data.dailyList[position]
            if item then
                LuaImageLoader.load(views.iv_image, item.coverForFeed)
                views.tv_title.setText(item.title)
            end
            return convertView
        end
    }))
    listview.setAdapter(adapter)
    listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
        onItemClick = function(adapter, view, position, id)
            launchDetail(data.dailyList[position + 1])
        end,
    }))
    getData()
end

