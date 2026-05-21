
function __SlabStyle(config = {}) constructor {    
    colorBase           = config[$ "colorBase"]         ?? #808080;
    colorFocused        = config[$ "colorFocused"]      ?? #FFFFFF;
    colorDisabled       = config[$ "colorDisabled"]     ?? #808080;
    colorPending        = config[$ "colorPending"]      ?? #FF4040;
    
    bgColorBase         = config[$ "bgColorBase"]       ?? #202020;
    bgColorFocused      = config[$ "bgColorFocused"]    ?? #404040;
    bgColorDisabled     = config[$ "bgColorDisabled"]   ?? #202020;
    bgColorPending      = config[$ "bgColorPending"]    ?? #402020;
    
    bgSpriteBase        = config[$ "bgSpriteBase"]      ?? undefined;
    bgSpriteFocused     = config[$ "bgSpriteFocused"]   ?? undefined;
    bgSpriteDisabled    = config[$ "bgSpriteDisabled"]  ?? undefined;
    bgSpritePending     = config[$ "bgSpritePending"]   ?? undefined;
    
    alphaBase           = config[$ "alphaBase"]         ?? 1.0;
    alphaFocused        = config[$ "alphaFocused"]      ?? 1.0;
    alphaDisabled       = config[$ "alphaDisabled"]     ?? 0.5;
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
            case SLAB_STATE.FOCUSED:  return colorFocused;
            case SLAB_STATE.DISABLED: return colorDisabled;
            case SLAB_STATE.PENDING:  return colorPending;
            default:                  return colorBase;
        }
    }
    static __GetBgColor = function(state) {
        switch (state) {
            case SLAB_STATE.FOCUSED:  return bgColorFocused;
            case SLAB_STATE.DISABLED: return bgColorDisabled;
            case SLAB_STATE.PENDING:  return bgColorPending;
            default:                  return bgColorBase;
        }
    }
    static __GetBgSprite = function(state) {
        switch (state) {
            case SLAB_STATE.FOCUSED:  return bgSpriteFocused;
            case SLAB_STATE.DISABLED: return bgSpriteDisabled;
            case SLAB_STATE.PENDING:  return bgSpritePending;
            default:                  return bgSpriteBase;
        }
    }
    static __GetAlpha = function(state) {
        switch (state) {
            case SLAB_STATE.FOCUSED:  return alphaFocused;
            case SLAB_STATE.DISABLED: return alphaDisabled;
            case SLAB_STATE.PENDING:  return alphaPending;
            default:                  return alphaBase;
        }
    }
    static __GetScale = function(state) {
        switch (state) {
            case SLAB_STATE.FOCUSED:  return scaleFocused;
            case SLAB_STATE.DISABLED: return scaleDisabled;
            case SLAB_STATE.PENDING:  return scalePending;
            default:                  return scaleBase;
        }
    }
}

function SlabStyleGetId(name) {
    static cache = __SlabCache();
    return cache.styles[$ name];
}

function SlabStyleCreate(name, config = {}) {
    static cache = __SlabCache();
    cache.styles[$ name] = (config);
    return cache.styles[$ name];
}

function SlabStyleDelete(name) {
    static cache = __SlabCache();
    struct_remove(cache.styles, name);
}

function SlabStyleExists(name) {
    static cache = __SlabCache();
    return struct_exists(cache.styles, name);
}

function SlabStyleResolve(style) {
    static cache = __SlabCache();
    if (is_string(style)) return variable_clone(cache.styles[$ style] ?? {});
    if (is_struct(style)) return style;
    return {};
}

function SlabStyleMerge(source, override) {
    var _result = variable_clone(source);
    var _keys = struct_get_names(override);
    for (var i = 0, n = array_length(_keys); i < n; i++) {
        var _key = _keys[i];
        _result[$ _key] = override[$ _key];
    }
    return _result;
}

