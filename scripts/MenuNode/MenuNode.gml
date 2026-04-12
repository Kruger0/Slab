
function MenuNode(id, name, config = {}) constructor{
    
    #region Private
    __id            = id;
    __name          = name;
    __nodeType      = "BLANK";
    __focused       = false;    // If the node has focus (either by keyboard or mouse)
    __interactive   = true;     // If the node can have focus (either by keyboard or mouse)
    __enabled       = true;     // If the node can run its callback when selected
    __visible       = true;     // If the node is rendered and calculated on the layout spacing
    __mng           = undefined;
    __style         = config[$ "style"];
    
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
    __zoneActive    = ""; // zoneName ?
    __zoneCount     = 0;
    __zoneIndex     = undefined;
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
    __xOffAnim      = new AnimTrack(ac_test, "xOff", animSpeed);
    __yOffAnim      = new AnimTrack(ac_test, "yOff", animSpeed);
    __xSclAnim      = new AnimTrack(ac_test, "xScl", animSpeed);
    __ySclAnim      = new AnimTrack(ac_test, "yScl", animSpeed);
    __angleAnim     = new AnimTrack(ac_test, "angle", animSpeed);
    #endregion
    
    // Methods
    static PagePush = function(page) {
        __mng.PagePush(page);
    }
    static PagePop = function() {
        __mng.PagePop();
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
    
    static Update = function(focused){
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
        var _body = ZoneGetData("BODY");
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
            if (point_in_rectangle(__mng.__mouseX, __mng.__mouseY, _x1, _y1, _x2, _y2)) {
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
    static Render = function() {
        
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
    static Select = function() {
        // Custom
        for (var i = 0, n = array_length(__onSelectCb); i < n; i++) {
            var _e = __onSelectCb[i];
            _e.callback(_e.data);
        }
        
        // Debug
        if (global.debug) {
            show_debug_message($"{instanceof(self)} '{__name}' - Select()");
        }
    }
    static Enter = function() {
        __xSclAnim.Snap(0.8).Play(1);
        __ySclAnim.Snap(0.8).Play(1);
        
        // Custom
        for (var i = 0, n = array_length(__onEnterCb); i < n; i++) {
            var _entry = __onEnterCb[i];
            _entry.callback(_entry.data);
        }
    }
    static Leave = function() {
        __xOffAnim.Snap(0);
        __yOffAnim.Snap(0);
        __xSclAnim.Snap(1);
        __ySclAnim.Snap(1);
        
        __focused = false;
        
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
    
    static ZoneGetData = function(type) {
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
        if (__focused) OnFocusIn();
        else OnFocusOut();
    }
    
    static OnFocusIn = function(){
        __xOffAnim.Play(0);
        __yOffAnim.Play(0);
        __xSclAnim.Play(1.2);
        __ySclAnim.Play(1.2);
    };
    static OnFocusOut = function(){
        __xOffAnim.Play(0);
        __yOffAnim.Play(0);
        __xSclAnim.Play(1);
        __ySclAnim.Play(1);
        __pending = false;
    };
    
    static HandleAction = function(action) {};
    static HandleMouse = function(mouse) {};
}

function MenuNodeText(id, name, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType      = "TEXT";
    __name          = name;
    __interactive   = false;
    
    __bgColorBase   = config[$ "bgColorBase"];
    __bgSpriteBase  = config[$ "bgSpriteBase"];
    
    OnRender(function() {
        var _body = ZoneGetData("BODY");
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _c = #202020;//colors.disabled;
        var _t = __name;
        
        // Background
        if (!is_undefined(__bgSpriteBase)) {
            draw_sprite_stretched_ext(__bgSpriteBase, 0, _x, _y, _w, _h, __bgColorBase ?? c_white, 1);
        } else if (!is_undefined(__bgColorBase)) {
            draw_sprite_stretched_ext(spr_pixel, 0, _x, _y, _w, _h, __bgColorBase, 1);
        }
        
        // Name
        scribble(_t, __id)
            .align(__hAlign, __vAlign)
            .blend(_c, __alpha)
            .transform(__xScl, __yScl, __angle)
            .draw(__xPos, __yPos);
    });
}

function MenuNodeSeparator(id, name = id, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType      = "SEPARATOR";
    __name          = name;
    __interactive   = false;
    
    __drawLine      = config[$ "drawLine"] ?? true;
    __height        = config[$ "height"] ?? 4;
    __width         = config[$ "width"] ?? 1;
    
    OnRender(function() {
        if (!__drawLine) return;;
        var _c = colors.base;
        var _body = ZoneGetData("BODY");
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        draw_set_alpha(__alpha);
        draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _c, _c, _c, _c, false);
        draw_set_alpha(1);
    });
}

function MenuNodeSprite(id, name, sprite, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType  = "SPRITE";
    __name      = name;
}

function MenuNodeButton(id, name, callback, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType  = "BUTTON";
    __name      = name;
    
    Callback = method(self, callback ?? function(){});
    
    static DoSelect = function() {
        __xSclAnim.Snap(1).Play(1.2);
        __ySclAnim.Snap(1).Play(1.2);
        Callback();
    }
    
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) DoSelect();
    }
    static HandleAction = function(action) {
        if (action.selectPressed) DoSelect();
    }
    
    OnRender(function() {
        var _body = ZoneGetData("BODY");
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _t = __name;
        // Background
        
        // Name
        var _c = (__focused ? colors.focused : colors.base);
        scribble(_t, __id)
            .align(__hAlign, __vAlign)
            .blend(_c, __alpha)
            .transform(__xScl, __yScl, __angle)
            .draw(__xPos, __yPos);
    });
}

function MenuNodeConfirm(id, name, callback, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType  = "SELECTOR";
    __name      = name;
    __pending   = false;
    __message   = config[$ "message"] ?? name + "?";
    
    Callback = method(self, callback ?? function(){});
    
    static DoSelect = function() {
        __xSclAnim.Snap(1).Play(1.2);
        __ySclAnim.Snap(1).Play(1.2);
        if (__pending) {
            Callback();
            __pending = false;
        } else {
            __pending = true;
        }
    }
    
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) DoSelect();
    }
    static HandleAction = function(action) {
        if (action.selectPressed) DoSelect();
    }
    
    OnRender(function() {
        var _body = ZoneGetData("BODY");
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _c = (__focused ? (__pending ? colors.pending : colors.focused) : colors.base);
        var _t = (__pending ? __message : __name);
        
        // Background
        
        // Name
        scribble(_t, __id)
            .align(__hAlign, __vAlign)
            .blend(_c, __alpha)
            .transform(__xScl, __yScl, __angle)
            .draw(__xPos, __yPos);
    });
    OnLeave(function() {
        __pending = false;
    })
}

function MenuNodeSelector(id, name, options, valueGet, valueSet, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType      = "SELECTOR";
    __name          = name;
    __optionArray   = options;
    __optionCount   = array_length(options);
    __optionIndex   = undefined;
    __optionCycle   = config[$ "cycle"] ?? true;
    
    ValueGet = method(self, valueGet);
    ValueSet = method(self, valueSet);

    static OptionGetActive = function() {
        return __optionArray[__optionIndex];
    }
    static OptionCycleLeft = function() {
        if (__optionCycle) {
            __optionIndex = ((__optionIndex - 1) % __optionCount + __optionCount) % __optionCount;
        } else {
            if (__optionIndex == 0) return false;
            __optionIndex = max(0, __optionIndex - 1);
        }
        return true;
    }
    static OptionCycleRight = function() {
        if (__optionCycle) {
            __optionIndex = (__optionIndex + 1) % __optionCount;
        } else {
            if (__optionIndex == __optionCount-1) return false;
            __optionIndex = min(__optionCount - 1, __optionIndex + 1);
        }
        return true;
    }
    
    static DoLeft = function() {
        if (OptionCycleLeft()) {
            __xOffAnim.Snap(-10).Play(0);
            ValueSet(OptionGetActive());
        }
    }
    static DoRight = function() {
        if (OptionCycleRight()) {
            __xOffAnim.Snap(10).Play(0);
            ValueSet(OptionGetActive());
        }
    }
    
    static HandleAction = function(action) {
        if (action.leftPressed) DoLeft();
        if (action.rightPressed) DoRight();
    }
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) {
            switch (__zoneActive) {
                case "LEFT": DoLeft(); break;
                case "RIGHT": DoRight(); break;
            }
        }
    }
    
    OnEnter(function() {
        var _value = ValueGet();
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
            var _t = __name;
            switch (_zone.type) {
                case "BODY": {
                    scribble(_t, __id)
                        .align(__hAlign, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(__xPos, __yPos);
                } break;
                case "RIGHT": {
                    if (!__optionCycle && __optionIndex == __optionCount-1) break;
                    _t = ">";
                    _c = _zone.active ? colors.focused : colors.base;
                    scribble(_t, __id)
                        .align(1, 1)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w/2, _y+_h/2);
                } break;
                case "LEFT": {
                    if (!__optionCycle && __optionIndex == 0) break;
                    _c = _zone.active ? colors.focused : colors.base;
                    _t = "<";
                    scribble(_t, __id)
                        .align(1, 1)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w/2, _y+_h/2);
                } break;
                case "VALUE": {
                    _t = string(OptionGetActive()[0]);
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

function MenuNodeCheckbox(id, name, valueGet, valueSet, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType  = "CHECKBOX";
    __name      = name;
    __value     = undefined;
    
    ValueGet = method(self, valueGet);
    ValueSet = method(self, valueSet);
    
    static DoSelect = function() {
        __xSclAnim.Snap(1).Play(1.2);
        __ySclAnim.Snap(1).Play(1.2);
        __value = !__value;
        ValueSet(__value);
    }
    
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed) DoSelect();
    }
    static HandleAction = function(action) {
        if (action.selectPressed) DoSelect();
    }
    
    OnEnter(function() {
        var _value = ValueGet();
        if (is_real(_value) || is_bool(_value)) {
            __value = _value;
        }
        if (is_undefined(_value)) {
            show_debug_message($"MenuNodeCheckbox: bool '{_value}' could not be solved. Defaulting to false");
            __value = false;
        }
    });
    OnSelect(function() {
        switch (__zoneActive) {
            case "BOX": {
                ActionSelect();
            } break;
        }
    })
    OnRender(function() {
        for (var i = 0; i < __zoneCount; i++) {
            var _zone = __zoneArray[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (__focused ? colors.focused : colors.base);
            var _t = __name;
            switch (_zone.type) {
                case "BODY": {
                    scribble(_t, __id)
                        .align(__hAlign, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(__xPos, __yPos);
                } break;
                case "BOX": {
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

function MenuNodeSlider(id, name, valueGet, valueSet, valueMin, valueMax, valueStep, valueFormat = function(v){return string(v)}, config = {}) : MenuNode(id, name, config) constructor {
    __nodeType  = "SLIDER";
    __value     = undefined;
    __valueMin  = valueMin;
    __valueMax  = valueMax;
    __valueStep = valueStep
    __dragging  = false;
    
    ValueGet    = method(self, valueGet);
    ValueSet    = method(self, valueSet);
    ValueFormat = method(self, valueFormat);
    
    static DoLeft = function() {
        __value -= __valueStep;
        __value = clamp(__value, __valueMin, __valueMax);
        ValueSet(__value);
    }
    static DoRight = function() {
        __value += __valueStep;
        __value = clamp(__value, __valueMin, __valueMax);
        ValueSet(__value);
    }
    
    static HandleAction = function(action) {
        if (action.leftPressed) DoLeft();
        if (action.rightPressed) DoRight();
    }
    static HandleMouse = function(mouse) {
        if (mouse.leftPressed && __zoneActive == "BAR") {
            __dragging = true;
            __mng.NodeLock(self);
        }
        if (__dragging) {
            var _bar = ZoneGetData("BAR");
            var _delta = clamp((__mng.__mouseX - _bar.x) / _bar.w, 0, 1);
            var _value = __valueMin + _delta * (__valueMax - __valueMin);
            _value = round(_value / __valueStep) * __valueStep;
            _value = clamp(_value, __valueMin, __valueMax);
            if (_value != __value) {
                __value = _value;
                ValueSet(__value);
            }
            if (mouse.leftReleased) {
                __dragging = false;
                __mng.NodeUnlock();
            }
        }
    }
    
    OnEnter(function() {
        var _value = ValueGet();
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
            var _t = __name;
            switch (_zone.type) {
                case "BODY": {
                    scribble(_t, __id)
                        .align(__hAlign, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(__xPos, __yPos);
                } break;
                case "VALUE": {
                    scribble(ValueFormat(__value), __id)
                        .align(2, __vAlign)
                        .blend(_c, __alpha)
                        .transform(__xScl, __yScl, __angle)
                        .draw(_x+_w, __yPos);
                } break
                case "BAR": {
                    _c = colors.base;
                    draw_rectangle_colour(_x, _y, _x+_w, _y+_h, _c, _c, _c, _c, false);
                    _c = colors.focused;
                    var _n = (__value - __valueMin) / (__valueMax - __valueMin);
                    draw_rectangle_colour(_x, _y, _x+_w*_n, _y+_h, _c, _c, _c, _c, false);
                } break
            }
        }
    });
}

