
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
    __lockedNode    = undefined;
    __enabled       = true;
    
    static __GetActionInput  = function() {
        return {
            leftPressed     : InputRepeat(INPUT_VERB.LEFT, 0, 2),
            rightPressed    : InputRepeat(INPUT_VERB.RIGHT, 0, 2),
            upPressed       : InputRepeat(INPUT_VERB.UP, 0, 2),
            downPressed     : InputRepeat(INPUT_VERB.DOWN, 0, 2),
            
            selectPressed   : InputPressed(INPUT_VERB.ACCEPT),
            selectHeld      : InputCheck(INPUT_VERB.ACCEPT),
            selectReleased  : InputReleased(INPUT_VERB.ACCEPT),
            
            backPressed     : InputPressed(INPUT_VERB.CANCEL),
            backHeld        : InputCheck(INPUT_VERB.CANCEL),
            backReleased    : InputReleased(INPUT_VERB.CANCEL),
        }
    }
    static __GetMouseInput = function() {
        return {
            leftPressed     : InputMousePressed(mb_left),
            leftHeld        : InputMouseCheck(mb_left),
            leftReleased    : InputMouseReleased(mb_left),
            
            rightPressed    : InputMousePressed(mb_right),
            rightHeld       : InputMouseCheck(mb_right),
            rightReleased   : InputMouseReleased(mb_right),
            
            scrollDelta     : mouse_wheel_down() - mouse_wheel_up(),
        }
    }
    static __ClearInput = function(input) {
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
        
        var _page = GetActivePage();
        if (is_undefined(_page)) return;
        
        var _inputAction = __GetActionInput ();
        var _inputMouse = __GetMouseInput();
        
        if (__mouseActive) {
            __ClearInput(_inputAction);
        } else {
            __ClearInput(_inputMouse);
        }
        
        // Locked Node
        if (!is_undefined(__lockedNode)) {
            __lockedNode.Update(true);
            if (__mouseActive) {
                if (!is_undefined(__mouseFocus)) {
                    __lockedNode.HandleMouse(_inputMouse);
                }
            } else {
                __lockedNode.HandleAction(_inputAction);
            }
            if (_inputAction.backPressed) UnlockNode();
            delete _inputAction;
            delete _inputMouse;
            return self;
        }
        
        // Input State
        var _nodeCount = array_length(_page.__nodeArray);
        if (__mouseEnabled) {
            var _mouseActive = __mouseActive;
            if (InputMouseCheck(mb_any)) __mouseActive = true;
            if (InputMouseMoved()) __mouseActive = true;
            if (InputCheckMany(-1, -1)) __mouseActive = false;
            if (__mouseActive && !_mouseActive) {
                for (var i = 0; i < _nodeCount; i++) {
                    _page.__nodeArray[i].SetFocused(false);
                }
            }
        } else {
            __mouseActive = false;
        }
        
        // Node Selection
        __mouseFocus = undefined;
        if (__mouseActive) {
            for (var i = 0, n = array_length(_page.__nodeOrder); i < n; i++) {
                var _node = _page.__GetNode(i);
                var _isOver = _node.ContainsPoint(__mouseX, __mouseY);
                if (_isOver && !_node.__interactive) {
                    _node.__focused = false;
                    continue;
                }
                if (_isOver && !_node.__focused) _node.SetFocused(true);
                if (!_isOver && _node.__focused) _node.SetFocused(false);
                if (_isOver) __mouseFocus = i;
            }
            _page.__SetNode(__mouseFocus);
        } else {
            var _yDelta = (_inputAction.downPressed - _inputAction.upPressed);
            if (_yDelta != 0) {
                var _next = _page.__nodeActive;
                var _count = array_length(_page.__nodeOrder);
                var _guard = 0;
                do {
                    _next += _yDelta;
                    if (_page.__cycle) {
                        _next = ((_next % _count) + _count) % _count;
                    } else {
                        _next = clamp(_next, 0, _count - 1);
                    }
                    _guard++;
                } until (_page.__nodeArray[_page.__nodeOrder[_next]].__interactive || _guard >= _count);
                _page.__SetNode(_next);
            }
        }
        
        _page.__Update(__mouseActive);
        var _node = _page.__GetNodeActive();
        
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
        if (_inputAction.backPressed) PopPage();
        
        // Cleanup
        delete _inputAction;
        delete _inputMouse;
        return self;
    }
    static Render = function() {
        var _page = GetActivePage();
        if (is_undefined(_page)) return;
        _page.__Render();
        if (global.debug) {
            var _c = #FF00FF;
            draw_circle_color(__mouseX, __mouseY, 2, _c, _c, false);
            draw_circle_color(__mouseX, __mouseY, 6, _c, _c, true);
        }
        return self;
    }
    
    static GetActivePage = function() {
        var _page = array_last(__stackArray);
        return __pages[$ _page];
    }
    static AddPage = function(name) {
        static cache = __MenuCache();
        var _data = cache.pages[$ name];
        var _page = new MenuPage(name, _data.layer, _data.nodes);
        _page.__mng = self;
        __pages[$ name] = _page;
        return self;
    }
    static PushPage = function(name) {
        var _pageCurr = GetActivePage();
        if !(is_undefined(_pageCurr)) _pageCurr.__Leave(false);
        array_push(__stackArray, name);
        var _pageNext = GetActivePage();
        if (is_undefined(_pageNext)) return;
        _pageNext.__Enter(__mouseActive);
        return self;
    }
    static PopPage = function() {
        if (array_length(__stackArray) <= 1) return;
        var _pageCurr = GetActivePage();
        if (is_undefined(_pageCurr)) return;
        _pageCurr.__Leave(true);
        array_pop(__stackArray);
        var _pageNext = GetActivePage();
        if (is_undefined(_pageNext)) return;
        _pageNext.__Enter(__mouseActive);
        return self;
    }
    
    static SetMouseEnabled = function(enabled) {
        __mouseEnabled = enabled;
        return self;
    }
    static GetMouseEnabled = function() {
        return __mouseEnabled ;
    }
    static GetMouseState = function() {
        if (!__mouseActive) return MENU_MOUSE.INACTIVE;
        if (is_undefined(__mouseFocus)) return MENU_MOUSE.IDLE;
        return MENU_MOUSE.HOVER;
    }
    
    static LockNode = function(node) {
        __lockedNode = node;
        return self;
    }
    static UnlockNode = function() {
        __lockedNode = undefined;
        return self;
    }
    
    static GetStyle = function(style) {
        
    }
    static SetStyle = function(style) {
        
    }
    #endregion
}
