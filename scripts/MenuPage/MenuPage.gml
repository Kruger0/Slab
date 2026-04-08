
function MenuPage(name, nodes, config = {}) constructor{
    self.name   = name;
    self.nodes  = nodes;
    
    #region Public
    xPad    = config[$ "xPad"] ?? 32;
    yPad    = config[$ "yPad"] ?? 32;
    xMarg   = config[$ "xMarg"] ?? 32;
    yMarg   = config[$ "yMarg"] ?? 32;
    xFactor = config[$ "xFactor"] ?? 0;
    yFactor = config[$ "yFactor"] ?? 0;
    spacing = config[$ "spacing"] ?? 8;
    hAlign  = config[$ "hAlign"] ?? fa_center;
    vAlign  = config[$ "vAlign"] ?? fa_middle;
    cycle   = config[$ "cycle"] ?? true;
    hFill   = config[$ "hFill"] ?? true;
    vFill   = config[$ "vFill"] ?? true;
    enabled = config[$ "enabled"] ?? true;
    font    = config[$ "font"] ?? fnt_test;
    scale   = config[$ "scale"] ?? 1;
    #endregion
    
    #region Private
    cursor  = 0;
    #endregion
    
    // Methods
    static NodeGetActive = function() {
        return nodes[cursor];
    }
    
    static CursorFindFirst = function() {
        var _count = array_length(nodes);
        var _guard = 0;
        while (!nodes[cursor].interactive && _guard < _count) {
            cursor++;
            _guard++;
        }
    }
    
    static OnEnter = function(){
        CursorFindFirst();
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.OnEnter();
            _node.mng = mng;
        }
    };
    static OnLeave = function(resetCursor){
        if (resetCursor) cursor = 0;
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.OnLeave();
        }
    };
    
    static Update = function(useMouse){
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.Update(useMouse ? undefined : (cursor == i));
        }
    };
    static Render = function(ctx){
        
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
            _nodeMaxW = max(_nodeMaxW, _node.GetWidth());
            _nodeMaxH = max(_nodeMaxH, _node.GetHeight());
            _totalH  += _node.GetHeight() + spacing;
        }
        _totalH = max(0, _totalH - spacing);
        
        var _scaledMaxW = _nodeMaxW * scale;
        var _scaledTotalH = _totalH * scale;
        
        // Node alignment
        var _nodeX, _nodeY;
        switch (hAlign) {
            case fa_left:   _nodeX = _pageCtx.x; break;
            case fa_center: _nodeX = _pageCtx.x + (_pageCtx.w - _scaledMaxW) / 2; break;
            case fa_right:  _nodeX = _pageCtx.x + (_pageCtx.w - _scaledMaxW); break;
        }
        switch (vAlign) {
            case fa_top:    _nodeY = _pageCtx.y; break;
            case fa_middle: _nodeY = _pageCtx.y + (_pageCtx.h - _scaledTotalH) / 2; break;
            case fa_bottom: _nodeY = _pageCtx.y + (_pageCtx.h - _scaledTotalH); break;
        }
        
        // Node drawing
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node   = nodes[i];
            var _nodeH  = _node.GetHeight();
            var _nodeW  = _node.GetWidth();
            
            // Node canvas
            var _nodeCtx = {
                x: _nodeX, y: _nodeY,
                w: _nodeMaxW, h: _nodeH,
                scale,
            }
            
            _node.Render(_nodeCtx);
            _nodeY += (_nodeH + spacing) * scale;
        }
        draw_set_font(-1);
    };
}
