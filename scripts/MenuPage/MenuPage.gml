
function MenuPage(name, nodes, config = {}) constructor{
    // Passed
    self.name   = name;
    self.nodes  = nodes;
    
    // Public
    xPad    = config[$ "xPad"] ?? 32;
    yPad    = config[$ "yPad"] ?? 32;
    xMarg   = config[$ "xMarg"] ?? 32;
    yMarg   = config[$ "yMarg"] ?? 32;
    spacing = config[$ "spacing"] ?? 0;
    hAlign  = config[$ "hAlign"] ?? fa_center;
    vAlign  = config[$ "vAlign"] ?? fa_middle;
    cycle   = config[$ "cycle"] ?? true;
    enabled = config[$ "enabled"] ?? true;
    font    = config[$ "font"] ?? fnt_test;
    scale   = config[$ "scale"] ?? 1;
    
    // Private
    cursor  = 0;
    
    // Statics
    static NodeGetCurrent = function() {
        return nodes[cursor];
    }
    
    // Methods
    Update = config[$ "Update"] ?? function(){
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.Update(cursor == i);
        }
    };
   
    Render = config[$ "Render"] ?? function(ctx){
        
        // Page canvas
        var _pageCtx = {
           x:ctx.x + xPad, y:ctx.y + yPad,
           w:ctx.w - xPad*2, h:ctx.h - yPad*2,
        }
        
        // Node setup
        draw_set_font(font);
        
        // Node measuring
        var _nodeMaxW   = 0;
        var _nodeMaxH   = 0;
        var _totalH     = 0;
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _nodeMaxW = max(_nodeMaxW, _node.GetWidth() * scale);
            _nodeMaxH = max(_nodeMaxH, _node.GetHeight() * scale);
            _totalH  += _node.GetHeight() * scale + spacing * scale;
        }
        _totalH = max(0, _totalH - spacing);
        
        // Node alignment
        var _nodeX, _nodeY;
        switch (hAlign) {
            case fa_left:   _nodeX = _pageCtx.x; break;
            case fa_center: _nodeX = _pageCtx.x + (_pageCtx.w - _nodeMaxW) / 2; break;
            case fa_right:  _nodeX = _pageCtx.x + (_pageCtx.w - _nodeMaxW); break;
        }
        switch (vAlign) {
            case fa_top:    _nodeY = _pageCtx.y; break;
            case fa_middle: _nodeY = _pageCtx.y + (_pageCtx.h - _totalH) / 2; break;
            case fa_bottom: _nodeY = _pageCtx.y + (_pageCtx.h - _totalH); break;
        }
        
        // Node drawing
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node   = nodes[i];
            var _nodeH  = _node.GetHeight();
            var _nodeW  = _node.GetWidth();
            
            // Node canvas
            var _nodeCtx = {
                x: _nodeX, y: _nodeY,
                w: _nodeMaxW, h: _nodeH * scale,
                scale,
            }
            
            _node.Render(_nodeCtx);
            _nodeY += (_nodeH + spacing) * scale;
        }
        draw_set_font(-1);
    };
    
    // Pushing this page on the stack
    OnEnter = config[$ "OnEnter"] ?? function(){
        static callback = function(node, i){node.OnEnter()};
        array_foreach(nodes, callback);
    };
    
    // Poping this page from the stack
    OnLeave = config[$ "OnLeave"] ?? function(){
        cursor = 0;
        static callback = function(node, i){node.OnLeave()};
        array_foreach(nodes, callback);
    };
    
    // Coming back from another page
    OnReveal = config[$ "OnReveal"] ?? function() {
        static callback = function(node, i){node.OnReveal()};
        array_foreach(nodes, callback);
    }
    
    // Pushing another page into the stack
    OnSuspend = config[$ "OnSuspend"] ?? function() {
        static callback = function(node, i){node.OnSuspend()};
        array_foreach(nodes, callback);
    }
}