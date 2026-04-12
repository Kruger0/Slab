
function MenuManager(config = {}) constructor{
    
    #region Private
    __style         = config[$ "style"] ?? new MenuStyle("default");
    __stackArray    = [];
    __pages         = {};
    __mouseX        = 0;
    __mouseY        = 0;
    __mouseEnabled  = true;
    __mouseActive   = false;
    __mouseFocus    = undefined;
    __nodeLocked    = undefined;
    
    static __InputMethodAction = function() {
        return {
            leftPressed         : InputRepeat(INPUT_VERB.LEFT, 0, 2),
            rightPressed        : InputRepeat(INPUT_VERB.RIGHT, 0, 2),
            upPressed           : InputRepeat(INPUT_VERB.UP, 0, 2),
            downPressed         : InputRepeat(INPUT_VERB.DOWN, 0, 2),
                                    
            selectPressed       : InputPressed(INPUT_VERB.ACCEPT),
            selectHeld          : InputCheck(INPUT_VERB.ACCEPT),
            selectReleased      : InputReleased(INPUT_VERB.ACCEPT),
                                    
            backPressed         : InputPressed(INPUT_VERB.CANCEL),
            backHeld            : InputCheck(INPUT_VERB.CANCEL),
            backReleased        : InputReleased(INPUT_VERB.CANCEL),
        }
    }
    static __InputMethodMouse = function() {
        return {
            leftPressed     : InputMousePressed(mb_left),
            leftHelf        : InputMouseCheck(mb_left),
            leftReleased    : InputMouseReleased(mb_left),
                                
            rightPressed    : InputMousePressed(mb_right),
            rightHeld       : InputMouseCheck(mb_right),
            rightReleased   : InputMouseReleased(mb_right),
            
            xDelta          : window_mouse_get_delta_x(),
            yDelta          : window_mouse_get_delta_y(),
            scrollDelta     : mouse_wheel_down() - mouse_wheel_up(),
        }
    }
    static __InputClear = function(input) {
        var _keys = struct_get_names(input);
        for (var i = 0; i < array_length(_keys); i++) {
            input[$ _keys[i]] = 0;
        }
    }
    #endregion
    
    #region Public
    static Update = function(mx, my) {
        __mouseX = mx;
        __mouseY = my;
        
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        
        var _inputAction    = __InputMethodAction();
        var _inputMouse     = __InputMethodMouse();
        
        if (__mouseActive) {
            __InputClear(_inputAction);
        } else {
            __InputClear(_inputMouse);
        }
        
        // Locked Node
        if (!is_undefined(__nodeLocked)) {
            __nodeLocked.Update(true);
            if (__mouseActive) {
                if (!is_undefined(__mouseFocus)) {
                    __nodeLocked.HandleMouse(_inputMouse);
                }
            } else {
                __nodeLocked.HandleAction(_inputAction);
            }
            if (_inputAction.backPressed) NodeUnlock();
            delete _inputAction;
            delete _inputMouse;
            return self;
        }
        
        // Input State
        var _nodeCount = _page.__nodeCount;
        if (__mouseEnabled) {
            var _mouseActive = __mouseActive;
            if (InputMouseCheck(mb_any)) __mouseActive = true;
            if (InputMouseMoved()) __mouseActive = true;
            if (InputCheckMany(-1, -1)) __mouseActive = false;
            if (__mouseActive && !_mouseActive) {
                for (var i = 0; i < _nodeCount; i++) _page.__nodeArray[i].SetFocused(false);
            }
        } else {
            __mouseActive = false;
        }
        
        // Node Selection
        __mouseFocus = undefined;
        if (__mouseActive) {
            for (var i = 0; i < _nodeCount; i++) {
                var _node = _page.__nodeArray[i];
                var _isOver = _node.ContainsPoint(__mouseX, __mouseY);
                if (_isOver && !_node.__interactive) {
                    _node.__focused = false;
                    continue;
                }
                if (_isOver && !_node.__focused) _node.SetFocused(true);
                if (!_isOver && _node.__focused) _node.SetFocused(false);
                if (_isOver) __mouseFocus = i;
            }
            _page.__NodeSet(__mouseFocus);
        } else {
            var _yDelta = (_inputAction.downPressed - _inputAction.upPressed);
            if (_yDelta != 0) {
                var _next = _page.__NodeGet();
                var _guard = 0;
                do {
                    _next += _yDelta;
                    if (_page.__cycle) {
                        _next = ((_next % _nodeCount) + _nodeCount) % _nodeCount;
                    } else {
                        _next = clamp(_next, 0, _nodeCount - 1);
                    }
                    _guard++;
                } until (_page.__nodeArray[_next].__interactive || _guard >= _nodeCount);
                _page.__NodeSet(_next);
            }
        }
        
        _page.Update(__mouseActive);
        var _node = _page.NodeGetActive();
        
        // Input Handling
        if (_node.__interactive) {
            if (__mouseActive) {
                if (!is_undefined(__mouseFocus)) {
                    _node.HandleMouse(_inputMouse);
                }
            } else {
                _node.HandleAction(_inputAction);
            }
        }
        
        // Back
        if (_inputAction.backPressed) PagePop();
        
        // Cleanup
        delete _inputAction;
        delete _inputMouse;
        return self;
    }
    static Render = function() {
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        _page.Render();
        if (global.debug) {
            var _c = #FF00FF
            draw_circle_color(__mouseX, __mouseY, 2, _c, _c, false);
            draw_circle_color(__mouseX, __mouseY, 6, _c, _c, true);
        }
        return self;
    }
    
    static PageGetActive = function() {
        var _page = array_last(__stackArray);
        return __pages[$ _page];
    }
    static PageAdd = function(page) {
        __pages[$ page.__name] = page;
        __pages[$ page.__name].__mng = self;
        return self;
    }
    static PagePush = function(page) {
        var _pageCurr = PageGetActive();
        if !(is_undefined(_pageCurr)) _pageCurr.Leave(false);
        array_push(__stackArray, page);
        var _pageNext = PageGetActive();
        if (is_undefined(_pageNext)) return;
        _pageNext.Enter(__mouseActive);
        return self;
    }
    static PagePop = function() {
        if (array_length(__stackArray) <= 1) return;
        var _pageCurr = PageGetActive();
        if (is_undefined(_pageCurr)) return;
        _pageCurr.Leave(true);
        array_pop(__stackArray);
        var _pageNext = PageGetActive();
        if (is_undefined(_pageNext)) return;
        _pageNext.Enter(__mouseActive);
        return self;
    }
    
    static MouseGetState = function() {
        if (!__mouseActive) return MENU_MOUSE.INACTIVE;
        if (is_undefined(__mouseFocus)) return MENU_MOUSE.IDLE;
        return MENU_MOUSE.HOVER;
    }
    static MouseSetEnabled = function(enabled) {
        __mouseEnabled = enabled;
        return self;
    }
    static MouseGetEnabled = function() {
        return __mouseEnabled ;
    }
    
    static NodeLock = function(node) {
        __nodeLocked = node;
        return self;
    }
    static NodeUnlock = function() {
        __nodeLocked = undefined;
        return self;
    }
    
    #endregion
}
