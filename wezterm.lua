local wezterm = require 'wezterm'
local io = require 'io';
local os = require 'os';
local config = {}

wezterm.on("trigger-vim-with-scrollback", function(window, pane)
  local scrollback = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows);

  local name = os.tmpname();
  local f = io.open(name, "w+");
  f:write(scrollback);
  f:flush();
  f:close();

  window:perform_action(wezterm.action{ SpawnCommandInNewTab = {
    domain = "CurrentPaneDomain",
    args={ "nvim", '-U', '$HOME/.config/nvim/minit.vim', '+', name }
    }
  }, pane)

  wezterm.sleep_ms(1000);
  os.remove(name);
end)

wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then
    name = 'TABLE: ' .. name
  end
  window:set_right_status(name or '')
end)

wezterm.on('select-and-paste', function(window, pane)
  wezterm.action.QuickSelectArgs {
   patterns = {
      '[\\w\\-\\.\\/~]+',
    },
  }
  wezterm.action.PasteFrom 'Clipboard'
end)

Alt = 'ALT'
NonAlt = 'META'
if wezterm.target_triple:find("windows") ~= nil then
  config.default_domain = 'WSL:Ubuntu'
  config.window_decorations = "RESIZE"
  config.window_padding = {
    left = 10,
    right = 10,
    top = 5,
    bottom = 5,
  }
elseif wezterm.target_triple:find("darwin") ~= nil then
  Alt = 'OPT'
  NonAlt = 'CMD'
  config.window_decorations = "RESIZE"
  config.set_environment_variables = {
   PATH = "$PATH:$HOME/.fzf/bin:$HOME/.cargo/bin:$HOME/.local/bin:/usr/bin:/bin:/opt/homebrew/bin:/usr/local/bin",
  }
  config.window_padding = {
    left = 10,
    right = 10,
    top = 5,
    bottom = 2,
  }
else
  config.window_decorations = "NONE"
  config.set_environment_variables = {
   PATH = "$PATH:$HOME/.fzf/bin:$HOME/.cargo/bin:$HOME/.local/bin:/usr/bin:/bin:/home/linuxbrew/bin:/home/linuxbrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/go/bin",
  }
  config.window_padding = {
    left = 10,
    right = 10,
    top = 5,
    bottom = 30,
  }
end

config.disable_default_key_bindings = true
config.font = wezterm.font 'JetBrains Mono Semibold'
config.font_size = 9.5
config.enable_scroll_bar = true
config.color_scheme = "Black Noodle"
config.default_prog = { 'fish' }
config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 1000 }
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.window_background_opacity = 0.99
config.colors = {
    tab_bar = {
        background = "rgba(0,0,0,0)"
    },
}
config.window_frame = {
    font_size = 7.5
}
config.inactive_pane_hsb = {
  hue = 1.2,
  saturation = 1.0,
  brightness = 0.4,
}
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.8,
  brightness = 1.5,
}

config.key_tables = {

  pane_adjust = {
    { key = 'm', action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
    { key = '/', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
    { key = '.', action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
    { key = ',', action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
    { key = 'h', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'l', action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = 'k', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'j', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'w', action = wezterm.action.CloseCurrentPane { confirm = false } },
    { key = "Space", action = wezterm.action.RotatePanes('Clockwise')},
    {
      key = '-',
      action = wezterm.action.SplitVertical {
          domain = 'CurrentPaneDomain',
      },
    },
    {
      key = '|',
      action = wezterm.action.SplitHorizontal {
          domain = 'CurrentPaneDomain',
      },
    },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

config.keys = {
  {
    key = 'R',
    mods = 'LEADER',
    action = wezterm.action.ReloadConfiguration,
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable {
        name = 'pane_adjust',
        one_shot = false,
    },
  },
  {
    key = 'Enter',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical {
        domain = 'CurrentPaneDomain',
    },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical {
        domain = 'CurrentPaneDomain',
    },
  },
  {
    key = '\\',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal {
        domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    key = 'Q',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    key = 'q',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentTab { confirm = false },
  },
  {
    key = 't',
    mods = 'LEADER',
    action = wezterm.action.SpawnTab 'DefaultDomain'
  },
  {
    key = 'Space',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = '\'',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.TogglePaneZoomState,
  },
  { key = '[', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
  { key = ']', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(1) },
  { key = "L", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
  { key = "H", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "Tab", mods = Alt, action = wezterm.action.ActivatePaneDirection('Next') },
  { key = "Tab", mods = Alt .. "|SHIFT", action = wezterm.action.ActivatePaneDirection('Prev') },
  { key = ")", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection('Next') },
  { key = "(", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection('Prev') },
  { key = '+', mods = 'CTRL|SHIFT', action = wezterm.action.IncreaseFontSize },
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.DecreaseFontSize },
  { key = "b", mods = "CTRL|SHIFT", action = wezterm.action{ EmitEvent = "trigger-vim-with-scrollback" } },
  { key = '}', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollByPage(-1) },
  { key = '{', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollByPage(1) },
  { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollByLine(-1) },
  { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollByLine(1) },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ScrollToPrompt(-1) },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ScrollToPrompt(1) },
  { key = 's', mods = 'LEADER', action = wezterm.action.ShowTabNavigator },
  { key = 'F', mods = 'LEADER', action = wezterm.action.Search("CurrentSelectionOrEmptyString")},
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action { EmitEvent = "select-and-paste" } },
  { key = 'M', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = '?', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { key = '>', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
  { key = '<', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
  { key = 'c', mods = NonAlt, action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection' },
  { key = 'v', mods = NonAlt, action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'N', mods = 'LEADER', action = wezterm.action_callback(function(win, pane)
      local tab, window = pane:move_to_new_window()
    end)
  },
  {
    key = 'N',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      local tab, window = pane:move_to_new_tab()
    end),
  },
  {
    key = 'f',
    mods = 'LEADER',
    action = wezterm.action.QuickSelectArgs {
      patterns = {
        '[\\w\\-\\.\\/~]+',
      },
    },
  },
  {
    key = 'F',
    mods = 'LEADER',
    action = wezterm.action.QuickSelectArgs {
      patterns = {
        '\\S+',
      },
    },
  },
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = 'Rename tab:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = 'd',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SwitchToWorkspace {
      name = 'default',
    },
  },
  { key = 'W', mods = 'LEADER', action = wezterm.action.SwitchToWorkspace },
  {
    key = 'S',
    mods = 'LEADER',
    action = wezterm.action.ShowLauncherArgs {
      flags = 'WORKSPACES',
    },
  },
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Foreground = { AnsiColor = 'Yellow' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            wezterm.action.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },
  { key = 'l', mods = 'LEADER', action = wezterm.action.SwitchWorkspaceRelative(1) },
  { key = 'h', mods = 'LEADER', action = wezterm.action.SwitchWorkspaceRelative(-1) },
}

-- if wezterm.target_triple:find("darwin") == nil then
--   local added_keys = {
--     { key = 'c', mods = 'ALT', action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection' },
--     { key = 'v', mods = 'ALT', action = wezterm.action.PasteFrom 'Clipboard' },
--   }
--   for _, v in ipairs(added_keys) do
--      table.insert(config.keys, v)
--   end
-- else
--   local added_keys = {
--     { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection' },
--     { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom 'Clipboard' },
--   }
--   for _, v in ipairs(added_keys) do
--      table.insert(config.keys, v)
--   end
-- end

return config
