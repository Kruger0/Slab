
// ==================================================== STYLES

SlabStyleCreate("main", {
    colorBase: c_gray,
    colorFocused: c_yellow
})

SlabStyleCreate("text", {
    colorBase: c_dkgray,
    bgColorBase: c_ltgray,
})

SlabStyleCreate("button", {
    colorBase: c_aqua,
})

// ==================================================== PAGES

SlabPageDefine("page_main", "layerMain", [
    new SlabNodeText("main", "Main Menu", {style: "text"}),
    new SlabNodeButton("start", "Start", function(){
        show_debug_message(__id);
        room_goto(rm_game);
    }, {style: "button"}),
    new SlabNodeButton("continue", "Continue", function(){SetEnabled(false)}),
    new SlabNodeButton("credits", "Credits"),
    new SlabNodeButton("options", "Options", function(){
        PushPage("page_options");
    }),
    new SlabNodeSeparator("sep"),
    new SlabNodeConfirm("exit", "Exit", function(){
        game_end();
    }, {message : "Exit Game?"})
], {cycle: true})

SlabPageDefine("page_pause", "layerPause", [
    new SlabNodeText("pause", "Pause", {style: "text"}),
    new SlabNodeButton("resume", "Resume", function(){
        __manager.SetEnabled(false)
    }),
    new SlabNodeButton("restart", "Restart"),
    new SlabNodeButton("options", "Options", function(){PushPage("page_options")}),
    new SlabNodeSeparator("sep"),
    new SlabNodeConfirm("exit", "Leave", function(){
        room_goto(rm_menu);
    }, {message : "Leave Game?"}),
])

SlabPageDefine("page_options", "layerOptions", [
    new SlabNodeText("options", "Options", {style: "text"}),
    new SlabNodeSelector("language", "Language", [
            ["English", "en_US"], 
            ["Português", "pt_BR"], 
            ["Español", "es_ES"]
        ], 
        function(){return global.options.language},
        function(v){global.options.language = v[1]}),
    new SlabNodeButton("audio", "Audio", function(){PushPage("page_audio")}),
    new SlabNodeButton("video", "Video", function(){PushPage("page_video")}),
    new SlabNodeConfirm("reset", "Reset", function(){}, {message: "Are You Sure?"}),
    new SlabNodeSeparator("sep"),
    new SlabNodeButton("back", "Back", function(){PopPage()})
])

SlabPageDefine("page_audio", "layerAudio", [
    new SlabNodeText("audio", "Audio", {style: "text"}),
    new SlabNodeSlider("master", "Master", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 1, function(v){return string_format(v, 3, 0)+"%"}),
    new SlabNodeSlider("music", "Music", 
        function(){return global.options.audio.music},
        function(v){global.options.audio.music = v}, 0, 100, 1, function(v){return string_format(v, 3, 0)+"%"}),
    new SlabNodeSlider("sfx", "Effects", 
        function(){return global.options.audio.sfx},
        function(v){global.options.audio.sfx = v}, 0, 100, 1, function(v){return string_format(v, 3, 0)+"%"}),
    new SlabNodeSeparator("sep"),
    new SlabNodeButton("back", "Back", function(){PopPage()}),
])

SlabPageDefine("page_video", "layerVideo", [
    new SlabNodeText("video", "Video", {style: "text"}),
    new SlabNodeSelector("display", "Display", [
            ["Windowed", 0],
            ["Fullscreen", 1],
            ["Borderless", 2]
        ], 
        function(){return global.options.video.display},
        function(v){global.options.video.display = v[1]}),
    new SlabNodeSelector("resolution", "Resolution", [
            ["640x360", 0],
            ["1280x720", 1],
            ["1920x1080", 2]
        ],
        function(){return global.options.video.resolution},
        function(v){global.options.video.resolution = v[1]}),
    new SlabNodeCheckbox("bloom", "Bloom",
        function(){return global.options.video.bloom},
        function(v){global.options.video.bloom = v}),
    new SlabNodeCheckbox("vsync", "VSync",
        function(){return global.options.video.vsync},
        function(v){global.options.video.vsync = v}),
    new SlabNodeSeparator("sep"),
    new SlabNodeButton("back", "Back", function(){PopPage()}),
])
