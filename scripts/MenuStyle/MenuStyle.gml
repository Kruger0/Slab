
function __MenuStyle(config = {}) constructor {    
    colorBase           = config[$ "colorBase"]         ?? #808080;
    colorFocused        = config[$ "colorFocused"]      ?? #FFFFFF;
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
    
    scaleBase           = config[$ "scaleBase"]         ?? [1.0, 1.0];
    scaleFocused        = config[$ "scaleFocused"]      ?? [1.1, 1.1];
    scaleDisabled       = config[$ "scaleDisabled"]     ?? [1.0, 1.0];
    scalePending        = config[$ "scalePending"]      ?? [1.0, 1.0];
    
    font                = config[$ "font"]              ?? undefined;
    animSpeed           = config[$ "animSpeed"]         ?? 0.15;
    animCurve           = config[$ "animCurve"]         ?? ac_test;
    
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
    static __GetBgColor = function(state) {
        switch (state) {
            case MENU_STATE.FOCUSED:  return bgColorFocused;
            case MENU_STATE.DISABLED: return bgColorDisabled;
            case MENU_STATE.PENDING:  return bgColorPending;
            default:                  return bgColorBase;
        }
    }
    static __GetBgSprite = function(state) {
        switch (state) {
            case MENU_STATE.FOCUSED:  return bgSpriteFocused;
            case MENU_STATE.DISABLED: return bgSpriteDisabled;
            case MENU_STATE.PENDING:  return bgSpritePending;
            default:                  return bgSpriteBase;
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

function MenuStyleGetId(name) {
    static cache = __SlateCache();
    return cache.styles[$ name];
}

function StaleStyleCreate(name, config = {}) {
    static cache = __SlateCache();
    cache.styles[$ name] = new __MenuStyle(config);
    return cache.styles[$ name];
}

function MenuStyleDelete(name) {
    static cache = __SlateCache();
    struct_remove(cache.styles, name);
}

function MenuStyleExists(name) {
    static cache = __SlateCache();
    return struct_exists(cache.styles, name);
}

function MenuStyleResolve(style) {
    static cache = __SlateCache();
    if (is_string(style)) return variable_clone(cache.styles[$ style] ?? {});
    if (is_struct(style)) return style;
    return {};
}

function MenuStyleMerge(source, override) {
    var _result = variable_clone(source);
    var _keys = struct_get_names(override);
    for (var i = 0, n = array_length(_keys); i < n; i++) {
        var _key = _keys[i];
        _result[$ _key] = override[$ _key];
    }
    return _result;
}

