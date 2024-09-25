local wezterm = require 'wezterm'
local io = require 'io';
local os = require 'os';
local config = {}

wezterm.on("trigger-vim-with-scrollback", function(window, pane)
  -- Retrieve the current viewport's text.
  -- Pass an optional number of lines (eg: 2000) to retrieve
  -- that number of lines starting from the bottom of the viewport
  local scrollback = pane:get_lines_as_text();

  -- Create a temporary file to pass to vim
  local name = os.tmpname();
  local f = io.open(name, "w+");
  f:write(scrollback);
  f:flush();
  f:close();

  -- Open a new window running vim and tell it to open the file
  window:perform_action(wezterm.action{ SpawnCommandInNewTab = {
    domain = "CurrentPaneDomain",
    args={ "nvim", '-U', '$HOME/.config/nvim/minit.vim', '+', name }
    }
  }, pane)

  -- wait "enough" time for vim to read the file before we remove it.
  -- The window creation and process spawn are asynchronous
  -- wrt. running this script and are not awaitable, so we just pick
  -- a number.
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

config.font = wezterm.font 'JetBrains Mono'
config.enable_scroll_bar = true
local colors, metadata = wezterm.color.load_base16_scheme('~/.config/wezterm/theme.yaml')
config.color_scheme = colors
-- config.enable_kitty_keyboard = true
config.set_environment_variables = {
  PATH = "$PATH:/opt/homebrew/bin:$HOME/.cargo/bin:$HOME/.local/bin:/usr/bin:/bin",
}
config.default_prog = { 'fish' }

config.leader = { key = 'Space', mods = 'SHIFT' }

config.key_tables = {

  pane_adjust = {
    { key = 'm', action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
    { key = '/', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
    { key = ',', action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
    { key = '.', action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
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
    key = 'Space',
    mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable {
        name = 'pane_adjust',
        one_shot = false,
    },
  },
  {
    key = 'v',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical {
        domain = 'CurrentPaneDomain',
    },
  },
  {
    key = '|',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal {
        domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'w',
    mods = 'LEADER',
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
    key = 'Enter',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
  { key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection('Prev')},
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection('Next')},
  { key = '=', mods = 'CTRL|SHIFT|CMD', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL|SHIFT|CMD', action = wezterm.action.DecreaseFontSize },
  { key = "b", mods = "CTRL|SHIFT", action = wezterm.action{ EmitEvent = "trigger-vim-with-scrollback" } },
  { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollByPage(-1) },
  { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ScrollByPage(1) },
  { key = 'k', mods = 'CTRL|SHIFT|CMD', action = wezterm.action.ScrollByLine(-1) },
  { key = 'j', mods = 'CTRL|SHIFT|CMD', action = wezterm.action.ScrollByLine(1) },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ScrollToPrompt(-1) },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ScrollToPrompt(1) },
  { key = 's', mods = 'LEADER', action = wezterm.action.ShowTabNavigator },
  { key = 'c', mods = 'LEADER', action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection' },
  { key = 'p', mods = 'LEADER', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'S', mods = 'LEADER', action = wezterm.action.Search("CurrentSelectionOrEmptyString")},
  {
    key = 's',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.QuickSelectArgs {
      patterns = {
        '[\\w\\-\\.\\/]+',
      },
    },
  },
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.Search {
      Regex = '[\\w\\-\\.\\/]+',
    },
  },
  {
    key = 'f',
    mods = 'LEADER',
    action = wezterm.action.Search {
      Regex = '[\\w\\-\\.\\/]+\\.[\\w\\.]+\\s*$',
    },
  },
}

return config
