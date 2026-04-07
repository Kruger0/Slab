
function MenuManager(config = {}) constructor{
    // Private
    stack   = [];
    pages   = {};
    x       = 0; 
    y       = 0;
    w       = 0;
    h       = 0;
    mx      = 0; 
    my      = 0;
    useKeys = true; // 
    
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
        var _inputUp        = keyboard_check_pressed(vk_up);
        var _inputDown      = keyboard_check_pressed(vk_down);
        var _inputLeft      = keyboard_check_pressed(vk_left);
        var _inputRight     = keyboard_check_pressed(vk_right);
        var _inputSelect    = keyboard_check_pressed(vk_enter);
        var _inputBack      = keyboard_check_pressed(vk_escape);
        var _inputClicked   = mouse_check_button_pressed(mb_left);

        #endregion
        
        #region Mouse Focus
        var _page  = PageGetActive();
        if (is_undefined(_page)) return;
        var _count = array_length(_page.nodes);
        var _delta = _inputDown - _inputUp;
        
        var _mouseFocusIdx = -1
        
        for (var i = 0; i < _count; i++) {
            var _node = _page.nodes[i];
            with (_node) {
                if (ContainsPoint(mx-x, my-y)) {
                    if (!mouseIn && !mouseOver) {
                        mouseIn = true;
                        mouseOut = false;
                        show_debug_message($"{name} - MOUSE IN");
                        OnMouseEnter();
                    }
                    mouseOver = true;
                    _mouseFocusIdx = i;
                    break;
                } else {
                    if (!mouseOut && mouseOver) {
                        mouseOut = true;
                        mouseIn = false;
                        show_debug_message($"{name} - MOUSE OUT");
                        OnMouseLeave();
                    }
                    mouseOver = false;
                }
            }
        }
        if (_mouseFocusIdx != -1) {
            _page.cursor = _mouseFocusIdx;
        }
        #endregion
        
        #region Key Focus
        if (_delta != 0) {
            var _next = _page.cursor + _delta;
            if (_page.cycle) {
                _page.cursor = ((_next % _count) + _count) % _count;
            } else {
                _page.cursor = clamp(_next, 0, _count - 1);
            }
        }
        #endregion
        
        _page.Update();
        
        #region Mouse Zone
        var _node = _page.NodeGetActive();
        if (_mouseFocusIdx != -1) {
            _node.UpdateHoveredZone(mx-x, my-y);
        } else {
            _node.hoveredZone = "";
        }
        #endregion
        
        #region Selection
        if (_inputSelect || (_inputClicked && _mouseFocusIdx != -1)) {
            _node.Select(self);
        }
        #endregion
        
        if (_inputBack) PagePop();
    }
    
    static Render = function() {
        var _ctx = {x, y, w, h};
        var _page = PageGetActive();
        if (is_undefined(_page)) return;
        _page.Render(_ctx);
        draw_circle_color(mx, my, 2, c_lime, c_lime, false);
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
    new MenuNodeButton("ui_playGame"),
    new MenuNodeButton("ui_continue"),
    new MenuNodeButton("ui_options", function(mng){mng.PagePush("menu_options")}),
    new MenuNodeButton("ui_credits"),
    new MenuNodeButton("ui_exit", function(){game_end()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_options", [
    new MenuNodeSelector("ui_language"),
    new MenuNodeButton("ui_audio", function(mng){mng.PagePush("menu_audio")}),
    new MenuNodeButton("ui_video", function(mng){mng.PagePush("menu_video")}),
    new MenuNodeButton("ui_back", function(mng){mng.PagePop()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_audio", [
    new MenuNodeSlider("ui_volume_master"),
    new MenuNodeSlider("ui_volume_music"),
    new MenuNodeSlider("ui_volume_sfx"),
    new MenuNodeButton("ui_back", function(mng){mng.PagePop()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_video", [
    new MenuNodeToggle("ui_fullscreen"),
    new MenuNodeSelector("ui_resolution"),
    new MenuNodeToggle("ui_bloom"),
    new MenuNodeToggle("ui_vsync"),
    new MenuNodeButton("ui_back", function(mng){mng.PagePop()}),
]))

global.menuTest.PagePush("menu_main");


