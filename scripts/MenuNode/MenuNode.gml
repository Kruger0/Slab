
function MenuNode(id, name, config = {}) constructor{
    self.id     = id;
    self.name   = name;
    
    #region Public
    colors      = config[$ "colors"] ?? {
        base        : #808080,
        focused     : #FFFFFF,
        pending     : #FF0000,
        disabled    : #606060
    };
    alpha       = config[$ "alpha"] ?? 1;
    animSpeed   = config[$ "animSpeed"] ?? 0.5;
    #endregion
    
    #region Private
    __ = {};
    with (__) {
        type        = "BLANK";
        focused     = false;    // If the node has focus (either by keyboard or mouse)
        interactive = true;     // If the node can have focus (either by keyboard or mouse)
        enabled     = true;     // If the node can run its callback when selected
        visible     = true;     // If the node is rendered and calculated on the layout spacing
        hAlign      = fa_left;  // Coordinate position relative to the node
        vAlign      = fa_middle;
        xAnchor     = 0;
        yAnchor     = 0;
        
        angle       = 0;
        xPos        = 0;
        yPos        = 0;
        xScl        = 1;
        yScl        = 1;
        
        zoneArray   = [];
        zoneIndex   = undefined;
        zoneActive  = "";
        zoneNode    = undefined;
        zoneCount   = 0//array_length(flexZones);
        
        onEnterCb   = [];
        onLeaveCb   = [];
    }
    focused     = false;    // If the node has focus (either by keyboard or mouse)
    interactive = true;     // If the node can have focus (either by keyboard or mouse)
    enabled     = true;     // If the node can run its callback when selected
    visible     = true;     // If the node is rendered and calculated on the layout spacing
    hAlign      = fa_left;  // Coordinate position relative to the node
    vAlign      = fa_middle;
    xAnchor     = 0;
    yAnchor     = 0;
    
    angle       = 0;
    xPos        = 0;
    yPos        = 0;
    xScl        = 1;
    yScl        = 1;
    
    xOffAnim    = new AnimTrack(ac_test, "xOff", animSpeed);
    yOffAnim    = new AnimTrack(ac_test, "yOff", animSpeed);
    xSclAnim    = new AnimTrack(ac_test, "xScl", animSpeed);
    ySclAnim    = new AnimTrack(ac_test, "yScl", animSpeed);
    angleAnim   = new AnimTrack(ac_test, "angle", animSpeed);
    
    onUpdateCb  = [];
    onRenderCb  = [];
    onSelectCb  = [];
    
    // DEPRECATED
    flexNode    = undefined;
    flexZones   = [];
    #endregion
    
    // Methods
    static PagePush = function(page) {
        mng.PagePush(page);
    }
    static PagePop = function() {
        mng.PagePop();
    }
    
    static OnUpdate = function(callback, data = undefined) {
        array_push(onUpdateCb, {callback, data});
    }
    static OnRender = function(callback, data = undefined) {
        array_push(onRenderCb, {callback, data});
    }
    static OnSelect = function(callback, data = undefined) {
        array_push(onSelectCb, {callback, data});
    }
    static OnEnter = function(callback, data = undefined) {
        array_push(__.onEnterCb, {callback, data});
    }
    static OnLeave = function(callback, data = undefined) {
        array_push(__.onLeaveCb, {callback, data});
    }
    
    static Update = function(focused){
        // Input
        if (!is_undefined(focused)) SetFocused(focused);
        
        // Animation
        xOffAnim.Update();
        yOffAnim.Update();
        xSclAnim.Update();
        ySclAnim.Update();
        angleAnim.Update();
        xScl = xSclAnim.GetValue();
        yScl = ySclAnim.GetValue();
        
        // Aligmnet
        var _body = ZoneGetBody();
        var _xOff = xOffAnim.GetValue();
        var _yOff = yOffAnim.GetValue();
        
        switch (hAlign) {
            case fa_left:   xPos = _body.x; break;
            case fa_center: xPos = _xOff + _body.x + (_body.w / 2); break;
            case fa_right:  xPos = _xOff + _body.x + _body.w; break;
        }
        switch (vAlign) {
            case fa_top:    yPos = _yOff + _body.y; break;
            case fa_middle: yPos = _yOff + _body.y + (_body.h / 2); break;
            case fa_bottom: yPos = _yOff + _body.y + _body.n; break;
        }
        
        // Active Zone
        __.zoneActive = "";
        var _zoneActive = undefined;
        var _zCurr = -1;
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zoneCurr = flexZones[i];
            _zoneCurr.active = false;
            var _x1 = _zoneCurr.x;
            var _y1 = _zoneCurr.y;
            var _x2 = _x1+_zoneCurr.w;
            var _y2 = _y1+_zoneCurr.h;
            if (point_in_rectangle(mng.__.mx, mng.__.my, _x1, _y1, _x2, _y2)) {
                if (_zoneCurr.z > _zCurr) {
                    _zCurr = _zoneCurr.z;
                    _zoneActive = _zoneCurr;
                }
            }
        }
        if (!is_undefined(_zoneActive)) {
            _zoneActive.active = true;
            __.zoneActive = _zoneActive.type;
        }
        
        // Custom
        for (var i = 0, n = array_length(onUpdateCb); i < n; i++) {
            var _entry = onUpdateCb[i];
            _entry.callback(_entry.data);
        }
    }
    static Render = function() {
        // Custom
        if (array_length(flexZones) < 1) return;
        for (var i = 0, n = array_length(onRenderCb); i < n; i++) {
            var _entry = onRenderCb[i];
            _entry.callback(_entry.data);
        }
        
        // Debug
        if (global.debug) {
            for (var i = 0, n = array_length(flexZones); i < n; i++) {
                var _zone = flexZones[i];
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
            draw_circle_color(xPos, yPos, 6, _c1, _c2, false);
            draw_circle_color(xPos, yPos, 6, _c1, _c1, true);
            
            //for (var i = 0; i < array_length(flexZones); i++) {
            //    draw_text(xPos, yPos+i*16, flexZones[i])
            //}
        }
    }
    static Select = function() {
        // Custom
        for (var i = 0, n = array_length(onSelectCb); i < n; i++) {
            var _e = onSelectCb[i];
            _e.callback(_e.data);
        }
        
        // Debug
        if (global.debug) {
            show_debug_message($"{instanceof(self)} '{name}' - Select()");
        }
    }
    static Enter = function() {
        xSclAnim.Snap(0.8).Play(1);
        ySclAnim.Snap(0.8).Play(1);
        
        // Custom
        for (var i = 0, n = array_length(__.onEnterCb); i < n; i++) {
            var _entry = __.onEnterCb[i];
            _entry.callback(_entry.data);
        }
    }
    static Leave = function() {
        xOffAnim.Snap(0);
        yOffAnim.Snap(0);
        xSclAnim.Snap(1);
        ySclAnim.Snap(1);
        
        focused = false;
        
        // Custom
        for (var i = 0, n = array_length(__.onLeaveCb); i < n; i++) {
            var _entry = __.onLeaveCb[i];
            _entry.callback(_entry.data);
        }
    }
    
    static ContainsPoint = function(px, py) {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
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
    
    static ZoneGetBody = function() {
        if (array_length(flexZones) == 0) return;
        return flexZones[0]; // TODO pass custom node width
    }
    
    static SetFocused = function(focused) {
        if (self.focused == focused) exit;
        self.focused = focused;
        if (focused) OnFocusIn();
        else OnFocusOut();
    }
    
    static OnFocusIn = function(){
        xOffAnim.Play(0);
        yOffAnim.Play(0);
        xSclAnim.Play(1.2);
        ySclAnim.Play(1.2);
    };
    static OnFocusOut = function(){
        xOffAnim.Play(0);
        yOffAnim.Play(0);
        xSclAnim.Play(1);
        ySclAnim.Play(1);
        pending = false;
    };
    
    static ActionLeft = function() {
        
    }
    static ActionRight = function() {
    
    }
    static ActionUp = function() {
        
    }
    static ActionDown = function() {
        
    }
    static ActionSelect = function() {
        Select();
    }
    
    static ActionHandler = function(actions) {
        if (actions.leftPressed) ActionLeft();
        if (actions.rightPressed) ActionRight();
        if (actions.upPressed) ActionUp();
        if (actions.downPressed) ActionDown();
        if (actions.selectPressed) ActionSelect();
    }
    
    static MouseHandler = function(mouse) {
        if (mouse.leftPressed) Select();
    }
}

function MenuNodeText(id, name, config = {}) : MenuNode(id, name, config) constructor {
    type        = "TEXT";
    interactive = false;
    
    background  = config[$ "background"];
    
    OnRender(function() {
        var _body = ZoneGetBody();
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _c = #202020;//colors.disabled;
        var _t = name;
        
        // Background
        if !(is_undefined(background)) {
            if (asset_get_type(background) == asset_sprite) {
                draw_sprite_stretched_ext(background, 0, _x, _y, _w, _h, c_white, 1);
            }
            if (is_real(background)) {
                draw_sprite_stretched_ext(spr_pixel, 0, _x, _y, _w, _h, background, 1);
            }
        }
        
        // Name
        scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(xPos, yPos);
    });
}

function MenuNodeSeparator(id, name = id, config = {}) : MenuNode(id, name, config) constructor {
    type        = "SEPARATOR";
    interactive = false;
    
    drawLine    = config[$ "drawLine"] ?? true;
    height      = config[$ "height"] ?? 4;
    width       = config[$ "width"] ?? 1;
    
    OnRender(function() {
        if (!drawLine) return;;
        var _c = colors.base;
        var _body = ZoneGetBody();
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        draw_set_alpha(alpha);
        draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _c, _c, _c, _c, false);
        draw_set_alpha(1);
    });
}

function MenuNodeSprite(id, name, sprite, config = {}) : MenuNode(id, name, config) constructor {
    type        = "SPRITE";
}

function MenuNodeButton(id, name, onSelect, config = {}) : MenuNode(id, name, config) constructor {
    type = "BUTTON";
    
    if (is_callable(onSelect)) OnSelect(method(self, onSelect));
    
    OnSelect(function() {
        xSclAnim.Snap(1).Play(1.1);
        ySclAnim.Snap(1).Play(1.1);
    })
    
    OnRender(function() {
        var _body = ZoneGetBody();
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _t = name;
        // Background
        
        // Name
        var _c = (focused ? colors.focused : colors.base);
        scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(xPos, yPos);
    });
}

function MenuNodeConfirm(id, name, onSelect, config = {}) : MenuNode(id, name, config) constructor {
    type    = "CONFIRM";
    pending = false;
    msg     = config[$ "msg"] ?? name + "?";
    
    OnConfirm = is_callable(onSelect) ? method(self, onSelect) : undefined;
    
    OnSelect(function() {
        if (pending) {
            if (is_callable(OnConfirm)) OnConfirm();
        } else {
            pending = true;
        }
        xSclAnim.Snap(1).Play(1.1);
        ySclAnim.Snap(1).Play(1.1);
    });
    
    OnRender(function() {
        var _body = ZoneGetBody();
        var _x = _body.x;
        var _y = _body.y;
        var _w = _body.w;
        var _h = _body.h;
        var _c = (focused ? (pending ? colors.pending : colors.focused) : colors.base);
        var _t = (pending ? msg : name);
        
        // Background
        
        // Name
        scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(xPos, yPos);
    });
}

function MenuNodeSelector(id, name, options, valueGet, valueSet, config = {}) : MenuNode(id, name, config) constructor {
    __.type         = "SELECTOR";
    __.name         = name;
    __.optionArray  = options;
    __.optionIndex  = 0;
    __.optionCount  = array_length(options);
    __.optionCycle  = config[$ "cycle"] ?? true;
    
    static ValueGet = method(self, valueGet);
    static ValueSet = method(self, valueSet);
    
    // Find cursor value
    var _value = ValueGet();
    for (var i = 0; i < __.optionCount; i++) {
        if (options[i][1] == _value) {
            __.optionIndex = i;
            break;
        }
    }
    if (__.optionIndex == undefined) {
        show_debug_message($"MenuNodeSelector: value '{_value}' not found in options. Defaulting to 0");
        __.optionIndex = 0;
    }
    
    static OptionGetActive = function() {
        return __.optionArray[__.optionIndex];
    }
    static OptionCycleLeft = function() {
        with (__) {
            if (optionCycle) {
                optionIndex = ((optionIndex - 1) % optionCount + optionCount) % optionCount;
            } else {
                if (optionIndex == 0) return false;
                optionIndex = max(0, optionIndex - 1);
            }
        }
        return true;
    }
    static OptionCycleRight = function() {
        with (__) {
            if (optionCycle) {
                optionIndex = (optionIndex + 1) % optionCount;
            } else {
                if (optionIndex == optionCount-1) return false;
                optionIndex = min(optionCount - 1, optionIndex + 1);
            }
        }
        return true;
    }
    
    static ActionLeft = function() {
        if (OptionCycleLeft()) {
            ValueSet(OptionGetActive());
            xOffAnim.Snap(-10).Play(0);
        }
    }
    static ActionRight = function() {
        if (OptionCycleRight()) {
            ValueSet(OptionGetActive());
            xOffAnim.Snap(10).Play(0);
        }
    }
    
    OnEnter(ValueGet);
    
    OnSelect(function(){
        switch (__.zoneActive) {
            case "LEFT": ActionLeft(); break;
            case "RIGHT": ActionRight(); break;
        }
    });
    
    OnRender(function() {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (focused ? colors.focused : colors.base);
            var _t = name;
            switch (_zone.type) {
                case "BODY": {
                    scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(xPos, yPos);
                } break;
                case "RIGHT": {
                    if (!__.optionCycle && __.optionIndex == __.optionCount-1) break;
                    _t = ">";
                    _c = _zone.active ? colors.focused : colors.base;
                    scribble(_t, id).align(1, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x+_w/2, _y+_h/2);
                } break;
                case "LEFT": {
                    if (!__.optionCycle && __.optionIndex == 0) break;
                    _c = _zone.active ? colors.focused : colors.base;
                    _t = "<";
                    scribble(_t, id).align(1, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x+_w/2, _y+_h/2);
                } break;
                case "VALUE": {
                    _t = string(OptionGetActive()[0]);
                    scribble(_t, id).align(1, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x+_w/2+xOffAnim.GetValue(), _y+_h/2);
                } break;
            }
        }
    });
}

function MenuNodeCheckbox(id, name, valueGet, valueSet, config = {}) : MenuNode(id, name, config) constructor {
    type    = "CHECKBOX";
    value   = 0;
    
    ValueGet = method(self, valueGet);
    ValueSet = method(self, valueSet);
    OnChange = is_callable(onChange) ? method(self, onChange) : undefined;
    
    static ActionSelect = function() {
        value ^= 1;
        OnChange(value);
        xSclAnim.Snap(1).Play(1.1);
        ySclAnim.Snap(1).Play(1.1);
    }
    
    OnSelect(function() {
        switch (__.zoneActive) {
            case "BOX": {
                ActionSelect();
            } break;
        }
    })
    
    OnRender(function() {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (focused ? colors.focused : colors.base);
            var _t = name;
            switch (_zone.type) {
                case "BODY": {
                    scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(xPos, yPos);
                } break;
                case "BOX": {
                    _t = (value ? "[[   ]" : "[[X]");
                    scribble(_t, id).align(1, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x+_w/2, _y+_h/2);
                } break
            }
        }
    });
}

/// @func MenuNodeSlider(id, name, get, set, min, max, step, [format], [config])
function MenuNodeSlider(id, name, valueGet, valueSet, valueMin, valueMax, valueStep, valueFormat, config = {}) : MenuNode(id, name, config) constructor {
    type        = "SLIDER";
    value       = 0;
    dragging    = false;
    
    ValueGet    = method(self, valueGet);
    ValueSet    = method(self, valueSet);
    ValueFormat = method(self, valueFormat ?? function(v){return string(v)});
    
    self.valueMin   = valueMin;
    self.valueMax   = valueMax;
    self.valueStep  = valueStep
    
    OnSelect(function() {
        switch (__.zoneActive) {
            case "BAR": {
                // starts dragging untill mouse button is released
            } break;
        }
    })
    
    OnRender(function() {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x = _zone.x;
            var _y = _zone.y;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = (focused ? colors.focused : colors.base);
            var _t = name;
            switch (_zone.type) {
                case "BODY": {
                    scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(xPos, yPos);
                } break;
                case "VALUE": {
                    scribble(ValueFormat(value), id).align(2, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x+_w, yPos);
                } break
                case "BAR": {
                    draw_rectangle(_x, _y, _x+_w, _y+_h, true);
                } break
            }
        }
    });
}




