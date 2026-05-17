
function __MenuPage(data, manager) constructor{
    static cache = __MenuCache();
    
    __layer         = data.layer;
    __nodeArray     = data.nodes;
    __cycle         = data.config[$ "cycle"] ?? true;
    __manager       = manager;
    __styleSource   = MenuBindStyle(manager.__style);
    __styleOverride = MenuBindStyle(data.config[$ "style"]);
    __style         = MenuMergeStyle(__styleSource, __styleOverride);;
    __nodeOrder     = [];
    __nodeActive    = 0;
    
    static __SetNode = function(value) {
        if (is_undefined(value)) return;
        if (value != clamp(value, 0, array_length(__nodeOrder)-1)) return;
        __nodeActive = value;
        return self;
    }
    
    static __FlexNode = function(type, id, x, y, z, w, h) constructor {
        self.type   = type;
        self.id     = id;
        self.x      = x;
        self.y      = y;
        self.z      = z;
        self.w      = w;
        self.h      = h;
        self.active = false;
    };
    static __FlexParse = function(root, data = []) {
        var _name = string_split(flexpanel_node_get_name(root), "_");
        var _type = _name[0];
        var _id = (array_length(_name) > 1 ? string_join_ext("_", _name, 1) : ""); 
        var _z = 0;
        var _isNode = true;
        
        switch (_type) {
            // Body
            case MENU_NODE_TEXT:
            case MENU_NODE_SEPARATOR:
            case MENU_NODE_BUTTON:
            case MENU_NODE_SPRITE:
            case MENU_NODE_SELECTOR:
            case MENU_NODE_SLIDER:
            case MENU_NODE_CONFIRM:
            case MENU_NODE_CHECKBOX: {
                _type = MENU_ZONE_BODY;
            } break;
            // Zones
            case MENU_ZONE_VALUE: {
                    
            } break;
            case MENU_ZONE_BAR:
            case MENU_ZONE_BOX:
            case MENU_ZONE_LEFT:
            case MENU_ZONE_RIGHT: {
                _z = 1;
            } break;
            default: {
                _isNode = false;
            }
        }
        
        // Create a ref on the node
        for (var i = 0, n = array_length(__nodeArray); i < n; i++) {
            var _node = __nodeArray[i];
            if (_node.__id == _id) {
                var _flexDisp = flexpanel_node_style_get_display(root);
                var _nodeDisp = (_node.__visible ? flexpanel_display.flex : flexpanel_display.none);
                if (_flexDisp != _nodeDisp) {
                    flexpanel_node_style_set_display(root, _nodeDisp);
                }
                _node.__zoneNode = root;
                break;
            }
        }
        
        // Push to node data
        if (_isNode) {
            var _n = flexpanel_node_layout_get_position(root, false);
            array_push(data, new __FlexNode(_type, _id, _n.left, _n.top, _z, _n.width, _n.height));
        }
        
        // Continue
        var _childs = flexpanel_node_get_num_children(root);
        for (var i = 0; i < _childs; i++) {
            var _child = flexpanel_node_get_child(root, i);
            __FlexParse(_child, data);
        }
        return data;
    };
    
    static __InitPage = function() {
        var _root = layer_get_flexpanel_node(__layer);
        var _layout = __FlexParse(_root);
        var _rootPos = flexpanel_node_layout_get_position(_root);
        flexpanel_calculate_layout(_root, _rootPos.width, _rootPos.height, _rootPos.direction);
        _layout = __FlexParse(_root);
            
        // Updates node navigation order
        __nodeOrder = [];
        for (var i = 0, n = array_length(_layout); i < n; i++) {
            if (_layout[i].type != MENU_ZONE_BODY) continue;
            var _id = _layout[i].id;
            for (var j = 0, o = array_length(__nodeArray); j < o; j++) {
                if (__nodeArray[j].__id == _id) {
                    array_push(__nodeOrder, j);
                    break;
                }
            }
        }
            
        // Link nodes to their zones
        for (var i = 0, n = array_length(__nodeArray); i < n ; i++) {
            var _node = __nodeArray[i];
            var _flex = _node.__zoneNode;
            if (_flex == undefined) continue;
            var _data = __FlexParse(_flex);
            with (_node) {
                __zoneArray = _data;
                __zoneCount = array_length(_data);
            }
        }
        
        // Set first interactive node as active
        var _guard = 0;
        var _count = array_length(__nodeOrder);
        while (!__GetNodeActive().__interactive && _guard < _count) {
            __nodeActive = (__nodeActive + 1) % _count;
            _guard++;
        }
    }
    
    static __GetNodeActive = function() {
        return __nodeArray[__nodeOrder[__nodeActive]];
    }
    static __GetNode = function(index) {
        return __nodeArray[__nodeOrder[index]];
    }

    static __Update = function(mouseActive){
        for (var i = 0, n = array_length(__nodeArray); i < n; i++) {
            var _node = __nodeArray[i];
            _node.__Update(mouseActive ? undefined : (__GetNodeActive() == _node));
        }
    };
    static __Render = function(){
        for (var i = 0, n = array_length(__nodeArray); i < n; i++) {
            var _node = __nodeArray[i];
            _node.__Render()
        }
    };
    static __Enter = function(resetNode) {
        __style = MenuMergeStyle(__styleSource, __styleOverride);
        __InitPage();
        for (var i = 0, n = array_length(__nodeArray); i < n; i++) {
            var _node = __nodeArray[i];
            _node.__Enter(self);
            if (resetNode) {
                _node.__Update(false);
            } else {
                _node.__Update(__GetNodeActive() == _node);
            }
        }
    }
    static __Leave = function(resetNode) {
        if (resetNode) __nodeActive = 0;
        for (var i = 0, n = array_length(__nodeArray); i < n; i++) {
            var _node = __nodeArray[i];
            _node.__Leave();
        }
    }
}
