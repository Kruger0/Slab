
function MenuNode(id, label, config = {}) constructor{
    
    #region Private
    __id            = id;
    __label         = label;
    __style         = undefined;
    __styleSource   = undefined;
    __styleOverride = MenuBindStyle(config[$ "style"]);
    __type          = MENU_NODE_BLANK;
    __state         = MENU_STATE.BASE;
    
    __pending       = false;
    __dragging      = false;
    __focused       = false;    // If the node has focus (either by keyboard or mouse)
    
    __interactive   = true;     // If the node can have focus (either by keyboard or mouse)
    __enabled       = true;     // If the node can run its callback when selected
    __visible       = true;     // If the node is rendered and calculated on the layout spacing
    
    __manager       = undefined;
    __page          = undefined;
    
    __value         = undefined;
    
    __hAlign        = fa_left;  // Coordinate position relative to the node
    __vAlign        = fa_middle;
    __xAnchor       = 0;
    __yAnchor       = 0;
    __angle         = 0;
    __xPos          = 0;
    __yPos          = 0;
    __xScl          = 1;
    __yScl          = 1;
    
    __alpha         = 1;
    
    __zoneArray     = [];
    __zoneCount     = 0;
    __zoneActive    = "";
    __zoneNode      = undefined;
    
    __onUpdateCb    = [];
    __onRenderCb    = [];
    __onSelectCb    = [];
    __onEnterCb     = [];
    __onLeaveCb     = [];
    #endregion
    
    #region Style
    colors      = config[$ "colors"] ?? {
        base        : #808080,
        focused     : #FFFFFF,
        pending     : #FF0000,
        disabled    : #606060
    };
    alpha       = config[$ "alpha"] ?? 1;
    animSpeed   = config[$ "animSpeed"] ?? 0.5;
    __xOffAnim      = new MenuAnimTrack(ac_test, "xOff", animSpeed);
    __yOffAnim      = new MenuAnimTrack(ac_test, "yOff", animSpeed);
    __xSclAnim      = new MenuAnimTrack(ac_test, "xScl", animSpeed);
    __ySclAnim      = new MenuAnimTrack(ac_test, "yScl", animSpeed);
    __angleAnim     = new MenuAnimTrack(ac_test, "angle", animSpeed);
    #endregion
    
    // Methods
    static PushPage = function(page) {
        __manager.PushPage(page);
    }
    static PopPage = function() {
        __manager.PopPage();
    }
    
    static OnUpdate = function(callback, data = undefined) {
        array_push(__onUpdateCb, {callback, data});
    }
    static OnRender = function(callback, data = undefined) {
        array_push(__onRenderCb, {callback, data});
    }
    static OnSelect = function(callback, data = undefined) {
        array_push(__onSelectCb, {callback, data});
    }
    static OnEnter = function(callback, data = undefined) {
        array_push(__onEnterCb, {callback, data});
    }
    static OnLeave = function(callback, data = undefined) {
        array_push(__onLeaveCb, {callback, data});
    }
    
    static __Update = function(focused){
        // Input
        if (!is_undefined(focused)) SetFocused(focused);
        
        // Animation
        __xOffAnim.Update();
        __yOffAnim.Update();
        __xSclAnim.Update();
        __ySclAnim.Update();
        __angleAnim.Update();
        __xScl = __xSclAnim.GetValue();
        __yScl = __ySclAnim.GetValue();
        
        // Aligmnet
        var _body = GetZoneData(MENU_ZONE_BODY);
        var _xOff = __xOffAnim.GetValue();
        var _yOff = __yOffAnim.GetValue();
        
        switch (__hAlign) {
            case fa_left:   __xPos = _body.x; break;
            case fa_center: __xPos = _xOff + _body.x + (_body.w / 2); break;
            case fa_right:  __xPos = _xOff + _body.x + _body.w; break;
        }
        switch (__vAlign) {
            case fa_top:    __yPos = _yOff + _body.y; break;
            case fa_middle: __yPos = _yOff + _body.y + (_body.h / 2); break;
            case fa_bottom: __yPos = _yOff + _body.y + _body.n; break;
        }
        
        // Active Zone
        __zoneActive = "";
        var _zoneActive = undefined;
        var _zCurr = -1;
        for (var i = 0, n = __zoneCount; i < n; i++) {
            var _zoneCurr = __zoneArray[i];
            _zoneCurr.active = false;
            var _x1 = _zoneCurr.x;
            var _y1 = _zoneCurr.y;
            var _x2 = _x1+_zoneCurr.w;
            var _y2 = _y1+_zoneCurr.h;
            if (point_in_rectangle(__manager.__mouseX, __manager.__mouseY, _x1, _y1, _x2, _y2)) {
                if (_zoneCurr.z > _zCurr) {
                    _zCurr = _zoneCurr.z;
                    _zoneActive = _zoneCurr;
                }
            }
        }
        if (!is_undefined(_zoneActive)) {
            _zoneActive.active = true;
            __zoneActive = _zoneActive.type;
        }
        
        // Custom
        for (var i = 0, n = array_length(__onUpdateCb); i < n; i++) {
            var _entry = __onUpdateCb[i];
            _entry.callback(_entry.data);
        }
    }
    static __Render = function() {
        
        // Custom
        if (__zoneCount < 1) return;
        for (var i = 0, n = array_length(__onRenderCb); i < n; i++) {
            var _entry = __onRenderCb[i];
            _entry.callback(_entry.data);
        }
        
        // Debug
        if (global.debug) {
            for (var i = 0; i < __zoneCount; i++) {
                var _zone = __zoneArray[i];
                var _x = _zone.x;
                var _y = _zone.y;
                var _w = _zone.w;
                var _h = _zone.h;
                var _c1 = #FF0000;
                var _c2 = #00FF00
                draw_rectangle_colour(_x, _y, _x+_w, _y+_h, _c1, _c2, _c1, _c2, true);
            }
            var _c1 = #000000;
            var _c2 = #FFFFFF;
            draw_circle_color(__xPos, __yPos, 6, _c1, _c2, false);
            draw_circle_color(__xPos, __yPos, 6, _c1, _c1, true);
        }
    }
    static __Select = function() {
        // Custom
        for (var i = 0, n = array_length(__onSelectCb); i < n; i++) {
            var _e = __onSelectCb[i];
            _e.callback(_e.data);
        }
        
        // Debug
        if (global.debug) {
            show_debug_message($"{instanceof(self)} '{__label}' - Select()");
        }
    }
    static __Enter = function(page) {
        // Define
        __page = page;
        __manager = page.__manager;
        __styleSource = page.__styleSource;
        __style = MenuMergeStyle(__styleSource, __styleOverride);
        
        // Animate
        __xSclAnim.Snap(0.8).Play(1);
        __ySclAnim.Snap(0.8).Play(1);
        
        // Custom
        for (var i = 0, n = array_length(__onEnterCb); i < n; i++) {
            var _entry = __onEnterCb[i];
            _entry.callback(_entry.data);
        }
    }
    static __Leave = function() {
        __xOffAnim.Snap(0);
        __yOffAnim.Snap(0);
        __xSclAnim.Snap(1);
        __ySclAnim.Snap(1);
        
        __focused   = false;
        __pending   = false;
        __dragging  = false;
        
        // Custom
        for (var i = 0, n = array_length(__onLeaveCb); i < n; i++) {
            var _entry = __onLeaveCb[i];
            _entry.callback(_entry.data);
        }
    }
    
    static ContainsPoint = function(px, py) {
        for (var i = 0; i < __zoneCount; i++) {
            var _zone = __zoneArray[i];
            var _x1 = _zone.x;
            var _y1 = _zone.y;
            var _x2 = _x1+_zone.w;
            var _y2 = _y1+_zone.h;
            if (point_in_rectangle(px, py, _x1, _y1, _x2, _y2)) {
                return true;
            }
        }
        return false;
    }
    
    static GetZoneData = function(type) {
        var _data = undefined
        for (var i = 0; i < __zoneCount; i++) {
            var _zone = __zoneArray[i];
            if (_zone.type == type) {
                _data = _zone;
                break;
            }
        }
        return _data;
    }
    
    static SetFocused = function(focused) {
        if (__focused == focused) exit;
        __focused = focused;
        if (__focused) __OnFocusIn();
        else __OnFocusOut();
    }
    
    static __OnFocusIn = function(){
        __xOffAnim.Play(0);
        __yOffAnim.Play(0);
        __xSclAnim.Play(1.2);
        __ySclAnim.Play(1.2);
    };
    static __OnFocusOut = function(){
        __xOffAnim.Play(0);
        __yOffAnim.Play(0);
        __xSclAnim.Play(1);
        __ySclAnim.Play(1);
        __pending = false;
    };
    
    static HandleAction = function(action) {};
    static HandleMouse = function(mouse) {};
    
}

function MenuNodeText(id, label, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_TEXT;
    __label = label;
    __interactive = false;
    
    __bgColorBase = config[$ "bgColorBase"];
    __bgSpriteBase = config[$ "bgSpriteBase"];
    
    OnRender(function() {
        var _body = GetZoneData(MENU_ZONE_BODY);
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _c = #202020;//colors.disabled;
        var _t = __label;
        
        // Background
        if (!is_undefined(__bgSpriteBase)) {
            draw_sprite_stretched_ext(__bgSpriteBase, 0, _x, _y, _w, _h, __bgColorBase ?? c_white, 1);
        } else if (!is_undefined(__bgColorBase)) {
            draw_sprite_stretched_ext(spr_pixel, 0, _x, _y, _w, _h, __bgColorBase, 1);
        }
        
        // Label
        scribble(_t, __id)
            .align(__hAlign, __vAlign)
            .blend(_c, __alpha)
            .transform(__xScl, __yScl, __angle)
            .draw(__xPos, __yPos);
    });
}

function MenuNodeSeparator(id, label = id, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_SEPARATOR;
    __label = label;
    __interactive = false;
    
    __drawLine = config[$ "drawLine"] ?? true;
    __height = config[$ "height"] ?? 4;
    __width = config[$ "width"] ?? 1;
    
    OnRender(function() {
        if (!__drawLine) return;;
        var _c = colors.base;
        var _body = GetZoneData(MENU_ZONE_BODY);
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        draw_set_alpha(__alpha);
        draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _c, _c, _c, _c, false);
        draw_set_alpha(1);
    });
}

function MenuNodeSprite(id, label, sprite, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_SPRITE;
    __label = label;
}

function MenuNodeButton(id, label, callback, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_BUTTON;
    __label = label;
    
    Callback = method(self, callback ?? function(){});
    
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) __Select();
    }
    static HandleAction = function(action) {
        if (action.selectPressed) __Select();
    }
    
    OnSelect(function() {
        __xSclAnim.Snap(1).Play(1.2);
        __ySclAnim.Snap(1).Play(1.2);
        Callback();
    });
    OnRender(function() {
        var _body = GetZoneData(MENU_ZONE_BODY);
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _t = __label;
        // Background
        
        // Label
        var _c = (__focused ? __style.colorFocused : __style.colorBase);
        scribble(_t, __id)
            .align(__hAlign, __vAlign)
            .blend(_c, __alpha)
            .transform(__xScl, __yScl, __angle)
            .draw(__xPos, __yPos);
    });
}

function MenuNodeConfirm(id, label, callback, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_SELECTOR;
    __label = label;
    __message = config[$ "message"] ?? label + "?";
    
    Callback = method(self, callback ?? function(){});
    
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) __Select();
    }
    static HandleAction = function(action) {
        if (action.selectPressed) __Select();
    }
    
    OnSelect(function() {
        __xSclAnim.Snap(1).Play(1.2);
        __ySclAnim.Snap(1).Play(1.2);
        if (__pending) {
            Callback();
            __pending = false;
        } else {
            __pending = true;
        }
    });
    OnRender(function() {
        var _body = GetZoneData(MENU_ZONE_BODY);
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _c = (__focused ? (__pending ? colors.pending : colors.focused) : colors.base);
        var _t = (__pending ? __message : __label);
        
        // Background
        
        // Label
        scribble(_t, __id)
            .align(__hAlign, __vAlign)
            .blend(_c, __alpha)
            .transform(__xScl, __yScl, __angle)
            .draw(__xPos, __yPos);
    });
}

function MenuNodeSelector(id, label, options, valueGetter, valueSetter, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_SELECTOR;
    __label = label;
    __optionArray = options;
    __optionCount = array_length(options);
    __optionIndex = undefined;
    __optionCycle = config[$ "cycle"] ?? true;
    
    GetValue = method(self, valueGetter);
    SetValue = method(self, valueSetter);

    static GetActiveOption = function() {
        return __optionArray[__optionIndex];
    }
    static CycleOptionLeft = function() {
        if (__optionCycle) {
            __optionIndex = ((__optionIndex - 1) % __optionCount + __optionCount) % __optionCount;
        } else {
            if (__optionIndex == 0) return false;
            __optionIndex = max(0, __optionIndex - 1);
        }
        return true;
    }
    static CycleOptionRight = function() {
        if (__optionCycle) {
            __optionIndex = (__optionIndex + 1) % __optionCount;
        } else {
            if (__optionIndex == __optionCount-1) return false;
            __optionIndex = min(__optionCount - 1, __optionIndex + 1);
        }
        return true;
    }
    
    static SelectLeft = function() {
        if (CycleOptionLeft()) {
            __xOffAnim.Snap(-10).Play(0);
            SetValue(GetActiveOption());
        }
    }
    static SelectRight = function() {
        if (CycleOptionRight()) {
            __xOffAnim.Snap(10).Play(0);
            SetValue(GetActiveOption());
        }
    }
    
    static HandleAction = function(action) {
        if (action.leftPressed) SelectLeft();
        if (action.rightPressed) SelectRight();
    }
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) {
            switch (__zoneActive) {
                case MENU_ZONE_LEFT: SelectLeft(); break;
                case MENU_ZONE_RIGHT: SelectRight(); break;
            }
        }
    }
    
    OnEnter(function() {
        var _value = GetValue();
        for (var i = 0; i < __optionCount; i++) {
            if (__optionArray[i][1] == _value) {
                __optionIndex = i;
                break;
            }
        }
        if (__optionIndex == undefined) {
            show_debug_message($"MenuNodeSelector: value '{_value}' not found in options. Defaulting to 0");
            __optionIndex = 0;
        }
    });
    OnRender(function() {
        for (var i = 0; i < __zoneCount; i++) {
            var _zone = __zoneArray[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (__focused ? colors.focused : colors.base);
            var _t = __label;
            switch (_zone.type) {
                case MENU_ZONE_BODY: {
                    // Label
                    scribble(_t, __id)
                        .align(__hAlign, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(__xPos, __yPos);
                } break;
                case MENU_ZONE_LEFT: {
                    if (!__optionCycle && __optionIndex == 0) break;
                    _c = _zone.active ? colors.focused : colors.base;
                    _t = "<";
                    scribble(_t, __id)
                        .align(1, 1)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w/2, _y+_h/2);
                } break;
                case MENU_ZONE_RIGHT: {
                    if (!__optionCycle && __optionIndex == __optionCount-1) break;
                    _t = ">";
                    _c = _zone.active ? colors.focused : colors.base;
                    scribble(_t, __id)
                        .align(1, 1)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w/2, _y+_h/2);
                } break;
                case MENU_ZONE_VALUE: {
                    _t = string(GetActiveOption()[0]);
                    scribble(_t, __id)
                        .align(1, 1)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w/2+__xOffAnim.GetValue(), _y+_h/2);
                } break;
            }
        }
    });
}

function MenuNodeCheckbox(id, label, valueGetter, valueSetter, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_CHECKBOX;
    __label = label;
    
    GetValue = method(self, valueGetter);
    SetValue = method(self, valueSetter);
    
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) {
            switch (__zoneActive) {
                case MENU_ZONE_BOX: __Select(); break;
            }
        };
    }
    static HandleAction = function(action) {
        if (action.selectPressed) __Select();
    }
    
    OnEnter(function() {
        var _value = GetValue();
        if (is_real(_value) || is_bool(_value)) {
            __value = _value;
        }
        if (is_undefined(_value)) {
            show_debug_message($"MenuNodeCheckbox: bool '{_value}' could not be solved. Defaulting to false");
            __value = false;
        }
    });
    OnSelect(function() {
        __xSclAnim.Snap(1).Play(1.2);
        __ySclAnim.Snap(1).Play(1.2);
        __value = !__value;
        SetValue(__value);
    });
    OnRender(function() {
        for (var i = 0; i < __zoneCount; i++) {
            var _zone = __zoneArray[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (__focused ? colors.focused : colors.base);
            var _t = __label;
            switch (_zone.type) {
                case MENU_ZONE_BODY: {
                    // Label
                    scribble(_t, __id)
                        .align(__hAlign, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(__xPos, __yPos);
                } break;
                case MENU_ZONE_BOX: {
                    _t = (__value ? "[[X]" : "[[   ]");
                    scribble(_t, __id)
                        .align(1, 1)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w/2, _y+_h/2);
                } break
            }
        }
    });
}

function MenuNodeSlider(id, label, valueGetter, valueSetter, valueMin, valueMax, valueStep, valueFormat = function(v){return string(v)}, config = {}) : MenuNode(id, label, config) constructor {
    __type = MENU_NODE_SLIDER;
    __valueMin = valueMin;
    __valueMax = valueMax;
    __valueStep = valueStep;
    __valueNorm = undefined;
    
    GetValue = method(self, valueGetter);
    SetValue = method(self, valueSetter);
    FormatValue = method(self, valueFormat);
    
    static SelectLeft = function() {
        __value -= __valueStep ?? 1;
        __value = clamp(__value, __valueMin, __valueMax);
        SetValue(__value);
    }
    static SelectRight = function() {
        __value += __valueStep ?? 1;
        __value = clamp(__value, __valueMin, __valueMax);
        SetValue(__value);
    }
    
    static HandleAction = function(action) {
        if (action.leftPressed) SelectLeft();
        if (action.rightPressed) SelectRight();
    }
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed && __zoneActive == MENU_ZONE_BAR) {
            __dragging = true;
            __manager.LockNode(self);
        }
        if (__dragging) {
            var _bar = GetZoneData(MENU_ZONE_BAR);
            var _delta = clamp((__manager.__mouseX - _bar.x) / _bar.w, 0, 1);
            var _value = __valueMin + _delta * (__valueMax - __valueMin);
            if (!is_undefined(__valueStep)) _value = round(_value / __valueStep) * __valueStep;
            _value = clamp(_value, __valueMin, __valueMax);
            if (_value != __value) {
                __value = _value;
                SetValue(__value);
            }
            if (mouse.leftReleased) {
                __dragging = false;
                __manager.UnlockNode();
            }
        }
    }
    
    OnEnter(function() {
        var _value = GetValue();
        __value = _value;
    })
    OnRender(function() {
        for (var i = 0; i < __zoneCount; i++) {
            var _zone = __zoneArray[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (__focused ? colors.focused : colors.base);
            var _t = __label;
            switch (_zone.type) {
                case MENU_ZONE_BODY: {
                    // Label
                    scribble(_t, __id)
                        .align(__hAlign, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(__xPos, __yPos);
                } break;
                case MENU_ZONE_VALUE: {
                    scribble(FormatValue(__value), __id)
                        .align(2, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w, __yPos);
                } break
                case MENU_ZONE_BAR: {
                    // Enable Edge Mask
                    gpu_set_stencil_enable(true);
                    draw_clear_stencil(0);
                    gpu_set_stencil_func(cmpfunc_always);
                    gpu_set_stencil_ref(1);
                    gpu_set_stencil_pass(stencilop_replace);
                    gpu_set_colorwriteenable(false, false, false, false);
                    var _r = _h/2;
                    draw_rectangle(_x+_r, _y, _x+_w-_r, _y+_h, false);
                    draw_circle(_x+_r, _y+_r, _r, false);
                    draw_circle(_x+_w-_r, _y+_r, _r,false);
                    gpu_set_colorwriteenable(true, true, true, true);
                    gpu_set_stencil_func(cmpfunc_equal);
                    gpu_set_stencil_ref(1);
                    gpu_set_stencil_pass(stencilop_keep);
                    
                    // Background
                    _c = #404040;
                    draw_rectangle_colour(_x, _y, _x+_w, _y+_h, _c, _c, _c, _c, false);
                    
                    // Slider
                    _c = (__focused ? colors.focused : colors.base)
                    var _n = (__value - (__valueMin)) / ((__valueMax) - (__valueMin));
                    draw_rectangle_colour(_x, _y, _x+_w*_n, _y+_h, _c, _c, _c, _c, false);
                    
                    // Foreground
                    
                    // Disable Edge Mask
                    gpu_set_stencil_enable(false);
                } break
            }
        }
    });
}
