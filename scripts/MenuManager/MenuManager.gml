
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
        style           = config[$ "style"] ?? new MenuStyle("styleTest");
        
        static __InputMethodActions = function() {
            return {
                leftPressed         : InputPressed(INPUT_VERB.LEFT),
                rightPressed        : InputPressed(INPUT_VERB.RIGHT),
                upPressed           : InputPressed(INPUT_VERB.UP),
                downPressed         : InputPressed(INPUT_VERB.DOWN),
                                    
                selectPressed       : InputPressed(INPUT_VERB.ACCEPT),
                selectCheck         : InputCheck(INPUT_VERB.ACCEPT),
                selectReleased      : InputReleased(INPUT_VERB.ACCEPT),
                                    
                backPressed         : InputPressed(INPUT_VERB.CANCEL),
                backCheck           : InputCheck(INPUT_VERB.CANCEL),
                backReleased        : InputReleased(INPUT_VERB.CANCEL),
            }
        }
        static __InputMethodMouse = function() {
            return {
                leftPressed     : InputMousePressed(mb_left),
                leftCheck       : InputMouseCheck(mb_left),
                leftReleased    : InputMouseReleased(mb_left),
                                
                rightPressed    : InputMousePressed(mb_right),
                rightCheck      : InputMouseCheck(mb_right),
                rightReleased   : InputMouseReleased(mb_right),
                
                //scrollDelta     : InputMouseCheck()
            }
        }
        static __InputClear = function(input) {
            var _keys = struct_get_names(input);
            for (var i = 0; i < array_length(_keys); i++) {
                input[$ _keys[i]] = 0;
            }
        }
    }
    
    // Public
    static Update = function(mx, my) {
        __.mx = mx;
        __.my = my;
        
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        
        var _inputActions   = __InputMethodActions();
        var _inputMouse     = __InputMethodMouse();
        
        if (__.mouseActive) {
            __InputClear(_inputActions);
        } else {
            __InputClear(_inputMouse);
        }
        
        // Input State
        var _nodeCount = _page.__.nodeCount;
        if (__.mouseEnabled) {
            var _mouseActive = __.mouseActive;
            if (InputMouseCheck(mb_any)) __.mouseActive = true;
            if (InputMouseMoved()) __.mouseActive = true;
            if (InputCheckMany(-1, -1)) __.mouseActive = false;
            if (__.mouseActive && !_mouseActive) {
                for (var i = 0; i < _nodeCount; i++) _page.__.nodeArray[i].SetFocused(false);
            }
        } else {
            mouseActive = false;
        }
        
        // Node Selection
        __.mouseFocus = undefined;
        if (__.mouseActive) {
            for (var i = 0; i < _nodeCount; i++) {
                var _node = _page.__.nodeArray[i];
                var _isOver = _node.ContainsPoint(__.mx, __.my);
                if (_isOver && !_node.interactive) {
                    _node.focused = false;
                    continue;
                }
                if (_isOver && !_node.focused) _node.SetFocused(true);
                if (!_isOver && _node.focused) _node.SetFocused(false);
                if (_isOver) __.mouseFocus = i;
            }
            _page.__NodeSet(__.mouseFocus);
        } else {
            var _yDelta = (_inputActions.downPressed - _inputActions.upPressed);
            if (_yDelta != 0) {
                var _next = _page.__NodeGet();
                var _guard = 0;
                do {
                    _next += _yDelta;
                    if (_page.cycle) {
                        _next = ((_next % _nodeCount) + _nodeCount) % _nodeCount;
                    } else {
                        _next = clamp(_next, 0, _nodeCount - 1);
                    }
                    _guard++;
                } until (_page.__.nodeArray[_next].interactive || _guard >= _nodeCount);
                _page.__NodeSet(_next);
            }
        }
        
        _page.Update(__.mouseActive);
        var _node = _page.NodeGetActive();
        
        // Input Handling
        if (_node.interactive) {
            if (__.mouseActive) {
                if (!is_undefined(__.mouseFocus)) {
                    _node.MouseHandler(_inputMouse);
                }
            } else {
                _node.ActionHandler(_inputActions);
                // TODO node locking for handling in node navigation using xDelta & yDelta
            }
        }
        
        // Back
        if (_inputActions.backPressed) PagePop();
        
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
        __.pages[$ page.__.name] = page;
        __.pages[$ page.__.name].__.mng = self;
        return self;
    }
    static PagePush = function(page) {
        var _pageCurr = PageGetActive();
        if !(is_undefined(_pageCurr)) _pageCurr.Leave(false);
        array_push(__.stack, page);
        var _pageNext = PageGetActive();
        if (is_undefined(_pageNext)) return;
        _pageNext.Enter(__.mouseActive);
        return self;
    }
    static PagePop = function() {
        if (array_length(__.stack) <= 1) return;
        var _pageCurr = PageGetActive();
        if (is_undefined(_pageCurr)) return;
        _pageCurr.Leave(true);
        array_pop(__.stack);
        var _pageNext = PageGetActive();
        if (is_undefined(_pageNext)) return;
        _pageNext.Enter(__.mouseActive);
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
}
