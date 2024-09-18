local wezterm = require 'wezterm';
return {
    font = wezterm.font_with_fallback {
        {
            family = "HackGen35 Console NF",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        },
        {
            family = "Menlo",
            weight = "Regular",
            stretch = "Normal",
            style = "Normal",
        }
    },
    font_size = 16.0,
    hide_tab_bar_if_only_one_tab = true,
    disable_default_key_bindings = true,
    keys = {
        {
            key = "v",
            mods = "CMD",
            action = wezterm.action.PasteFrom "Clipboard",
        },
        {
            key = "c",
            mods = "CMD",
            action = wezterm.action.CopyTo "Clipboard",
        },
    }
}
