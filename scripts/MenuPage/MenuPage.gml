
function MenuPage(name, layer, nodes, config = {}) constructor{
    self.name   = name;
    self.layer  = layer;
    self.nodes  = nodes;
    
    #region Public
    cycle   = config[$ "cycle"] ?? true;
    enabled = config[$ "enabled"] ?? true;
    #endregion
    
    // Private
    __ = {};
    with (__) {
        self.name   = name;
        self.layer  = layer;
        cursor      = 0; // DEPRECATED
        ready       = false;
        nodeArray   = nodes;
        nodeCount   = array_length(nodes);
        nodeActive  = 0;
        
        static __CursorSet = function(value) {
            if (is_undefined(value)) return;
            if (value != clamp(value, 0, array_length(nodes)-1)) return;
            __.cursor = value;
            return self;
        }
        static __CursorGet = function() {
            return __.cursor;
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
            for (var i = 0, n = array_length(nodes); i < n; i++) {
                var _node = nodes[i];
                if (_node.id == _id) {
                    var _flexDisp = flexpanel_node_style_get_display(root);
                    var _nodeDisp = (_node.visible ? flexpanel_display.flex : flexpanel_display.none);
                    if (_flexDisp != _nodeDisp) {
                        flexpanel_node_style_set_display(root, _nodeDisp);
                    }
                    _node.flexNode = root;
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
            var _root = layer_get_flexpanel_node(layer);
            var _layout = __FlexParse(_root);
            var _rootPos = flexpanel_node_layout_get_position(_root);
            flexpanel_calculate_layout(_root, _rootPos.width, _rootPos.height, _rootPos.direction);
            _layout = __FlexParse(_root);
            
            for (var i = 0, n = array_length(nodes); i < n; i++) {
                var _node = nodes[i];
                var _flex = _node.flexNode;
                if (_flex == undefined) continue;
                var _data = __FlexParse(_flex);
            
                for (var j = 0; j < array_length(_data); j++) {
                    array_push(_node.flexZones, _data[j]);
                }
            }
        }
    }
    
    __PageInit();
    
    // Methods
    static NodeGetActive = function() {
        return nodes[__.cursor];
    }
    
    static CursorFindFirst = function() {
        var _count = array_length(nodes);
        var _guard = 0;
        while (!nodes[__.cursor].interactive && _guard < _count) {
            __.cursor++;
            _guard++;
        }
    }
    
    static NodeFindFirst = function() {
        var _guard = 0;
        while (!__.nodeArray[__.nodeActive].interactive && _guard < __.nodeCount) {
            __.nodeActive++;
            _guard++;
        }
    }
    
    static Update = function(mouseActive){
        for (var i = 0; i < __.nodeCount; i++) {
            var _node = __.nodeArray[i];
            _node.Update(mouseActive ? undefined : (__.cursor == i));
        }
        __.ready = true;
    };
    static Render = function(){
        if (!__.ready) return;
        for (var i = 0; i < __.nodeCount; i++) {
            var _node   = nodes[i];
            _node.Render();
        }
        __.ready = false;
    };
    static Enter = function() {
        CursorFindFirst();
        for (var i = 0; i < __.nodeCount; i++) {
            var _node = __.nodeArray[i];
            _node.mng = mng;
            _node.Enter();
        }
    }
    static Leave = function(resetNode) {
        if (resetNode) __.nodeActive = 0;
        if (resetNode) __.cursor = 0;
        for (var i = 0; i < __.nodeCount; i++) {
            var _node = __.nodeArray[i];
            _node.Leave();
        }
    }
}
