local wezterm = require 'wezterm';
return {
    font = wezterm.font("Menlo", {weight="Regular", stretch="Normal", style="Normal"}),
    font_size = 15.0,
    hide_tab_bar_if_only_one_tab = true,
    disable_default_key_bindings = true,
}
