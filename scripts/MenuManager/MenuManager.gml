
function MenuManager() constructor{
    // Private
    stack   = [];
    pages   = {};
    
    // Statics
    static Update = function() {
        
        #region Fetch Inputs
        var _inputUp        = keyboard_check_pressed(vk_up);
        var _inputDown      = keyboard_check_pressed(vk_down);
        var _inputLeft      = keyboard_check_pressed(vk_left);
        var _inputRight     = keyboard_check_pressed(vk_right);
        var _inputSelect    = keyboard_check_pressed(vk_enter);
        var _inputBack      = keyboard_check_pressed(vk_escape)
        #endregion
        
        // Page Update
        var _page   = PageGetActive();
        var _delta  = _inputDown - _inputUp;
        with (_page) {
            var _next = cursor + _delta;
            var _count = array_length(_page.nodes);
            if (cycle) {
                cursor = ((_next % _count) + _count) % _count;
            } else {
                cursor = clamp(_next, 0, _count - 1);
            }
            Update();
        }
        
        // Node Update
        var _node = _page.NodeGetCurrent();
        if (_inputSelect) {
            _node.OnSelect(self);
        }
        
        // Global Back
        if (_inputBack) {
            PagePop();
        }
    }
    
    static Render = function(w, h) {
        var _ctx = {
            x:0, y:0, 
            w, h
        }
        var _page = PageGetActive();
        _page.Render(_ctx);
    }
    
    static PageAdd = function(page) {
        pages[$ page.name] = page;
    }
    
    static PagePush = function(page) {
        var _active = PageGetActive();
        if !(is_undefined(_active)) _active.OnSuspend();
        array_push(stack, pages[$ page]);
        PageGetActive().OnEnter();
    }
    
    static PagePop = function() {
        if (array_length(stack) <= 1) return;
        PageGetActive().OnLeave();
        array_pop(stack);
        PageGetActive().OnReveal();
    }
    
    static PageGetActive = function() {
        return array_last(stack);
    }
}

global.menuTest = new MenuManager();
global.menuTest.PageAdd(new MenuPage("menu_main", [
    new MenuNodeButton("ui_playGame", function(){show_debug_message("play_game")}),
    new MenuNodeButton("ui_options", function(mng){mng.PagePush("menu_options")}),
    new MenuNodeButton("ui_credits", function(){}),
    new MenuNodeButton("ui_exit", function(){game_end()}),
]))
global.menuTest.PageAdd(new MenuPage("menu_options", [
    new MenuNodeButton("ui_audio", function(mng){mng.PagePush("menu_audio")}),
    new MenuNodeButton("ui_video", function(mng){mng.PagePush("menu_video")}),
    new MenuNodeSelector("ui_language"),
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




















