
function __MenuStyle(name, config = {}) constructor {
    self.name = name;
    
    colorBase           = config[$ "colorBase"]         ?? #808080;
    colorFocused        = config[$ "colorFocused"]      ?? #00FF00;
    colorDisabled       = config[$ "colorDisabled"]     ?? #444444;
    colorPending        = config[$ "colorPending"]      ?? #FF4444;
    
    bgColorBase         = config[$ "bgColorBase"]       ?? #202020;
    bgColorFocused      = config[$ "bgColorFocused"]    ?? #202020;
    bgColorDisabled     = config[$ "bgColorDisabled"]   ?? #202020;
    bgColorPending      = config[$ "bgColorPending"]    ?? #202020;
    
    bgSpriteBase        = config[$ "bgSpriteBase"]      ?? undefined;
    bgSpriteFocused     = config[$ "bgSpriteFocused"]   ?? undefined;
    bgSpriteDisabled    = config[$ "bgSpriteDisabled"]  ?? undefined;
    bgSpritePending     = config[$ "bgSpritePending"]   ?? undefined;
    
    alphaBase           = config[$ "alphaBase"]         ?? 1.0;
    alphaFocused        = config[$ "alphaFocused"]      ?? 1.0;
    alphaDisabled       = config[$ "alphaDisabled"]     ?? 0.4;
    alphaPending        = config[$ "alphaPending"]      ?? 1.0;
    
    scaleBase           = config[$ "scaleBase"]         ?? 1.0;
    scaleFocused        = config[$ "scaleFocused"]      ?? 1.1;
    scaleDisabled       = config[$ "scaleDisabled"]     ?? 1.0;
    scalePending        = config[$ "scalePending"]      ?? 1.0;
    
    font                = config[$ "font"]              ?? undefined;
    animSpeed           = config[$ "animSpeed"]         ?? 0.15;
    
    soundFocused        = config[$ "sndSelect"]         ?? undefined;
    soundSelect         = config[$ "sndSelect"]         ?? undefined;
    
    static __GetColor = function(state) {
        switch (state) {
            case MENU_STATE.FOCUSED:  return colorFocused;
            case MENU_STATE.DISABLED: return colorDisabled;
            case MENU_STATE.PENDING:  return colorPending;
            default:                  return colorBase;
        }
    }
    static __GetAlpha = function(state) {
        switch (state) {
            case MENU_STATE.FOCUSED:  return alphaFocused;
            case MENU_STATE.DISABLED: return alphaDisabled;
            case MENU_STATE.PENDING:  return alphaPending;
            default:                  return alphaBase;
        }
    }
    static __GetScale = function(state) {
        switch (state) {
            case MENU_STATE.FOCUSED:  return scaleFocused;
            case MENU_STATE.DISABLED: return scaleDisabled;
            case MENU_STATE.PENDING:  return scalePending;
            default:                  return scaleBase;
        }
    }
}

function MenuGetDefaultStyle() {
    static cache = __MenuCache();
    return cache.styles.base;
}

function MenuGetStyle(name) {
    static cache = __MenuCache();
    return cache.styles[$ name];
}

function MenuCreateStyle(name, config = {}) {
    static cache = __MenuCache();
    cache.styles[$ name] = new __MenuStyle(name, config);
}

function MenuStyleDelete(name) {
    static cache = __MenuCache();
}

function MenuStyleExists(name) {
    static cache = __MenuCache();
    return (!is_undefined(cache.styles[$ name]));
}

function MenuBindStyle(style) {
    static cache = __MenuCache();
    if (is_undefined(style)) return MenuGetDefaultStyle();
    if (is_struct(style)) return new __MenuStyle("style", style);
    if (is_string(style)) return cache.styles[$ style] ?? new __MenuStyle("style");
}

function MenuMergeStyle(source, override) {
    return source;
}