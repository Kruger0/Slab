
function MenuStyle(name, config = {}) constructor {
    self.name = name;
    
    // ─── GENERIC ─────────────────────────────────────
    colorBase               = config[$ "colorBase"]                 ?? #808080;
    colorFocused            = config[$ "colorFocused"]              ?? #FFFFFF;
    colorDisabled           = config[$ "colorDisabled"]             ?? #444444;
    colorPending            = config[$ "colorPending"]              ?? #FF4444;

    bgColorBase             = config[$ "bgColorBase"]               ?? #202020;
    bgColorFocused          = config[$ "bgColorFocused"]            ?? #202020;
    bgColorDisabled         = config[$ "bgColorDisabled"]           ?? #202020;
    bgColorPending          = config[$ "bgColorPending"]            ?? #202020;

    bgSpriteBase            = config[$ "bgSpriteBase"]              ?? undefined;
    bgSpriteFocused         = config[$ "bgSpriteFocused"]           ?? undefined;
    bgSpriteDisabled        = config[$ "bgSpriteDisabled"]          ?? undefined;
    bgSpritePending         = config[$ "bgSpritePending"]           ?? undefined;
    
    alphaBase               = config[$ "alphaBase"]                 ?? 1.0;
    alphaFocused            = config[$ "alphaFocused"]              ?? 1.0;
    alphaDisabled           = config[$ "alphaDisabled"]             ?? 0.4;
    alphaPending            = config[$ "alphaPending"]              ?? 1.0;
    
    scaleBase               = config[$ "scaleBase"]                 ?? 1.0;
    scaleFocused            = config[$ "scaleFocused"]              ?? 1.1;
    scaleDisabled           = config[$ "scaleDisabled"]             ?? 1.0;
    scalePending            = config[$ "scalePending"]              ?? 1.0;
    
    font                    = config[$ "font"]                      ?? undefined;
    animSpeed               = config[$ "animSpeed"]                 ?? 0.15;

    // ─── BUTTON ──────────────────────────────────────
    colorButtonBase         = config[$ "colorButtonBase"]           ?? colorBase;
    colorButtonFocused      = config[$ "colorButtonFocused"]        ?? colorFocused;
    colorButtonDisabled     = config[$ "colorButtonDisabled"]       ?? colorDisabled;

    bgColorButtonBase       = config[$ "bgColorButtonBase"]         ?? bgColorBase;
    bgColorButtonFocused    = config[$ "bgColorButtonFocused"]      ?? bgColorFocused;
    bgColorButtonDisabled   = config[$ "bgColorButtonDisabled"]     ?? bgColorDisabled;

    bgSpriteButtonBase      = config[$ "bgSpriteButtonBase"]        ?? bgSpriteBase;
    bgSpriteButtonFocused   = config[$ "bgSpriteButtonFocused"]     ?? bgSpriteFocused;
    bgSpriteButtonDisabled  = config[$ "bgSpriteButtonDisabled"]    ?? bgSpriteDisabled;

    fontButton              = config[$ "fontButton"]                ?? font;

    // ─── CONFIRM ─────────────────────────────────────
    colorConfirmBase        = config[$ "colorConfirmBase"]          ?? colorBase;
    colorConfirmFocused     = config[$ "colorConfirmFocused"]       ?? colorFocused;
    colorConfirmDisabled    = config[$ "colorConfirmDisabled"]      ?? colorDisabled;
    colorConfirmPending     = config[$ "colorConfirmPending"]       ?? colorPending;

    bgColorConfirmBase      = config[$ "bgColorConfirmBase"]        ?? bgColorBase;
    bgColorConfirmFocused   = config[$ "bgColorConfirmFocused"]     ?? bgColorFocused;
    bgColorConfirmDisabled  = config[$ "bgColorConfirmDisabled"]    ?? bgColorDisabled;
    bgColorConfirmPending   = config[$ "bgColorConfirmPending"]     ?? bgColorPending;

    bgSpriteConfirmBase     = config[$ "bgSpriteConfirmBase"]       ?? bgSpriteBase;
    bgSpriteConfirmFocused  = config[$ "bgSpriteConfirmFocused"]    ?? bgSpriteFocused;
    bgSpriteConfirmDisabled = config[$ "bgSpriteConfirmDisabled"]   ?? bgSpriteDisabled;
    bgSpriteConfirmPending  = config[$ "bgSpriteConfirmPending"]    ?? bgSpritePending;

    fontConfirm             = config[$ "fontConfirm"]               ?? font;
    
    static __GetColor = function(state, type) {
        var _key = "color";
        switch (type) {
            case MENU_NODE_BUTTON:      _key += "Button"; break;
            case MENU_NODE_CONFIRM:     _key += "Confirm"; break;
        }
        switch (state) {
            case MENU_STATE.FOCUSED:    _key += "Focused";
            case MENU_STATE.DISABLED:   _key += "Disabled";
            case MENU_STATE.PENDING:    _key += "Pending";
            case MENU_STATE.BASE:       _key += "Base";
        }
        return self[$ _key] ?? 0xFFFFFF;
    }
}

global.style = new MenuStyle("testStyle", {});
