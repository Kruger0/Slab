
global.debug = false;

#region MenuSystem Creation

mainMenu = new MenuManager();
mainMenu.PageAdd(new MenuPage("menu_main", [
    new MenuNodeLabel("MAIN MENU PAGE"),
    new MenuNodeSeparator(),
    new MenuNodeButton("Start", function(){show_debug_message("STARTING GAME")}),
    new MenuNodeButton("Continue"),
    new MenuNodeButton("Options", function(){PagePush("menu_options")}),
    new MenuNodeButton("Credits"),
    new MenuNodeConfirm("Exit", function(){game_end()}),
]))
mainMenu.PageAdd(new MenuPage("menu_options", [
    new MenuNodeLabel("OPTIONS"),
    new MenuNodeSeparator(),
    new MenuNodeSelector("Language", [["English", "en_US"],["Português", "pt_BR"]], function(option){show_debug_message($"Language set to {option[0]}")}),
    new MenuNodeButton("Audio", function(){PagePush("menu_audio")}),
    new MenuNodeButton("Video", function(){PagePush("menu_video")}),
    new MenuNodeButton("Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_audio", [
    new MenuNodeLabel("AUDIO"),
    new MenuNodeSeparator(),
    new MenuNodeSlider("Master Volume"),
    new MenuNodeSlider("Music Volume"),
    new MenuNodeSlider("SFX Volume"),
    new MenuNodeButton("Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_video", [
    new MenuNodeLabel("VIDEO"),
    new MenuNodeSeparator(),
    new MenuNodeToggle("Fullscreen"),
    new MenuNodeSelector("Resolution", [["640x360", 0],["1280x720", 1],["1920x1080", 2]], function(option){show_debug_message($"Resolution set to {option[0]}")}),
    new MenuNodeToggle("Bloom"),
    new MenuNodeToggle("VSync"),
    new MenuNodeButton("Back", function(){PagePop()}),
]))

mainMenu.PagePush("menu_main");

#endregion

var _panel = layer_get_flexpanel_node("layerBase")
//var _container = flexpanel_node_get_child(_panel, "container")
//data = flexpanel_node_layout_get_position(_container)
//var _data = flexpanel_node_get_struct(_panel)
//_data = json_stringify(_data, true)
//show_debug_message(_data)

function FlexGetNodes(root, data = [], ref = "") {
    var _pos    = flexpanel_node_layout_get_position(root, false);
    var _name   = string_split(flexpanel_node_get_name(root), "_");
    var _type   = _name[0];
    var _id     = (array_length(_name) > 1 ? string_join_ext("_", _name, 1) : ""); 
    var _z      = 0;
    var _par    = "";
    
    switch (_type) {
        // Main Nodes
        case "TEXT": {
            
        } break;
        case "SEP": {
            
        } break;
        case "BUTTON": {
            
        } break;
        case "SELECT": {
            ref = _id;
        } break;
        case "SLIDER": {
            ref = _id;
        } break;
        case "CHECKBOX": {
            ref = _id;
        } break;
        // Subnodes
        case "BAR":
        case "BOX":
        case "LEFT":
        case "RIGHT": {
            _z = 1;
            _par = ref;
        } break;
        case "LABEL":
        case "VALUE": {
            _par = ref;
        } break;
    }
    
    array_push(data, {
        type: _type,    // Node Type
        id  : _id,      // Node Name
        par : _par,     // Subnode Parent
        z   : _z,       // Node priotiry
        x   : _pos.left, 
        y   : _pos.top,
        w   : _pos.width, 
        h   : _pos.height,
        c   : random(#FFFFFF),//make_colour_hsv(random(255), 255, 128),
    });
    
    var _childs = flexpanel_node_get_num_children(root);
    for (var i = 0; i < _childs; i++) {
        var _child = flexpanel_node_get_child(root, i);
        FlexGetNodes(_child, data, ref);
    }
    return data;
}

nodeData = FlexGetNodes(_panel)

function FlexDrawQuad(data) {
    
    var _z = 0;
    var _n = 0;
    for (var i = 0, n = array_length(data); i < n; i++) {
        var _node = data[i];
        var _x1 = _node.x;
        var _y1 = _node.y;
        var _x2 = _x1+_node.w;
        var _y2 = _y1+_node.h;
        var _c  = _node.c;
        
        if (point_in_rectangle(mouse_x, mouse_y, _node.x, _node.y, _node.x + _node.w, _node.y + _node.h)) {
            if (_node.z > _z) {
                _z = _node.z;
                _n = i;
            }
        }
        
        if (_node.id != "") {
            var _r = 12;
            draw_roundrect_color_ext(_x1, _y1, _x2, _y2, _r, _r, _c, _c, false);
        }
        
        if (global.debug) {
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(_x1 + _node.w/2, _y1 + _node.h/2, _node.id);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            
            draw_sprite_stretched_ext(spr_flex_area, 1, _x1, _y1, _node.w, _node.h, -1, 1.0);
        }
    }
    
    var _node = data[_n];
    var _x1 = _node.x;
    var _y1 = _node.y;
    draw_sprite_stretched_ext(spr_flex_area, 1, _x1, _y1, _node.w, _node.h, -1, 1.0);
}

ZoneGetActive = function() {
        var _mx = mng.mx - mng.x;
        var _my = mng.my - mng.y;
        var _active = "";
        var _layer  = -1;
        for (var i = 0, n = array_length(zones); i < n; i++) {
            var _z = zones[i];
            if (point_in_rectangle(_mx, _my, _z.x, _z.y, _z.x + _z.w, _z.y + _z.h)) {
                if (_z.layer > _layer) {
                    _layer = _z.layer;
                    _active = _z.name;
                }
            }
        }
        return _active;
    }






