
function MenuStyle(id, config = {}) constructor {
    self.id = id;
    
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

    font                    = config[$ "font"]                      ?? undefined;

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
}