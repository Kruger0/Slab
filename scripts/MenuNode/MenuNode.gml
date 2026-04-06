
function AnimTrack(curve, channel, duration) constructor {
    self.channel  = animcurve_get_channel(curve, channel);
    self.duration = duration;
    posx          = 0;
    playing       = false;
    currValue     = 0;
    targetValue   = 0;
    startValue    = 0;

    static Play = function(to) {
        if (targetValue == to && playing) exit;  // already going there
        startValue  = currValue;
        targetValue = to;
        posx        = 0;
        playing     = true;
    }
    static Snap = function(to) {
        startValue  = to;
        targetValue = to;
        currValue   = to;
        posx        = 1;
        playing     = false;
    }
    static Update = function(dt) {
        if (!playing) exit;
        posx      = clamp(posx + dt / duration, 0, 1);
        var _t    = animcurve_channel_evaluate(channel, posx);
        currValue = lerp(startValue, targetValue, _t);
        playing   = (posx < 1);
    }
    static GetValue = function() {
        return currValue;
    }
}

function MenuNode(name, config = {}) constructor{
    // Passed
    self.name   = name;
    
    // Public
    colors      = config[$ "colors"] ?? {base: #FFFFFF, focused: #FFFF00, confirm : #FF0000, disabled : #606060};
    enabled     = config[$ "enabled"] ?? true;
    hAlign      = config[$ "hAlign"] ?? fa_center;
    vAlign      = config[$ "vAlign"] ?? fa_middle;
    
    // Private
    isFocused   = false;
    color       = colors.base;
    alpha       = 1;
    angle       = 0;
    xPos        = 0;
    yPos        = 0;
    xScl        = 1;
    yScl        = 1;
    xOffAnim    = new AnimTrack(ac_test, "xOff", 0.5);
    yOffAnim    = new AnimTrack(ac_test, "yOff", 0.5);
    xSclAnim    = new AnimTrack(ac_test, "xScl", 0.5);
    ySclAnim    = new AnimTrack(ac_test, "yScl", 0.5);
    onUpdateCb  = [];
    onRenderCb  = [];
    onSelectCb  = [];
    
    // Statics
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
        SetFocused(isFocused);
        
        // Animation
        var _dt = delta_time / 1000000;
        xOffAnim.Update(_dt);
        yOffAnim.Update(_dt);
        xSclAnim.Update(_dt);
        ySclAnim.Update(_dt);
        
        // Custom
        for (var i = 0, n = array_length(onUpdateCb); i < n; i++) {
            var _entry = onUpdateCb[i];
            _entry.callback(_entry.data);
        }
    }
    
    static Render = function(ctx) {
        // Selector
        if (isFocused) {
            draw_rectangle(ctx.x, ctx.y, ctx.x+ctx.w, ctx.y+ctx.h, true);
        }
        
        // Style
        switch (hAlign) {
            case fa_left:   xPos = ctx.x + xOffAnim.GetValue() * ctx.scale; break;
            case fa_center: xPos = ctx.x + xOffAnim.GetValue() + (ctx.w / 2) * ctx.scale; break;
            case fa_right:  xPos = ctx.x + xOffAnim.GetValue() + ctx.w * ctx.scale; break;
        }
        switch (vAlign) {
            case fa_top:    yPos = ctx.y + yOffAnim.GetValue() * ctx.scale; break;
            case fa_middle: yPos = ctx.y + yOffAnim.GetValue() + (ctx.h / 2)* ctx.scale; break;
            case fa_bottom: yPos = ctx.y + yOffAnim.GetValue() + ctx.h * ctx.scale; break;
        }
        xScl    = xSclAnim.GetValue() * ctx.scale;
        yScl    = ySclAnim.GetValue() * ctx.scale;
        color   = isFocused ? colors.focused : colors.base;
        
        // Custom
        for (var i = 0, n = array_length(onRenderCb); i < n; i++) {
            var _entry = onRenderCb[i];
            _entry.callback(_entry.data);
        }
        
        // Debug
        draw_circle_color(xPos, yPos, 2, c_red, c_red, false);
    }
    
    static Select = function(mng) {
        // Custom
        for (var i = 0, n = array_length(onSelectCb); i < n; i++) {
            var _entry = onSelectCb[i];
            _entry.callback(mng); // TODO pass this or data?
        }
    }
    
    // Methods
    SetFocused = function(isFocused) {
        if (self.isFocused == isFocused) exit;
        self.isFocused = isFocused;
        xOffAnim.Play(isFocused ? 0 : 0);
        yOffAnim.Play(isFocused ? 0 : 0);
        xSclAnim.Play(isFocused ? 1.2 : 1);
        ySclAnim.Play(isFocused ? 1.2 : 1);
    }
    
    OnEnter = config[$ "OnEnter"] ?? function(){
        xSclAnim.Snap(1);
        ySclAnim.Snap(1);
    };
    
    OnLeave = config[$ "OnLeave"] ?? function(){
        isFocused = false;
        xOffAnim.Snap(0);
        yOffAnim.Snap(0);
        xSclAnim.Snap(1);
        ySclAnim.Snap(1);
    };
    
    OnReveal = config[$ "OnReveal"] ?? function() {
        xSclAnim.Snap(1);
        ySclAnim.Snap(1);
    }
    
    OnSuspend = config[$ "OnSuspend"] ?? function() {
        isFocused = false;
        xOffAnim.Snap(0);
        yOffAnim.Snap(0);
        xSclAnim.Snap(1);
        ySclAnim.Snap(1);
    }
    
    GetWidth = config[$ "GetWidth"] ?? function() {
        return string_width(name);
    }
    
    GetHeight = config[$ "GetHeight"] ?? function(){
        return string_height(name);
    };
}

function MenuNodeButton(name, onSelect = function(){}, config = {}) : MenuNode(name, config) constructor {
    OnSelect(function() {
        xSclAnim.Snap(1);
        ySclAnim.Snap(1);
        xSclAnim.Play(1.2);
        ySclAnim.Play(1.2);
    })
    OnSelect(onSelect);
    
    OnRender(function() {
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, color, color, color, color, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

//function MenuNodeConfirmButton(name, onSelect, config = {}) : MenuNode(name, config) constructor {

//    confirmText  = config[$ "confirmText"] ?? "> ARE YOU SURE? <";
//    confirmColor = config[$ "confirmColor"] ?? c_red;
    
//    // Internal State
//    isConfirming = false;
    
//    // Bind the actual final action
//    Action = !is_undefined(onSelect) ? method(self, onSelect) : function(){};
    
//    // 1. The Logic Override
//    OnSelect = function(mng) {
//        if (!isConfirming) {
//            // First press: Enter confirm mode
//            isConfirming = true;
//            xScl.Play(1.3); // Optional: Give it a visual "pop" to warn the user
//        } else {
//            // Second press: Execute and reset
//            Action(mng);
//            isConfirming = false;
//        }
//    };
    
//    // 2. The Safety Net Override
//    var _baseUpdate = Update; // Store the parent's Update function
//    Update = function(_isFocused) {
//        // If the user gets scared and moves the cursor away, CANCEL the confirmation
//        if (self.isFocused && !_isFocused && isConfirming) {
//            isConfirming = false;
//        }
        
//        // Run the parent's normal update logic (animations, etc.)
//        _baseUpdate(_isFocused); 
//    };
    
//    // 3. The Visuals Override
//    var _baseRender = Render; // Store the parent's Render function
//    Render = function(_ctx) {
//        // Temporarily hijack the name and color
//        var _originalName = name;
//        var _originalColor = colors.focused;
        
//        if (isConfirming) {
//            name = confirmText;
//            colors.focused = confirmColor;
//        }
        
//        // Let the parent do the heavy lifting of drawing everything
//        _baseRender(_ctx); 
        
//        // Restore the original values so we don't permanently alter the node
//        if (isConfirming) {
//            name = _originalName;
//            colors.focused = _originalColor;
//        }
//    };
//}

function MenuNodeToggle(name) : MenuNode(name) constructor {
    OnRender(function() {
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, color, color, color, color, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

function MenuNodeSlider(name) : MenuNode(name) constructor {
    OnRender(function() {
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, color, color, color, color, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}

function MenuNodeSelector(name) : MenuNode(name) constructor {
    OnRender(function() {
        draw_set_halign(hAlign);
        draw_set_valign(vAlign);
        draw_text_transformed_color(xPos, yPos, name, xScl, yScl, angle, color, color, color, color, alpha);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    })
}