-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
local dpi = require("beautiful.xresources").apply_dpi
local awesome_widget = "/home/romaha/.config/awesome/awesome-wm-widgets/"
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local mpdarc_widget = require("awesome-wm-widgets.mpdarc-widget.mpdarc")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- Определяем геометрию - прямоугольник с закруглёнными уграми
rounded_shape = function(cr, width, height, radius)
    gears.shape.rounded_rect(cr, width, height, 10)
end

taglist_shape = function(cr, width, height, radius)
    gears.shape.rounded_rect(cr, width, height, 4)
end

-- Не требуется, так как тоже самое можно сделать через Picom,
-- причём определив необходимые исключения, + antialiasing
-- Add rounded corners for all clients

-- client.connect_signal("manage", function(c)
--      c.shape = rounded_shape
-- end)

-- Получается, что всегда слева открывается,
-- скорее всего нужно делать через функцию для тэга


myplacement = function(c) 
    local f = (awful.placement.right + awful.placement.left)
    f(client.focus)
end

-- Variables for notification
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end


-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init("/home/romaha/.config/awesome/themes/zenburn/theme.lua")
-- beautiful.init ("~/.config/awesome/themes/nord/theme.lua")

beautiful.init ("~/.config/awesome/themes/awesome-wm-nord-theme/theme.lua")
-- This is used later as the default terminal and editor to run.
terminal = "kitty -e fish"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awfu.layout.suit.magnifier,
--    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu(
   { items = { { "awesome", myawesomemenu, beautiful.awesome_icons },
	{ "open terminal", terminal } }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget and attach month callendar to it
mytextclock = wibox.widget.textclock()
month_calendar = awful.widget.calendar_popup.month({fg_color = red, opacity = 0.7}
)
month_calendar:attach(mytextclock, 'br')
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
	 if client.focus then
	    client.focus:move_to_tag(t)
	 end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
	 if client.focus then
	    client.focus:toggle_tag(t)
	 end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
   awful.button({ }, 1, function (c)
	 if c == client.focus then
	    c.minimized = true
	 else
	    c:emit_signal(
	       "request::activate",
	       "tasklist",
	       {raise = true}
	    )
	 end
   end),
   awful.button({ }, 3, function()
	 awful.menu.client_list({ theme = { width = 250 } })
   end),
   awful.button({ }, 4, function ()
	 awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
	 awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


awful.screen.connect_for_each_screen(function(s)
      -- Wallpaper
    
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({  "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- My own tag
    awful.tag.add("NeoVim", {
        index = 1,
        layout  = awful.layout.suit.tile,
        -- master_fill_policy = "master_width_factor",
        master_fill_policy = 0.7,
        gap_single_client = true,
        gap = 5,
        screen = s,
    })
    awful.tag.add("Www", {
        index = 2,
        layout  = awful.layout.suit.tile,
        -- master_fill_policy = "master_width_factor",
        master_fill_policy = 0.7,
        gap_single_client = true,
        gap = 8,
        screen = s,
    })
    awful.tag.add("Term", {
        index = 3,
        layout  = awful.layout.suit.fair,
        master_fill_policy = "master_width_factor",
        -- master_fill_policy = 0.7,
        gap_single_client = true,
        gap = 5,
        screen = s,
    })
    awful.tag.add("Float", {
        index = 4,
        layout  = awful.layout.suit.floating,
        -- master_fill_policy = "master_width_factor",
        master_fill_policy = 0.7,
        gap_single_client = true,
        gap = 15,
        screen = s,
    })
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 2, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    -- https://awesomewm.org/doc/api/classes/awful.widget.taglist.html
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        
        style = {
	   spacing = 1,
	   squares_resize = true,
	   shape = taglist_shape,
	   font = 'Source Sans Pro Regular 13'},
	
	
	widget_template = {
	   {
	      {
		 
		 {
                    {
		       id     = 'icon_role',
		       widget = wibox.widget.imagebox,
                    },
                    margins = 2,
                    widget  = wibox.container.margin,
		 },
		 {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
		 },
		 layout = wibox.layout.fixed.horizontal,
	      },
	      left  = 5,
	      right = 5,
	      widget = wibox.container.margin
	   },
	   id     = 'background_role',
	   widget = wibox.container.background,
	   -- Add support for hover colors and an index label
	   create_callback = function(self, c3, index, objects) --luacheck: no unused args
	     
	      self:connect_signal('mouse::enter', function()
				     if self.bg ~= '#d08770' then
					self.backup     = self.bg
					self.has_backup = true
				     end
				     self.bg = '#d08770'
	      end)
	      self:connect_signal('mouse::leave', function()
				     if self.has_backup then self.bg = self.backup end
	      end)
	   end,
	   update_callback = function(self, c3, index, objects) --luacheck: no unused args
	     
	   end,
	},
buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
       screen  = s,
       filter  = awful.widget.tasklist.filter.currenttags,
       buttons = tasklist_buttons,
       style = {
	  align = 'center', 
	  spacing = 9,
	  font = 'JetBrains Mono 12',
	  font_focus = 'JetBrains Mono 12',
	  shape_border_width = 2,
	  shape_border_color = '#777777',
	  -- shape_border_color_focus = '#FFA500',
	  shape_border_color_focus = '#5E81AC',
	  shape = rounded_shape
       },
       widget_template = {
	  {
	     {
                {
		   {
		      id     = 'icon_role',
		      widget = wibox.widget.imagebox,
		      resize = 'allowed',
		      forced_height = 30,
		      forced_width = 30,
		   },
		   top = 10,
		   bottom = 10,
		   left = 10,
		   widget  = wibox.container.margin,
                },
                {
		   id     = 'text_role',
		   widget = wibox.widget.textbox,
                },
                layout = wibox.layout.align.horizontal,
	     },

	     left  = 15,
	     right = 15,
	     widget = wibox.container.margin
	  },
	  id     = 'background_role',
	  widget = wibox.container.background,
       },
    }
 
function new_shape(cr, width, height, round)
    return gears.shape.rounded_rect(cr, width, height, 10)
end

    -- Create the wibox
    s.mywibox = awful.wibar({  
	  -- position="bottom",
	position = "top",
       -- width=math.ceil(screen.primary.geometry.width * 0.98),  
	height = dpi(40),
        opacity=0.95,
        screen = s, 
        shape = new_shape
        
    })
    
    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
        { -- Left widgets
            spacing = 25,
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        {spacing = 10,
	 layout = wibox.layout.flex.horizontal,
	 s.mytasklist}, -- Middle widget
        { -- Right widgets
            spacing = 20,
            layout = wibox.layout.fixed.horizontal,
            spacing_widget = { widget = wibox.widget.separator{orientation = vertical}},
           
            
	     cpu_widget(
            {width = 70}),
--            mpdarc_widget,
            volume_widget{
               widget_type = 'arc',
               with_icon = true,
               device = 'default',
               icon_dir = awesome_widget .. "vomume-widget/icons", 
               size = 40,
               thickness = 4
            },
            mytextclock,
	    mykeyboardlayout,
            wibox.widget.systray(),
            s.mylayoutbox,
        },
    },

        left = 10,
        right = 10,
        bottom = 5,
        top = 5,
        widget = wibox.container.margin
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey, "Shift"           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program

    awful.key({modkey,  }, "F1", 
        function() 
                awful.util.spawn("firefox")
            end,
              {description = "Open browser", group = "programs"}),


    awful.key({ modkey,           }, "F12", function () awful.spawn("systemctl suspend") end,
              {description = "Go to StandBy-mode", group = "launcher"}),


    awful.key({modkey, "Shift" }, "e", function() awful.spawn("emacs") end,
            {description = "Open Emacs", group = "programs"}),
    
     awful.key({modkey, "Shift" }, "y", function() awful.spawn("kitty -e yt", {floating = true, placement = awful.placement.centered}) end,
            {description = "Open Youtube", group = "programs"}),

    awful.key({modkey, "Control" }, "p", function() awful.spawn("/home/romaha/.config/openbox/rofi/bin/screenshot", {floating=true} ) end,
            {description = "Make screenshot", group = "programs"}),


    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal ) end,
              { description = "open a terminal", group = "launcher"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "]", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "m", function () optimal_size(c)                end,
              {description = "Optimal client size", group = "client"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),
    awful.key ({modkey, "Control"}, "t", function () rename_tag() end,
            {description = "Rename tag", group = "tag"}),

    -- Prompt
    --    awful.key({ modkey },            "d",     function () awful.screen.focused().mypromptbox:run() end,
    --              {description = "run prompt", group = "launcher"}),

    awful.key ({modkey}, "d", function() awful.spawn("rofi -show drun -theme ~/.config/awesome/themes/awesome-wm-nord-theme/nord.rasi -show-icons") end,
            {description = "Show rofi-drun", group = "program"}),
    awful.key ({modkey}, "w", function() awful.spawn("rofi -show window -theme ~/.config/awesome/themes/awesome-wm-nord-theme/nord.rasi -show-icons") end,
            {description = "Show rofi-window", group = "program"}),
    awful.key ({modkey}, "z", function() awful.placement.under_mouse(client.focus) end,
            {description = "Place client under mouse", group = "client"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({modkey, "Shift"}, "t", function (c) awful.titlebar.toggle(c) end,
        {description = "toggle titlebar", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            -- c.maximized_horizontal = not c.maximized_horizontal
            -- c:raise()
            optimal_size(c)
        end ,
        {description = "optimal client size", group = "client"})

)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     maximized = false,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
		     placement = awful.placement.no_overlap+awful.placement.no_offscreen
		     -- placement = awful.placement.right+awful.placement.left,
                     -- honor_workarea = true
                     -- placement = awful.placement.centered(c)

     }

    },

    { rule = { class = "imv" }, properties = { placement = awful.placement.centered,
    floating = true } },
{ rule = { class = "Conky" },
       properties = { border_width = 0, sticky = true } },
{ rule = { class = "Thunar" }, properties = {honor_workarea = true, honor_padding = true} },
{ rule = { class = "yt-mpv"},
        properties = { floating = true, ontop = true, raise = true }},


    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Msgcompose",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer",
          "yt-mpv"
      },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "Msgcompose",     -- Thunderbirs's Write message
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false, position='centerd' }
    },

    {rule = {class = "Inkscape"},
        properties = {titlebars_enabled = true}
    },
    {rule = {class = "Steam"},
        properties = {position = 'centered'}
    }
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
     if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- if awesome.startup then awful.tag.viewtoggle(1) end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
local top_titlebar = awful.titlebar(c, {
    size    = 20,
    font = 'Source Sans Pro Regular 10',
    
})
local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    top_titlebar : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
	       font = "Iosevka Nerd Font Mono 11",
	       align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

autorun = true
autorunApps = 
{
--    "xrandr --output DisplayPort-0 --primary --left-of HDMI-A-0",
    "picom -b",
--    "yandex-disk-indicator",
--    "/home/romaha/.local/bin/polkit.sh"
}


-- awful.spawn.easy_async_with_shell("ps -A | grep conky", function(stdout, exit_code)
--    if stdout == ""
--       then
--        awful.spawn("conky", {x=2100})
--     end
-- end)

if autorun then
    for app = 1, #autorunApps do
        awful.spawn.with_shell(autorunApps[app], {} )
    end
end

function rename_tag()
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end

            local t = awful.screen.focused().selected_tag
            if t then
                t.name = new_name
            end
        end
    }
end
awful.tag.viewidx(0)

-- Option for Help PopUp Window
beautiful.hotkeys_font = "JetBrains Mono 14"
beautiful.hotkeys_description_font = "JetBrains Mono 12"
beautiful.hotkeys_label_fg = "white"
beautiful.hotkeys_modifiers_fg = "#7D9CBA"
beautiful.hotkeys_border_width = 2
beautiful.hotkeys_group_margin = 20
-- }}}

myNeoVimtag = function(t)
   if t.name == "NeoVim" or t.name == "Www" then -- проверяет имя тега
      local tab = t
      c_number = tab:clients() -- проверяет количество клиентов, присоединенных к тэгу, передаваемому в функцию
      if #c_number == 1 then -- если количество клиентов равно одному, то
	 local c = tab:clients()
	 local geom = screen.primary.geometry
	 c[1].width = math.ceil(geom.width * 0.80)
	 c[1].height = math.ceil(geom.height * 0.85)
	 awful.placement.align(c[1], {position="centered"}) -- выравниваем по центру
	 t.layout  = awful.layout.suit.floating -- устанавливаем раскладку - floating
      else if #c_number > 1 then 
	    t.layout = awful.layout.suit.tile -- если клиентов больше одного,  "тайлинг"
      end
      end
   end
end

NeoVimtag = awful.tag.find_by_name(awful.screen.focused(), "NeoVim")
Wwwtag = awful.tag.find_by_name(awful.screen.focused(), "Www")

tag.connect_signal("tagged", function() myNeoVimtag(NeoVimtag) end)
tag.connect_signal("untagged", function() myNeoVimtag(NeoVimtag) end)
tag.connect_signal("request::select", function (tag) myNeoVimtag(tag) end)  
tag.connect_signal("tagged", function() myNeoVimtag(Wwwtag) end)
tag.connect_signal("untagged", function() myNeoVimtag(Wwwtag) end)


-- Оптимальный размер окна
--  Position: 749,81 (screen: 0)
--  Geometry: 2462x2006
function optimal_size(c)
   local c = client.focus
   local screen = awful.screen.focused()
   if screen.geometry.width == 1920 then
      c.width = math.ceil(screen.geometry.width * 0.90)
      c.height = math.ceil(screen.geometry.height * 0.90)
   else
      c.width = math.ceil(screen.geometry.width * 0.75)
      c.height = math.ceil(screen.geometry.height * 0.80)
   end
   awful.placement.align(c, {position="centered"})
end

client.connect_signal("property::position", function(c)
     if c.class == 'Steam' then
         local g = c.screen.geometry
         if c.y + c.height > g.height then
             c.y = g.height - c.height
             naughty.notify{
                 text = "restricted window: " .. c.name,
             }
         end
         if c.x + c.width > g.width then
             c.x = g.width - c.width
         end
     end
end)

titlebar_for_floating_cl = function(c)
    local client = c
    local tag_check = client.first_tag
    if tag_check.name == "Float" then
        c.border_width = 5
        awful.titlebar.show(client)
    else
        c.border_width = 1
        awful.titlebar.hide(client)
    end
end


client.connect_signal("tagged", function(c)  titlebar_for_floating_cl(c) end)

