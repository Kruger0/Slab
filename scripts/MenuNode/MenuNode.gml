
function MenuNode(name, config = {}) constructor{
    // Passed
    self.name   = name;
    
    // Public
    colors      = config[$ "colors"] ?? {base: #FFFFFF, focused: #FFFF00};
    enabled     = config[$ "enabled"] ?? true;
    
    // Private
    isFocused   = false;
    color       = colors.base;
    anim        = {
        curveId : ac_test,
        value   : 0,
        xOff    : 0,
        yOff    : 0,
        xTarg   : 0,
        yTarg   : 0,
    }
    
    // Statics
    static SetFocused = function(isFocused) {
        if (isFocused) {
            color = colors.focused;
            self.isFocused = true;
            anim.xTarg = 16;
        } else {
            color = colors.base;
            self.isFocused = false
            anim.xTarg = 0;
        }
    }
    
    static Reset = function() {
        anim = {
            value   : 0,
            speed   : 0.1,
            xOff    : 0,
            yOff    : 0,
            xTarg   : 0,
            yTarg   : 0,
        }
    }
    
    // Methods
    OnEnter = config[$ "OnEnter"] ?? function(){};
    
    OnLeave = config[$ "OnLeave"] ?? function(){};
    
    OnSelect = config[$ "OnSelect"] ?? function(){};
    
    Update = config[$ "Update"] ?? function(){
        with (anim) {
            xOff = lerp(xOff, xTarg, speed);
            yOff = lerp(yOff, yTarg, speed);
        }
    };
    
    Render = config[$ "Render"] ?? function(_ctx){
        if (isFocused) {
            draw_rectangle(_ctx.x, _ctx.y, _ctx.x+_ctx.w, _ctx.y+_ctx.h, true);
        }
        
        var _x = _ctx.x + anim.xOff;
        var _y = _ctx.y + anim.yOff + (_ctx.h / 2);
        var _c = color;
        
        draw_set_valign(fa_middle);
        draw_text_colour(_x, _y, name, _c, _c, _c, _c, 1);
    };
    
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