

function MenuNode(id, name, config = {}) constructor{
    self.id     = id;
    self.name   = name;
    
    #region Public
    colors      = config[$ "colors"] ?? {
        base        : #FFFFFF,
        focused     : #FFFF00,
        pending     : #FF0000,
        disabled    : #606060
    };
    alpha       = config[$ "alpha"] ?? 1;
    animSpeed   = config[$ "animSpeed"] ?? 0.5;
    #endregion
    
    #region Private
    focused     = false;    // If the node has focus (either by keyboard or mouse)
    interactive = true;     // If the node can have focus (either by keyboard or mouse)
    enabled     = true;     // If the node can run its callback when selected
    visible     = true;     // If the node is rendered and calculated on the layout spacing
    hAlign     = fa_left;  // Coordinate position relative to the node
    vAlign     = fa_middle;
    
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
    
    static Update = function(focused){
        // Input
        if (!is_undefined(focused)) SetFocused(focused);
        
        var _body = flexZones[0];
        switch (hAlign) {
            case fa_left:   xPos = _body.x; break;
            case fa_center: xPos = _body.x + (_body.w / 2); break;
            case fa_right:  xPos = _body.x + _body.w; break;
        }
        
        switch (vAlign) {
            case fa_top:    yPos = _body.x; break;
            case fa_middle: yPos = _body.x + (_body.w / 2); break;
            case fa_bottom: yPos = _body.x + _body.w; break;
        }
        
        // Animation
        xOffAnim.Update();
        yOffAnim.Update();
        xSclAnim.Update();
        ySclAnim.Update();
        
        xPos = xOffAnim.GetValue();
        yPos = yOffAnim.GetValue();
        xScl  = xSclAnim.GetValue();// * ctx.scale;
        yScl  = ySclAnim.GetValue();// * ctx.scale;
        
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
            //var _activeZone = ZoneGetActive();
            //draw_circle_color(xPos, yPos, 2, c_red, c_red, false);
            //draw_text(xPos + 100, yPos, _activeZone);
            
            for (var i = 0, n = array_length(flexZones); i < n; i++) {
                var _zone = flexZones[i];
                var _x = _zone.x;
                var _y = _zone.y;
                var _w = _zone.w;
                var _h = _zone.h;
                var _filter = gpu_get_tex_filter();
                gpu_set_tex_filter(false);
                draw_sprite_stretched_ext(spr_flex_area, 1, _x, _y, _w, _h, -1, 1.0);
                gpu_set_tex_filter(_filter);
            }
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
    
    static ZoneGetActive = function() {
        var _px = mng.mx - mng.x;
        var _py = mng.my - mng.y;
        var _active = "";
        var _z  = -1;
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x1 = _zone.x;
            var _y1 = _zone.y;
            var _x2 = _x1+_zone.w;
            var _y2 = _y1+_zone.h;
            if (point_in_rectangle(_px, _py, _x1, _y1, _x2, _y2)) {
                if (_zone.z > _z) {
                    _z = _zone.z;
                    _active = _zone.type;
                }
            }
        }
        return _active;
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
    
    static InputHandle = function(select, xDelta, yDelta) {
        if (xDelta < 0) ActionLeft();
        if (xDelta > 0) ActionRight();
        if (yDelta < 0) ActionUp();
        if (yDelta > 0) ActionDown();
        if (select)     ActionSelect();
        return true;
    }
    
    static OnEnter     = config[$ "OnEnter"] ?? function(){
        xSclAnim.Snap(0.8).Play(1);
        ySclAnim.Snap(0.8).Play(1);
    };
    static OnLeave     = config[$ "OnLeave"] ?? function(){
        
    };
    
    static GetWidth    = config[$ "GetWidth"] ?? function() {
        return string_width(name);
    }
    static GetHeight   = config[$ "GetHeight"] ?? function(){
        return string_height(name);
    };
}

#region Visual Nodes --------------------------

function MenuNodeText(id, name, config = {}) : MenuNode(id, name, config) constructor {
    interactive = false;
    background  = config[$ "background"];
    OnRender(function() {
        var _zone = flexZones[0];
        var _x = xPos + _zone.x;
        var _y = yPos + _zone.y;
        var _w = _zone.w;
        var _h = _zone.h;
        var _c = colors.disabled;
        
        // Background
        if !(is_undefined(background)) {
            if (asset_get_type(background) == asset_sprite) {
                draw_sprite_stretched_ext(background, 0, _x, _y, _zone.w, _zone.h, c_white, 1);
            }
            if (is_real(background)) {
                draw_sprite_stretched_ext(spr_pixel, 0, _x, _y, _zone.w, _zone.h, background, 1);
            }
        }
        
        // Name
        _y += _h/2
        scribble(name, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
    });
}

function MenuNodeSeparator(id, name = id, config = {}) : MenuNode(id, name, config) constructor {
    interactive = false;
    
    drawLine    = config[$ "drawLine"] ?? true;
    height      = config[$ "height"] ?? 4;
    width       = config[$ "width"] ?? 1;
    
    GetHeight   = function(){return height};
    GetWidth    = function(){return 0};
    
    OnRender(function() {
        if (!drawLine) exit;
        var _c = colors.base;
        var _zone = flexZones[0];
        draw_set_alpha(alpha);
        draw_rectangle_colour(_zone.x, _zone.y - height/2, _zone.x + _zone.w, _zone.y + height/2, _c, _c, _c, _c, false);
        draw_set_alpha(1);
    });
}

function MenuNodeSprite(id, name, sprite, config = {}) : MenuNode(id, name, config) constructor {
    
}

#endregion

#region Functional Nodes --------------------------

function MenuNodeButton(id, name, onSelect, config = {}) : MenuNode(id, name, config) constructor {
    
    if (is_callable(onSelect)) OnSelect(method(self, onSelect));
    
    OnSelect(function() {
        xSclAnim.Snap(1).Play(1.1);
        ySclAnim.Snap(1).Play(1.1);
    })
    
    OnRender(function() {
        var _zone = flexZones[0];
        var _x = xPos + _zone.x;
        var _y = yPos + _zone.y + _zone.h/2;
        var _c = focused ? colors.focused : colors.base;
        scribble(name, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
    });
}

function MenuNodeConfirm(id, name, onSelect, config = {}) : MenuNode(id, name, config) constructor {
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
        var _zone = flexZones[0];
        var _x = xPos + _zone.x;
        var _y = yPos + _zone.y + _zone.h/2;
        var _c = (focused ? (pending ? colors.pending : colors.focused) : colors.base);
        var _t = (pending ? msg : name);
        scribble(_t, id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
    });
}

function MenuNodeSelector(id, name, options, onChange, config = {}) : MenuNode(id, name, config) constructor {
    self.options    = options;
    self.cursor     = 0;
    cycle           = config[$ "cycle"] ?? true;
    
    OnChange = is_callable(onChange) ? method(self, onChange) : undefined;
    
    static OptionGetActive = function() {
        return options[cursor];
    }
    
    static ActionLeft = function() {
        var _len = array_length(options);
        if (cycle) {
            cursor = ((cursor - 1) % _len + _len) % _len;
        } else {
            cursor = max(0, cursor - 1);
        }
        if (is_callable(OnChange)) OnChange(OptionGetActive());
        xOffAnim.Snap(-16).Play(0);
    }
    static ActionRight = function() {
        var _len = array_length(options);
        if (cycle) {
            cursor = (cursor + 1) % _len;
        } else {
            cursor = min(_len - 1, cursor + 1);
        }
        if (is_callable(OnChange)) OnChange(OptionGetActive());
        xOffAnim.Snap(16).Play(0);
    }
    
    OnSelect(function(){
        switch (ZoneGetActive()) {
            case "LEFT": ActionLeft();  break;
            case "RIGHT": ActionRight(); break;
        }
    });
    
    OnRender(function() {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x = xPos + _zone.x;
            var _y = yPos + _zone.y + _zone.h/2;
            var _c = focused ? colors.focused : colors.base;
            var _t = "";
            var _h = 1;
            var _v = 1;
            switch (_zone.type) {
                case "BODY": {
                    _t = name;
                    _h = justify;
                    _v = 0;
                    _y -= _zone.h/2;
                } break;
                case "RIGHT": {
                    _t = ">";
                    _x += _zone.w/2;
                } break;
                case "LEFT": {
                    _t = "<";
                    _x += _zone.w/2;
                } break;
                case "VALUE": {
                    _x += _zone.w/2;
                    scribble(string(OptionGetActive()), id).align(hAlign, vAlign).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
                } break;
            }
        }
    });
}

#endregion

function MenuNodeCheckbox(id, name, onChange, config = {}) : MenuNode(id, name, config) constructor {
    value   = 0;
    
    OnChange = is_callable(onChange) ? method(self, onChange) : undefined;
    
    static ActionSelect = function() {
        value ^= 1;
        xSclAnim.Snap(1).Play(1.1);
        ySclAnim.Snap(1).Play(1.1);
    }
    
    OnSelect(function() {
        switch (ZoneGetActive()) {
            case "BOX": {
                ActionSelect();
            } break;
        }
    })
    
    OnRender(function() {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x = xPos + _zone.x;
            var _y = yPos + _zone.y + _zone.h/2;
            var _c = focused ? colors.focused : colors.base;
            var _t = "";
            var _h = 1;
            switch (_zone.type) {
                case "BODY": {
                    _t = name;
                    _h = justify;
                } break;
                case "BOX": {
                    _t = (value ? "[[  ]" : "[[X]");
                    _x += _zone.w/2;
                } break
            }
            scribble(_t, id).align(_h, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
        }
    });
}

/// @func MenuNodeSlider(id, name, get, set, min, max, step, format, [config])
function MenuNodeSlider(id, name, valueGet, valueSet, valueMin, valueMax, valueStep, valueFormat, config = {}) : MenuNode(id, name, config) constructor {
    value       = 0;
    dragging    = false;
    
    ValueGet    = method(self, valueGet);
    ValueSet    = method(self, valueSet);
    ValueFormat = method(self, valueFormat);
    
    self.valueMin   = valueMin;
    self.valueMax   = valueMax;
    self.valueStep  = valueStep
    
    
    OnSelect(function() {
        switch (ZoneGetActive()) {
            case "BAR": {
                // starts dragging untill mouse button is released
            } break;
        }
    })
    
    OnRender(function() {
        for (var i = 0, n = array_length(flexZones); i < n; i++) {
            var _zone = flexZones[i];
            var _x = xPos + _zone.x;
            var _y = yPos + _zone.y + _zone.h/2;
            var _w = _zone.w;
            var _h = _zone.h;
            var _c = focused ? colors.focused : colors.base;
            switch (_zone.type) {
                case "BODY": {
                    scribble(name, id).align(justify, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
                } break;
                case "VALUE": {
                    _x += _zone.w/2;
                    scribble(ValueFormat(value), id).align(justify, 1).blend(_c, alpha).transform(xScl, yScl, angle).draw(_x, _y);
                } break
                case "BAR": {
                    _x += _zone.w/2;
                    draw_rectangle(_x, _y, _x+_w, _y+_h, true)
                } break
            }
        }
    });
}





















