
function MenuPageDelete(name) {
    var _cache = __MenuCache();
    delete _cache.pages[$ name];
}

function MenuPageDefine(name, layer, nodes) {
    var _cache = __MenuCache();
    _cache.pages[$ name] = new MenuPage(name, layer, nodes);
    
    var _page = json_stringify(_cache.pages[$ name], true)
    show_debug_message(_page)
    
}

MenuPageDefine("page_main", "layerMain", [
    new MenuNodeText("main", "Main Menu", {bgColorBase : c_ltgray}),
    new MenuNodeButton("start", "Start"),
    new MenuNodeButton("continue", "Continue"),
    new MenuNodeButton("credits", "Credits"),
    //new MenuNodeButton("options", "Options", function(){PagePush("page_options")}),
    new MenuNodeSeparator("sep"),
    new MenuNodeConfirm("exit", "Exit", function(){game_end()}, {message : "Exit Game?"}),
])

