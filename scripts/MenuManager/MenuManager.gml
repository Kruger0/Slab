
function MenuManager(config = {}) constructor{
    // Private
    stack       = [];
    pages       = {};
    x           = 0; 
    y           = 0;
    w           = 0;
    h           = 0;
    mx          = 0;
    my          = 0;
    useMouse    = false;
    
    // Statics
    static Update = function(x, y, w, h, mx, my) {
        
        #region Update menu context area
        self.x  = x;
        self.y  = y;
        self.w  = w;
        self.h  = h;
        self.mx = mx;
        self.my = my;
        #endregion
        
        #region Fetch Inputs
        var _xDelta         = useMouse ? 0 : InputOpposingPressed(INPUT_VERB.LEFT, INPUT_VERB.RIGHT);
        var _yDelta         = useMouse ? 0 : InputOpposingPressed(INPUT_VERB.UP, INPUT_VERB.DOWN);
        var _inputSelect    = useMouse ? 0 : InputPressed(INPUT_VERB.ACCEPT);
        var _inputBack      = InputPressed(INPUT_VERB.CANCEL);
        var _mousePress     = InputMousePressed(mb_left);
        #endregion
        
        var _page  = PageGetActive();
        if (is_undefined(_page)) return;
        var _count = array_length(_page.nodes);
        var _mouseFocus = -1;
        
        var _useMouse = useMouse;
        if (InputMouseMoved()) useMouse = true;
        if (InputCheckMany(-1, -1)) useMouse = false;
        
        if (useMouse && !_useMouse) {
            for (var i = 0; i < _count; i++) _page.nodes[i].SetFocused(false);
        }
        
        // Hover & Cursor
        if (useMouse) {
            for (var i = 0; i < _count; i++) {
                var _node = _page.nodes[i];
                var _isOver = _node.ContainsPoint(mx - x, my - y);
                if (_isOver && !_node.interactive) {
                    _node.mouseOver = false;
                    continue;
                }
                if (_isOver && !_node.mouseOver) _node.OnMouseEnter();
                if (!_isOver && _node.mouseOver) _node.OnMouseLeave();
                _node.mouseOver = _isOver;
                if (_isOver) _mouseFocus = i;
            }
            if (_mouseFocus != -1) _page.cursor = _mouseFocus;
        } else {
            if (_yDelta != 0) {
                var _next = _page.cursor;
                var _guard = 0;
                do {
                    _next += _yDelta;
                    if (_page.cycle) {
                        _next = ((_next % _count) + _count) % _count;
                    } else {
                        _next = clamp(_next, 0, _count - 1);
                    }
                    _guard++;
                } until (_page.nodes[_next].interactive || _guard >= _count);
                _page.cursor = _next;
            }
        }
        
        _page.Update(useMouse);
        var _node = _page.NodeGetActive();
        
        // Select & Zones
        if (_node.interactive) {
            if (useMouse) {
                if (_mouseFocus != -1) {
                    _node.UpdateHoveredZone(mx - x, my - y);
                    if (_mousePress) _node.Select(self);
                }
            } else {
                if (_inputSelect) _node.Select(self);
            }
        }
        
        // Back
        if (_inputBack) PagePop();
    }
    
    static Render = function() {
        var _ctx = {x, y, w, h};
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        _page.Render(_ctx);
        if (global.debug) {
            draw_circle_color(mx, my, 2, c_lime, c_lime, false);
        }
    }
    
    static PageGetActive = function() {
        var _page = array_last(stack);
        return pages[$ _page];
    }
    
    static PageAdd = function(page) {
        pages[$ page.name] = page;
    }
    
    static PagePush = function(page) {
        var _pageCurr = PageGetActive();
        if !(is_undefined(_pageCurr)) _pageCurr.OnSuspend();
        array_push(stack, page);
        var _pageNext = PageGetActive();
        if !(is_undefined(_pageNext)) _pageNext.OnEnter();
    }
    
    static PagePop = function() {
        if (array_length(stack) <= 1) return;
        var _pageCurr = PageGetActive();
        if (is_undefined(_pageCurr)) return;
        _pageCurr.OnLeave();
        array_pop(stack);
        var _pageNext = PageGetActive();
        if (is_undefined(_pageNext)) return;
        _pageNext.OnReveal();
    }
}

global.menuTest = new MenuManager();
global.menuTest.PageAdd(new MenuPage("menu_main", [
    new MenuNodeLabel("SUPER FUN MENU SYSTEM"),
    new MenuNodeButton("ui_playGame"),
    new MenuNodeButton("ui_continue"),
    new MenuNodeButton("ui_options", function(mng){mng.PagePush("menu_options")}),
    new MenuNodeButton("ui_credits"),
    new MenuNodeButton("ui_exit", function(){game_end()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_options", [
    new MenuNodeLabel("OPTIONS"),
    new MenuNodeSelector("ui_language"),
    new MenuNodeButton("ui_audio", function(mng){mng.PagePush("menu_audio")}),
    new MenuNodeButton("ui_video", function(mng){mng.PagePush("menu_video")}),
    new MenuNodeButton("ui_back", function(mng){mng.PagePop()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_audio", [
    new MenuNodeLabel("AUDIO"),
    new MenuNodeSlider("ui_volume_master"),
    new MenuNodeSlider("ui_volume_music"),
    new MenuNodeSlider("ui_volume_sfx"),
    new MenuNodeButton("ui_back", function(mng){mng.PagePop()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_video", [
    new MenuNodeLabel("VIDEO"),
    new MenuNodeToggle("ui_fullscreen"),
    new MenuNodeSelector("ui_resolution"),
    new MenuNodeToggle("ui_bloom"),
    new MenuNodeToggle("ui_vsync"),
    new MenuNodeButton("ui_back", function(mng){mng.PagePop()}),
]))

global.menuTest.PagePush("menu_main");
