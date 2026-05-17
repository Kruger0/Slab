
function MenuPageDelete(name) {
    static cache = __MenuCache();
    delete cache.pages[$ name];
}

function MenuPageDefine(name, layer, nodes, config = {}) {
    static cache = __MenuCache();
    cache.pages[$ name] = {layer, nodes, config};
}

MenuStyleCreate("text", {
    colorBase: c_dkgray,
    bgColorBase: c_ltgray
})


// Main
MenuPageDefine("page_main", "layerMain", [
    new MenuNodeText("main", "Main Menu", {style: "text"}),
    new MenuNodeButton("start", "Start", function(){
        show_debug_message(__id);
        room_goto(rm_game);
    }, {
        style: {
            colorBase: c_yellow,
        }
    }),
    new MenuNodeButton("continue", "Continue"),
    new MenuNodeButton("credits", "Credits"),
    new MenuNodeButton("options", "Options", function(){
        PushPage("page_options");
    }),
    new MenuNodeSeparator("sep"),
    new MenuNodeConfirm("exit", "Exit", function(){
        game_end();
    }, {
        message : "Exit Game?",
    })
])

// Pause
MenuPageDefine("page_pause", "layerPause", [
    new MenuNodeText("pause", "Pause", {style: "text"}),
    new MenuNodeButton("resume", "Resume", function(){
        __manager.SetEnabled(false)
    }),
    new MenuNodeButton("restart", "Restart"),
    new MenuNodeButton("options", "Options", function(){PushPage("page_options")}),
    new MenuNodeSeparator("sep"),
    new MenuNodeConfirm("exit", "Leave", function(){
        room_goto(rm_menu);
    }, {message : "Leave Game?"}),
])

// Options
MenuPageDefine("page_options", "layerOptions", [
    new MenuNodeText("options", "Options", {style: "text"}),
    new MenuNodeSelector("language", "Language", [
            ["English", "en_US"], 
            ["Português", "pt_BR"], 
            ["Español", "es_ES"]
        ], 
        function(){return global.options.language},
        function(v){global.options.language = v[1]}),
    new MenuNodeButton("audio", "Audio", function(){PushPage("page_audio")}),
    new MenuNodeButton("video", "Video", function(){PushPage("page_video")}),
    new MenuNodeConfirm("reset", "Reset", function(){}, {message: "Are You Sure?"}),
    new MenuNodeSeparator("sep"),
    new MenuNodeButton("back", "Back", function(){PopPage()})
])

// Audio
MenuPageDefine("page_audio", "layerAudio", [
    new MenuNodeText("audio", "Audio", {style: "text"}),
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
    new MenuNodeButton("back", "Back", function(){PopPage()}),
])

// Video
MenuPageDefine("page_video", "layerVideo", [
    new MenuNodeText("video", "Video", {style: "text"}),
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
    new MenuNodeButton("back", "Back", function(){PopPage()}),
])
