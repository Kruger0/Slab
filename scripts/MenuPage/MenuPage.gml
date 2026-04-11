
function MenuPage(name, layer, nodes, config = {}) constructor{
    self.name   = name;
    self.layer  = layer;
    self.nodes  = nodes;
    
    #region Public
    xPad    = config[$ "xPad"] ?? 32;
    yPad    = config[$ "yPad"] ?? 32;
    xMarg   = config[$ "xMarg"] ?? 32;
    yMarg   = config[$ "yMarg"] ?? 32;
    xFactor = config[$ "xFactor"] ?? 0;
    yFactor = config[$ "yFactor"] ?? 0;
    spacing = config[$ "spacing"] ?? 8;
    hAlign  = config[$ "hAlign"] ?? fa_center;
    vAlign  = config[$ "vAlign"] ?? fa_middle;
    cycle   = config[$ "cycle"] ?? true;
    hFill   = config[$ "hFill"] ?? true;
    vFill   = config[$ "vFill"] ?? true;
    enabled = config[$ "enabled"] ?? true;
    font    = config[$ "font"] ?? fnt_test;
    scale   = config[$ "scale"] ?? 1;
    #endregion
    
    #region Private
    cursor  = 0;
    #endregion
    
    // Startup
    __ = {};
    with (__) {
        FlexNode = function(type, id, x, y, z, w, h) constructor {
            self.type   = type;
            self.id     = id;
            self.x      = x;
            self.y      = y;
            self.z      = z;
            self.w      = w;
            self.h      = h;
        }
        
        FlexParse = method(other, function(root, data = []) {
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
                array_push(data, new __.FlexNode(_type, _id, _n.left, _n.top, _z, _n.width, _n.height));
            }
            
            // Continue
            var _childs = flexpanel_node_get_num_children(root);
            for (var i = 0; i < _childs; i++) {
                var _child = flexpanel_node_get_child(root, i);
                __.FlexParse(_child, data);
            }
            return data;
        });
    }
    
    // Layout
    
    
    // Methods
    static NodeGetActive = function() {
        return nodes[cursor];
    }
    
    static CursorFindFirst = function() {
        var _count = array_length(nodes);
        var _guard = 0;
        while (!nodes[cursor].interactive && _guard < _count) {
            cursor++;
            _guard++;
        }
    }
    
    static OnEnter = function(){
        
        var _root = layer_get_flexpanel_node(layer);
        var _layout = __.FlexParse(_root);
        var _rootPos = flexpanel_node_layout_get_position(_root);
        flexpanel_calculate_layout(_root, _rootPos.width, _rootPos.height, _rootPos.direction);
        _layout = __.FlexParse(_root);
    
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            var _flex = _node.flexNode;
            if (_flex == undefined) continue;
            var _data = __.FlexParse(_flex);
        
            for (var j = 0; j < array_length(_data); j++) {
                array_push(_node.flexZones, {
                    type    : _data[j].type,
                    x       : _data[j].x,
                    y       : _data[j].y,
                    z       : _data[j].z,
                    w       : _data[j].w,
                    h       : _data[j].h,
                })
            }
        }
        
        CursorFindFirst();
        
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.OnEnter();
            _node.mng = mng;
        }
    };
    static OnLeave = function(resetCursor){
        if (resetCursor) cursor = 0;
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.OnLeave();
        }
    };
    
    static Update = function(useMouse){
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node = nodes[i];
            _node.Update(useMouse ? undefined : (cursor == i));
        }
    };
    
    static Render = function(){
        for (var i = 0, n = array_length(nodes); i < n; i++) {
            var _node   = nodes[i];
            _node.Render();
        }
    };
}
