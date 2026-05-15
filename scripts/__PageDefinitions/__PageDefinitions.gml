
function MenuPageDelete(name) {
    var _cache = __MenuCache();
    delete _cache.pages[$ name];
}

function MenuPageDefine(name, layer, nodes) {
    var _cache = __MenuCache();
    _cache.pages[$ name] = {layer, nodes};
}

// Main
MenuPageDefine("page_main", "layerMain", [
    new MenuNodeText("main", "Main Menu", {bgColorBase : c_ltgray}),
    new MenuNodeButton("start", "Start", function(){
        show_debug_message(__style);
        room_goto(rm_game);
    }),
    new MenuNodeButton("continue", "Continue"),
    new MenuNodeButton("credits", "Credits"),
    new MenuNodeButton("options", "Options", function(){
        PagePush("page_options")
    }),
    new MenuNodeSeparator("sep"),
    new MenuNodeConfirm("exit", "Exit", function(){
        game_end()
    }, {message : "Exit Game?"}),
])

// Pause
MenuPageDefine("page_pause", "layerPause", [
    new MenuNodeText("pause", "Pause", {bgColorBase : c_ltgray}),
    new MenuNodeButton("resume", "Resume", function(){show_debug_message(__style)}),
    new MenuNodeButton("restart", "Restart"),
    new MenuNodeButton("options", "Options", function(){PagePush("page_options")}),
    new MenuNodeSeparator("sep"),
    new MenuNodeConfirm("exit", "Leave", function(){
        room_goto(rm_menu);
    }, {message : "Leave Game?"}),
])

// Options
MenuPageDefine("page_options", "layerOptions", [
    new MenuNodeText("options", "Options", {bgColorBase : c_ltgray}),
    new MenuNodeSelector("language", "Language", [
            ["English", "en_US"], 
            ["Português", "pt_BR"], 
            ["Español", "es_ES"]
        ], 
        function(){return global.options.language},
        function(v){global.options.language = v[1]}),
    new MenuNodeButton("audio", "Audio", function(){PagePush("page_audio")}),
    new MenuNodeButton("video", "Video", function(){PagePush("page_video")}),
    new MenuNodeConfirm("reset", "Reset", function(){}, {message: "Are You Sure?"}),
    new MenuNodeSeparator("sep"),
    new MenuNodeButton("back", "Back", function(){PagePop()})
])

// Audio
MenuPageDefine("page_audio", "layerAudio", [
    new MenuNodeText("audio", "Audio",{bgColorBase : c_ltgray}),
    new MenuNodeSlider("master", "Master", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 1, function(v){return string_format(v, 3, 0)+"%"}),
    new MenuNodeSlider("music", "Music", 
        function(){return global.options.audio.music},
        function(v){global.options.audio.music = v}, 0, 100, 1, function(v){return string_format(v, 3, 0)+"%"}),
    new MenuNodeSlider("sfx", "Effects", 
        function(){return global.options.audio.sfx},
        function(v){global.options.audio.sfx = v}, 0, 100, 1, function(v){return string_format(v, 3, 0)+"%"}),
    new MenuNodeSeparator("sep"),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
])

// Video
MenuPageDefine("page_video", "layerVideo", [
    new MenuNodeText("video", "Video", {bgColorBase : c_ltgray}),
    new MenuNodeSelector("display", "Display", [
            ["Windowed", 0],
            ["Fullscreen", 1],
            ["Borderless", 2]
        ], 
        function(){return global.options.video.display},
        function(v){global.options.video.display = v[1]}),
    new MenuNodeSelector("resolution", "Resolution", [
            ["640x360", 0],
            ["1280x720", 1],
            ["1920x1080", 2]
        ],
        function(){return global.options.video.resolution},
        function(v){global.options.video.resolution = v[1]}),
    new MenuNodeCheckbox("bloom", "Bloom",
        function(){return global.options.video.bloom},
        function(v){global.options.video.bloom = v}),
    new MenuNodeCheckbox("vsync", "VSync",
        function(){return global.options.video.vsync},
        function(v){global.options.video.vsync = v}),
    new MenuNodeSeparator("sep"),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
])