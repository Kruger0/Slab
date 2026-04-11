
function MenuManager(config = {}) constructor{
    
    // Private
    __ = {};
    with (__) {
        stack           = [];
        pages           = {};
        mx              = 0;
        my              = 0;
        mouseEnabled    = true;
        mouseActive     = false;
        mouseFocus      = undefined;
        
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
        
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        
        var _input = __InputMethod();
        if (__.mouseActive) {
            _input.selectPressed = 0;
            _input.xDelta = 0;
            _input.yDelta = 0;
        } else {
            _input.mouseLeftPressed = 0;
        }
        
        // Input State
        var _count = array_length(_page.nodes);
        if (__.mouseEnabled) {
            var _mouseActive = __.mouseActive;
            if (InputMouseCheck(mb_any)) __.mouseActive = true;
            if (InputMouseMoved()) __.mouseActive = true;
            if (InputCheckMany(-1, -1)) __.mouseActive = false;
            if (__.mouseActive && !_mouseActive) {
                for (var i = 0; i < _count; i++) _page.nodes[i].SetFocused(false);
            }
        } else {
            mouseActive = false;
        }
        
        // Node Selection
        __.mouseFocus = undefined;
        if (__.mouseActive) {
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
            _page.__CursorSet(__.mouseFocus);
        } else {
            if (_input.yDelta != 0) {
                var _next = _page.__CursorGet();
                var _guard = 0;
                do {
                    _next += _input.yDelta;
                    if (_page.cycle) {
                        _next = ((_next % _count) + _count) % _count;
                    } else {
                        _next = clamp(_next, 0, _count - 1);
                    }
                    _guard++;
                } until (_page.nodes[_next].interactive || _guard >= _count);
                _page.__CursorSet(_next);
            }
        }
        
        _page.Update(__.mouseActive);
        var _node = _page.NodeGetActive();
        
        // Input Handling
        if (_node.interactive) {
            if (__.mouseActive) {
                if (!is_undefined(__.mouseFocus)) {
                    _node.InputHandle(_input);
                }
            } else {
                _node.InputHandle(_input);
                // TODO node locking for handling in node navigation using xDelta & yDelta
            }
        }
        
        // Back
        if (_input.backPressed) PagePop();
        
        // Cleanup
        delete _input;
        return self;
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
        return self;
    }
    
    static PageGetActive = function() {
        var _page = array_last(__.stack);
        return __.pages[$ _page];
    }
    static PageAdd = function(page) {
        __.pages[$ page.name] = page;
        __.pages[$ page.name].mng = self;
        return self;
    }
    static PagePush = function(page) {
        var _pageCurr = PageGetActive();
        if !(is_undefined(_pageCurr)) _pageCurr.OnLeave(false);
        array_push(__.stack, page);
        var _pageNext = PageGetActive();
        if !(is_undefined(_pageNext)) _pageNext.OnEnter();
        return self;
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
        return self;
    }
    
    static MouseGetState = function() {
        if (!__.mouseActive) return MENU_MOUSE.INACTIVE;
        if (is_undefined(__.mouseFocus)) return MENU_MOUSE.IDLE;
        return MENU_MOUSE.HOVER;
    }
    static MouseSetEnabled = function(enabled) {
        __.mouseEnabled = enabled;
        return self;
    }
    
    static InputSetMethod = function(func) {
        __InputMethod = method(self, func);
        return self;
    }
}
