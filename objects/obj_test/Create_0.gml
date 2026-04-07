
global.debug = false;

mainMenu = new MenuManager();
mainMenu.PageAdd(new MenuPage("menu_main", [
    new MenuNodeLabel("MAIN MENU PAGE"),
    new MenuNodeSeparator(),
    new MenuNodeButton("Start", function(){show_debug_message("STARTING GAME")}),
    new MenuNodeButton("Continue"),
    new MenuNodeButton("Options", function(){PagePush("menu_options")}),
    new MenuNodeButton("Credits"),
    new MenuNodeConfirm("Exit", function(){game_end()}),
]))
mainMenu.PageAdd(new MenuPage("menu_options", [
    new MenuNodeLabel("OPTIONS"),
    new MenuNodeSeparator(),
    new MenuNodeSelector("Language"),
    new MenuNodeButton("Audio", function(){PagePush("menu_audio")}),
    new MenuNodeButton("Video", function(){PagePush("menu_video")}),
    new MenuNodeButton("Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_audio", [
    new MenuNodeLabel("AUDIO"),
    new MenuNodeSeparator(),
    new MenuNodeSlider("Master Volume"),
    new MenuNodeSlider("Music Volume"),
    new MenuNodeSlider("SFX Volume"),
    new MenuNodeButton("Back", function(){PagePop()}),
]))
mainMenu.PageAdd(new MenuPage("menu_video", [
    new MenuNodeLabel("VIDEO"),
    new MenuNodeSeparator(),
    new MenuNodeToggle("Fullscreen"),
    new MenuNodeSelector("Resolution"),
    new MenuNodeToggle("Bloom"),
    new MenuNodeToggle("VSync"),
    new MenuNodeButton("Back", function(){PagePop()}),
]))

mainMenu.PagePush("menu_main");
