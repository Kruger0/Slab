
global.options = {
    audio : {
        master  : 50,
        music   : 50,
        sfx     : 50,
    },
    video : {
        display : 1,
        resolution : 1,
        bloom : true,
        vsync : false,
    },
    language : "pt_oBR",
}
global.debug = false;
scribble_font_set_default("fnt_test");

mainMenu = new MenuManager();
mainMenu.PageAdd(new MenuPage("main_menu", "layerMain", [
    new MenuNodeText("main", "Main Menu", {bgColorBase : c_ltgray}),
    new MenuNodeButton("start", "Start"),
    new MenuNodeButton("continue", "Continue"),
    new MenuNodeButton("options", "Options", function(){PagePush("menu_options")}),
    new MenuNodeButton("credits", "Credits"),
    new MenuNodeSeparator("sep"),
    new MenuNodeConfirm("exit", "Exit", function(){game_end()}, {message : "Exit Game?"}),
]))
mainMenu.PageAdd(new MenuPage("menu_options", "layerOptions", [
    new MenuNodeText("options", "Options", {bgColorBase : c_ltgray}),
    new MenuNodeSelector("language", "Language", 
        [
            ["English", "en_US"], 
            ["Português", "pt_BR"], 
            ["Español", "es_ES"]
        ], 
        function(){return global.options.language},
        function(v){global.options.language = v}),
    new MenuNodeButton("audio", "Audio", function(){PagePush("menu_audio")}),
    new MenuNodeButton("video", "Video", function(){PagePush("menu_video")}),
    new MenuNodeConfirm("reset", "Reset", function(){}, {message: "Are You Sure?"}),
    new MenuNodeSeparator("sep"),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_audio", "layerAudio", [
    new MenuNodeText("audio", "Audio",{bgColorBase : c_ltgray}),
    new MenuNodeSlider("master", "Master", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 5, function(v){return string_format(v, 3, 0)+"%"}),
    new MenuNodeSlider("music", "Music", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 5, function(v){return string_format(v, 3, 0)+"%"}),
    new MenuNodeSlider("sfx", "Effects", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 5, function(v){return string_format(v, 3, 0)+"%"}),
    new MenuNodeSeparator("sep"),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_video", "layerVideo", [
    new MenuNodeText("video", "Video", {bgColorBase : c_ltgray}),
    new MenuNodeSelector("display", "Display", 
        [
            ["Windowed", 0], 
            ["Fullscreen", 1], 
            ["Borderless", 2]
        ], 
        function(){return global.options.video.display},
        function(v){global.options.video.display = v[1]}),
    new MenuNodeSelector("resolution", "Resolution", 
        [
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
]))

mainMenu.PagePush("main_menu");
