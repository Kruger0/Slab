
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
    colors      = config[$ "colors"] ?? {base: #FFFFFF, focused: #FFFF00};
    enabled     = config[$ "enabled"] ?? true;
    
    // Private
    isFocused   = false;
    xOff        = new AnimTrack(ac_test, "xOff", 0.3);
    yOff        = new AnimTrack(ac_test, "yOff", 0.3);
    
    // Methods
    SetFocused = function(isFocused) {
        if (self.isFocused == isFocused) exit;
        self.isFocused = isFocused;
        xOff.Play(isFocused ? 16 : 0);
    }
    
    Reset = function() {
        isFocused = false;
        xOff.Snap(0);
        yOff.Snap(0);
    }
    
    Update = config[$ "Update"] ?? function(){
        var _dt = delta_time / 1000000;
        xOff.Update(_dt);
        yOff.Update(_dt);
    };
    
    Render = config[$ "Render"] ?? function(_ctx){
        if (isFocused) {
            draw_rectangle(_ctx.x, _ctx.y, _ctx.x+_ctx.w, _ctx.y+_ctx.h, true);
        }
        
        var _x = _ctx.x + xOff.GetValue();
        var _y = _ctx.y + yOff.GetValue() + (_ctx.h / 2);
        var _c = isFocused ? colors.focused : colors.base;
        
        draw_set_valign(fa_middle);
        draw_text_colour(_x, _y, name, _c, _c, _c, _c, 1);
    };
    
    OnEnter = config[$ "OnEnter"] ?? function(){};
    
    OnLeave = config[$ "OnLeave"] ?? function(){};
    
    OnSelect = config[$ "OnSelect"] ?? function(){};

    GetWidth = config[$ "GetWidth"] ?? function() {
        return string_width(name);
    }
    
    GetHeight = config[$ "GetHeight"] ?? function(){
        return string_height(name);
    };
}

function MenuNodeButton(name, onSelect) : MenuNode(name) constructor {
    OnSelect = onSelect ?? function(){};
}

function MenuNodeToggle(name) : MenuNode(name) constructor {
    
}

function MenuNodeSlider(name) : MenuNode(name) constructor {
    
}

function MenuNodeSelector(name) : MenuNode(name) constructor {
    
}