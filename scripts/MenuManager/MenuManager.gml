
function MenuManager(config = {}) constructor{
    
    // Private
    __ = {};
    with (__) {
        stack       = [];
        pages       = {};
        mx          = 0;
        my          = 0;
        useMouse    = false;
        mouseFocus  = -1;
        
        static __InputMethod = function() {
            return {
                xDelta              : InputOpposingPressed(INPUT_VERB.LEFT, INPUT_VERB.RIGHT),
                yDelta              : InputOpposingPressed(INPUT_VERB.UP, INPUT_VERB.DOWN),
                                    
                selectPressed       : InputPressed(INPUT_VERB.ACCEPT),
                selectCheck         : InputCheck(INPUT_VERB.ACCEPT),
                selectReleased      : InputReleased(INPUT_VERB.ACCEPT),
                                    
                backPressed         : InputPressed(INPUT_VERB.CANCEL),
                backCheck           : InputCheck(INPUT_VERB.CANCEL),
                backReleased        : InputReleased(INPUT_VERB.CANCEL),
                
                mouseRightPressed   : InputMousePressed(mb_left),
                mouseRightCheck     : InputMouseCheck(mb_left),
                mouseRightReleased  : InputMouseReleased(mb_left),
                
                mouseLeftPressed    : InputMousePressed(mb_left),
                mouseLeftCheck      : InputMouseCheck(mb_left),
                mouseLeftReleased   : InputMouseReleased(mb_left),
            }
        }
    }
    
    // Public
    static Update = function(mx, my) {
        __.mx = mx;
        __.my = my;
        
        #region Fetch Inputs
        var _input          = __InputMethod();
        var _xDelta         = __.useMouse ? 0 : _input.xDelta;
        var _yDelta         = __.useMouse ? 0 : _input.yDelta;
        var _inputSelect    = __.useMouse ? 0 : _input.selectPressed;
        
        var _mousePressed   = _input.mouseLeftPressed;
        var _mouseCheck     = _input.mouseLeftCheck;
        var _mouseRelease   = _input.mouseLeftReleased;
        #endregion
        
        var _page  = PageGetActive();
        if (is_undefined(_page)) return;
        var _count = array_length(_page.nodes);
        __.mouseFocus = -1;
        
        var _useMouse = __.useMouse;
        if (InputMouseMoved()) __.useMouse = true;
        if (InputCheckMany(-1, -1)) __.useMouse = false;
        
        // Mouse state has changed in this frame
        if (__.useMouse && !_useMouse) {
            for (var i = 0; i < _count; i++) _page.nodes[i].SetFocused(false);
        }
        
        // Hover & Cursor
        if (__.useMouse) {
            for (var i = 0; i < _count; i++) {
                var _node = _page.nodes[i];
                var _isOver = _node.ContainsPoint(__.mx, __.my);
                if (_isOver && !_node.interactive) {
                    _node.focused = false;
                    continue;
                }
                if (_isOver && !_node.focused) _node.SetFocused(true);
                if (!_isOver && _node.focused) _node.SetFocused(false);
                if (_isOver) __.mouseFocus = i;
            }
            if (__.mouseFocus != -1) _page.__.cursor = __.mouseFocus;
        } else {
            if (_yDelta != 0) {
                var _next = _page.__.cursor;
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
                _page.__.cursor = _next;
            }
        }
        
        _page.Update(__.useMouse);
        var _node = _page.NodeGetActive();
        
        // Select & Zones
        if (_node.interactive) {
            if (__.useMouse) {
                if (__.mouseFocus != -1) {
                    if (_mousePressed) _node.Select();
                }
            } else {
                // TODO yDelta actions will requires node focus locking in the future
                if (_inputSelect || _xDelta != 0 || _yDelta != 0) {
                    if (!_node.InputHandle(_inputSelect, _xDelta, _yDelta)) {
                        // Same line nodes logic goes here
                    }
                }
            }
        }
        
        // Back
        if (_input.backPressed) PagePop();
        
        // Cleanup
        delete _input;
    }
    static Render = function() {
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        _page.Render();
        if (global.debug) {
            var _c = #FF00FF
            draw_circle_color(__.mx, __.my, 2, _c, _c, false);
            draw_circle_color(__.mx, __.my, 6, _c, _c, true);
        }
    }
    
    static PageGetActive = function() {
        var _page = array_last(__.stack);
        return __.pages[$ _page];
    }
    static PageAdd = function(page) {
        __.pages[$ page.name] = page;
        __.pages[$ page.name].mng = self;
    }
    static PagePush = function(page) {
        var _pageCurr = PageGetActive();
        if !(is_undefined(_pageCurr)) _pageCurr.OnLeave(false);
        array_push(__.stack, page);
        var _pageNext = PageGetActive();
        if !(is_undefined(_pageNext)) _pageNext.OnEnter();
    }
    static PagePop = function() {
        if (array_length(__.stack) <= 1) return;
        var _pageCurr = PageGetActive();
        if (is_undefined(_pageCurr)) return;
        _pageCurr.OnLeave(true);
        array_pop(__.stack);
        var _pageNext = PageGetActive();
        if (is_undefined(_pageNext)) return;
        _pageNext.OnEnter();
    }
    
    static MouseGetState = function() {
        if (!__.useMouse) return MENU_MOUSE.INACTIVE;
        if (__.mouseFocus == -1) return MENU_MOUSE.IDLE;
        return MENU_MOUSE.HOVER;
    }
    
    static InputSetMethod = function(func) {
        __InputMethod = method(self, func);
        show_message(self);
    }
}
