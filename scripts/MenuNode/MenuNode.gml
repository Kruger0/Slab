

function MenuNode(name, config = {}) constructor{
    self.name   = name;
    
    #region Public
    colors      = config[$ "colors"] ?? {
        base        : #FFFFFF,
        focused     : #FFFF00,
        pending     : #FF0000,
        disabled    : #606060
    };
    alpha       = config[$ "alpha"] ?? 1;
    enabled     = config[$ "enabled"] ?? true;
    hAlign      = config[$ "hAlign"] ?? fa_center;
    vAlign      = config[$ "vAlign"] ?? fa_middle;
    animSpeed   = config[$ "animSpeed"] ?? 0.5;
    #endregion
    
    #region Private
    isFocused   = false;
    interactive = true;
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
    
    zones       = [];
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
    
    static Update = function(isFocused){
        // Input
        if (!is_undefined(isFocused)) SetFocused(isFocused);
        
        // Animation
        xOffAnim.Update();
        yOffAnim.Update();
        xSclAnim.Update();
        ySclAnim.Update();
        
        // Custom
        for (var i = 0, n = array_length(onUpdateCb); i < n; i++) {
            var _entry = onUpdateCb[i];
            _entry.callback(_entry.data);
        }
    }
    static Render = function(ctx) {
        UpdateLayout(ctx);
        
        // Custom
        for (var i = 0, n = array_length(onRenderCb); i < n; i++) {
            var _entry = onRenderCb[i];
            _entry.callback(_entry.data);
        }
        
        // Debug
        if (global.debug) {
            var _activeZone = ZoneGetActive();
            for (var i = 0, n = array_length(zones); i < n; i++) {
                var _z = zones[i];
                var _c = (_activeZone == _z.name ? #00FF00 : #0000FF)
                draw_rectangle_color(_z.x, _z.y, _z.x + _z.w, _z.y + _z.h, _c, _c, _c, _c, true);
            }
            draw_circle_color(xPos, yPos, 2, c_red, c_red, false);
            draw_text(xPos + 100, yPos, _activeZone);
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
    
    static UpdateLayout = function(ctx) {
        switch (hAlign) {
            case fa_left:   xPos = ctx.x; break;
            case fa_center: xPos = ctx.x + (ctx.w / 2) * ctx.scale; break;
            case fa_right:  xPos = ctx.x + ctx.w * ctx.scale; break;
        }
        switch (vAlign) {
            case fa_top:    yPos = ctx.y; break;
            case fa_middle: yPos = ctx.y + (ctx.h / 2) * ctx.scale; break;
            case fa_bottom: yPos = ctx.y + ctx.h * ctx.scale; break;
        }
        xPos += xOffAnim.GetValue();
        yPos += yOffAnim.GetValue();
        xScl  = xSclAnim.GetValue() * ctx.scale;
        yScl  = ySclAnim.GetValue() * ctx.scale;
        
        // Base zone — subclasses will override or extend this
        zones = [
            {
                name: "body",
                layer : 0,
                x: ctx.x,
                y: ctx.y,
                w: ctx.w * ctx.scale,
                h: ctx.h * ctx.scale,
            },
            {
                name: "arrowLeft",
                layer : 1,
                x: ctx.x,
                y: ctx.y,
                w: ctx.w*0.2 * ctx.scale,
                h: ctx.h * ctx.scale,
            },
            {
                name: "arrowRight",
                layer : 1,
                x: ctx.x + ctx.w*0.8,
                y: ctx.y,
                w: ctx.w*0.2 * ctx.scale,
                h: ctx.h * ctx.scale,
            },
        ];
    }
    
    static ContainsPoint = function(px, py) {
        for (var i = 0, n = array_length(zones); i < n; i++) {
            var _z = zones[i];
            if (point_in_rectangle(px, py, _z.x, _z.y, _z.x + _z.w, _z.y + _z.h)) {
                return true;
            }
        }
        return false;
    }
    
    static ZoneGetActive = function() {
        var _mx = mng.mx - mng.x;
        var _my = mng.my - mng.y;
        var _active = "";
        var _layer  = -1;
        for (var i = 0, n = array_length(zones); i < n; i++) {
            var _z = zones[i];
            if (point_in_rectangle(_mx, _my, _z.x, _z.y, _z.x + _z.w, _z.y + _z.h)) {
                if (_z.layer > _layer) {
                    _layer = _z.layer;
                    _active = _z.name;
                }
            }
        }
        return _active;
    }
    
    static SetFocused = function(focused) {
        if (self.isFocused == focused) exit;
        self.isFocused = focused;
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
    
    static InputHandle = function(select, xDelta, yDelta) {
        if (xDelta < 0) ActionLeft();
        if (xDelta > 0) ActionRight();
        if (yDelta < 0) ActionUp();
        if (yDelta > 0) ActionDown();
        if (select) Select();
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

function MenuNodeLabel(name, config = {}) : MenuNode(name, config) constructor {
    interactive = false;
    
    OnRender(function() {
        var _c = colors.disabled;
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, _c, _c, _c, _c, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    });
}

function MenuNodeSeparator(config = {}) : MenuNode("separator", config) constructor {
    interactive = false;
    
    drawLine    = config[$ "drawLine"] ?? true;
    height      = config[$ "height"] ?? 4;
    width       = config[$ "width"] ?? 1;
    
    GetHeight   = function(){return height};
    GetWidth    = function(){return 0};
    
    OnRender(function() {
        if (!drawLine) exit;
        var _y = yPos;
        var _c = colors.base;
        var _z = zones[0];
        draw_set_alpha(alpha);
        draw_rectangle_colour(_z.x, _y - height/2, _z.x + _z.w, _y + height/2, _c, _c, _c, _c, false);
        draw_set_alpha(1);
    });
}

function MenuNodeSameLine(config = {}) : MenuNode("sameLine", config) constructor {
    
}

#endregion

#region Functional Nodes --------------------------

function MenuNodeButton(name, onSelect, config = {}) : MenuNode(name, config) constructor {
    
    if (is_callable(onSelect)) OnSelect(method(self, onSelect));
    
    OnSelect(function() {
        xSclAnim.Snap(1).Play(1.1);
        ySclAnim.Snap(1).Play(1.1);
    })
    
    OnRender(function() {
        var _c = isFocused ? colors.focused : colors.base;
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, _c, _c, _c, _c, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

function MenuNodeConfirm(name, onSelect, config = {}) : MenuNode(name, config) constructor {
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
        var _c = isFocused ? (pending ? colors.pending : colors.focused) : colors.base;
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, pending ? msg : name, xScl, yScl, angle, _c, _c, _c, _c, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

function MenuNodeSelector(name, options, onChange, config = {}) : MenuNode(name, config) constructor {
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
        xOffAnim.Snap(-6).Play(0);
    }
    static ActionRight = function() {
        var _len = array_length(options);
        if (cycle) {
            cursor = (cursor + 1) % _len;
        } else {
            cursor = min(_len - 1, cursor + 1);
        }
        if (is_callable(OnChange)) OnChange(OptionGetActive());
        xOffAnim.Snap(6).Play(0);
    }
    
    OnSelect(function(){
        switch (ZoneGetActive()) {
            case "arrowLeft": ActionLeft();  break;
            case "arrowRight": ActionRight(); break;
        }
    });
    
    OnRender(function() {
        var _c = isFocused ? colors.focused : colors.base;
        draw_set_halign(fa_left);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, _c, _c, _c, _c, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

#endregion

// WIP --------------------------

function MenuNodeToggle(name) : MenuNode(name) constructor {
    OnRender(function() {
        var _c = isFocused ? colors.focused : colors.base;
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, _c, _c, _c, _c, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

function MenuNodeSlider(name) : MenuNode(name) constructor {
    OnRender(function() {
        var _c = isFocused ? colors.focused : colors.base;
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, _c, _c, _c, _c, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

