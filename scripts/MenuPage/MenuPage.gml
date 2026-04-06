
function MenuPage(name, nodes, config = {}) constructor{
    // Passed
    self.name   = name;
    self.nodes  = nodes;
    
    // Public
    xPad    = config[$ "xPad"] ?? 32;
    yPad    = config[$ "yPad"] ?? 32;
    spacing = config[$ "spacing"] ?? 8;
    alig    = config[$ "alig"] ?? 0; // WIP
    cycle   = config[$ "cycle"] ?? true;
    enabled = config[$ "enabled"] ?? true;
    
    // Private
    cursor      = 0;
    
    // Statics
    static NodeGetCurrent = function() {
        return nodes[cursor];
    }
    
    // Methods
    Update = config[$ "Update"] ?? function(){
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.Update();
        }
    };
   
    Render = config[$ "Render"] ?? function(ctx){
        // Calculates own position
        var _pageCtx = {
           x:ctx.x + xPad, y:ctx.y + yPad,
           w:ctx.w - xPad*2, h:ctx.h - yPad*2
        }
        
        // Loop each node
        var _nodeY = _pageCtx.y;
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node   = nodes[i];
            var _nodeH  = _node.GetHeight();
            var _nodeW  = _node.GetWidth();
            _node.SetFocused(cursor == i);
            
            var _nodeCtx = {
                x: _pageCtx.x, y: _nodeY,
                w: _pageCtx.w, h: _nodeH,
            }
            
            _node.Render(_nodeCtx);
            _nodeY += _nodeH + spacing;
        }
    };
    
    OnEnter = config[$ "OnEnter"] ?? function(){};
    
    OnLeave = config[$ "OnLeave"] ?? function(){
        cursor = 0;
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.Reset();
        }
    };
    
    OnReveal = config[$ "OnReveal"] ?? function() {
        
    }
    
    OnSuspend = config[$ "OnSuspend"] ?? function() {
        
    }
}