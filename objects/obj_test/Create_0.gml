
global.options = {
    audio : {
        master  : 0.5,
        music   : 0.5,
        sfx     : 0.5,
    },
    video : {
        display : 0,
        resolution : 0,
    }
}
global.debug = false;
scribble_font_set_default("fnt_test");

mainMenu = new MenuManager();
mainMenu.PageAdd(new MenuPage("main_menu", "layerMain", [
    new MenuNodeText("main", "Main Menu", {background : c_dkgray}),
    //new MenuNodeSeparator(),
    new MenuNodeButton("start", "Start"),
    new MenuNodeButton("continue", "Continue"),
    new MenuNodeButton("options", "Options", function(){PagePush("menu_options")}),
    new MenuNodeButton("credits", "Credits"),
    new MenuNodeConfirm("exit", "Exit", function(){game_end()}),
]))
mainMenu.PageAdd(new MenuPage("menu_options", "layerOptions", [
    new MenuNodeText("options", "Options"),
    //new MenuNodeSeparator(),
    new MenuNodeSelector("language", "Language", [["English", "en_US"],["Português", "pt_BR"]], function(v){show_debug_message($"Language set to {v[1]}")}),
    new MenuNodeButton("audio", "Audio", function(){PagePush("menu_audio")}),
    new MenuNodeButton("video", "Video", function(){PagePush("menu_video")}),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_audio", "layerAudio", [
    new MenuNodeText("audio", "Audio"),
    //new MenuNodeSeparator(),
    new MenuNodeSlider("master", "Master Volume", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 1),
    new MenuNodeSlider("music", "Music Volume", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 1),
    new MenuNodeSlider("sfx", "SFX Volume", 
        function(){return global.options.audio.master},
        function(v){global.options.audio.master = v}, 0, 100, 1),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_video", "layerVideo", [
    new MenuNodeText("video", "Video"),
    //new MenuNodeSeparator(),
    new MenuNodeSelector("display", "Display", [["Windowed", 0], ["Fullscreen", 1], ["Borderless", 2]], function(v){global.options.video.display = v[1]}),
    new MenuNodeSelector("resolution", "Resolution", [["640x360", 0],["1280x720", 1],["1920x1080", 2]], function(v){global.options.video.resolution = v[1]}),
    new MenuNodeCheckbox("bloom", "Bloom"),
    new MenuNodeCheckbox("vsync", "VSync"),
    new MenuNodeButton("back", "Back", function(){PagePop()}),
]))

mainMenu.PagePush("main_menu");
