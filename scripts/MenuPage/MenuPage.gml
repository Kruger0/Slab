
function MenuPage(name, layer, nodes, config = {}) constructor{
    
    #region Private
    __name          = name;
    __layer         = layer;
    __cycle         = config[$ "cycle"] ?? true;
    __style         = config[$ "style"];
    __mng           = undefined;
    __nodeArray     = nodes;
    __nodeCount     = array_length(nodes);
    __nodeActive    = 0; // TODO change to index?
    
    static __NodeSet = function(value) {
        if (is_undefined(value)) return;
        if (value != clamp(value, 0, __nodeCount-1)) return;
        __nodeActive = value;
        return self;
    }
    static __NodeGet = function() {
        return __nodeActive;
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
        var _name   = string_split(flexpanel_node_get_name(root), "_");
        var _type   = _name[0];
        var _id     = (array_length(_name) > 1 ? string_join_ext("_", _name, 1) : ""); 
        var _z      = 0;
        var _isNode = true;
              
        switch (_type) {
            // Body
            case "TEXT":
            case "SEPARATOR":
            case "BUTTON":
            case "SPRITE":
            case "SELECTOR":
            case "SLIDER":
            case "CONFIRM":
            case "CHECKBOX": {
                _type = "BODY";
            } break;
            // Zones
            case "VALUE": {
                    
            } break;
            case "BAR":
            case "BOX":
            case "LEFT":
            case "RIGHT": {
                _z = 1;
            } break;
            default: {
                _isNode = false;
            }
        }
            
        // Create a ref on the node
        for (var i = 0; i < __nodeCount; i++) {
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
    
    static __PageInit = function() {
            var _root = layer_get_flexpanel_node(__layer);
            var _layout = __FlexParse(_root);
            var _rootPos = flexpanel_node_layout_get_position(_root);
            flexpanel_calculate_layout(_root, _rootPos.width, _rootPos.height, _rootPos.direction);
            _layout = __FlexParse(_root);
            
            for (var i = 0; i < __nodeCount; i++) {
                var _node = __nodeArray[i];
                var _flex = _node.__zoneNode;
                if (_flex == undefined) continue;
                var _data = __FlexParse(_flex);
                with (_node) {
                    __zoneArray = _data;
                    __zoneCount = array_length(_data);
                }
            }
        }
    __PageInit();
    #endregion
    
    #region Public
    static NodeGetActive = function() {
        return __nodeArray[__nodeActive];
    }
    static NodeFindFirst = function() {
        var _guard = 0;
        while (!__nodeArray[__nodeActive].__interactive && _guard < __nodeCount) {
            __nodeActive++;
            _guard++;
        }
    }
    
    static Update = function(mouseActive){
        for (var i = 0; i < __nodeCount; i++) {
            var _node = __nodeArray[i];
            _node.Update(mouseActive ? undefined : (__nodeActive == i));
        }
    };
    static Render = function(){
        for (var i = 0; i < __nodeCount; i++) {
            var _node = __nodeArray[i];
            _node.Render();
        }
    };
    static Enter = function(resetNode) {
        NodeFindFirst();
        __style ??= __mng.__style;
        for (var i = 0; i < __nodeCount; i++) {
            var _node = __nodeArray[i];
            _node.__mng = __mng;
            _node.__style ??= __style;
            _node.Enter();
            if (resetNode) {
                _node.Update(false);
            } else {
                _node.Update(__nodeActive == i);
            }
        }
    }
    static Leave = function(resetNode) {
        if (resetNode) __nodeActive = 0;
        for (var i = 0; i < __nodeCount; i++) {
            var _node = __nodeArray[i];
            _node.Leave();
            //if (resetNode) _node.Update(false);
        }
    }
    #endregion
}
