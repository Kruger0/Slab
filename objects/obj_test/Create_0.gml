
global.debug = false;

#region MenuSystem Creation

scribble_font_set_default("fnt_test")

mainMenu = new MenuManager();
mainMenu.PageAdd(new MenuPage("test_menu", "layerBase", [
    new MenuNodeText("testText", "Main Menu", {background : c_dkgray}),
    new MenuNodeSeparator("testSep"),
    new MenuNodeButton("testButton0", "Test", function(){show_debug_message("test")}),
    new MenuNodeSelector("test_selector0", "Language", ["English", "Português", "Español", "Russian", "French"]),
    new MenuNodeSelector("test_selector1", "Fullscreen", ["On", "Off"]),
    new MenuNodeSlider("testSlider0", "Volume", -1, -1, 0, 100, 1, function(v){return v}),
    new MenuNodeCheckbox("testCheckbox0", "Check"),
    new MenuNodeConfirm("testConfirm0", "Confirm", function(){game_end()}),
]))

mainMenu.PagePush("test_menu");

#endregion




//mainMenu.PageAdd(new MenuPage("menu_options", [
//    new MenuNodeText("OPTIONS"),
//    new MenuNodeSeparator(""),
//    new MenuNodeSelector("Language", [["English", "en_US"],["Português", "pt_BR"]], function(option){show_debug_message($"Language set to {option[0]}")}),
//    new MenuNodeButton("Audio", function(){PagePush("menu_audio")}),
//    new MenuNodeButton("Video", function(){PagePush("menu_video")}),
//    new MenuNodeButton("Back", function(){PagePop()}),
//]))
//mainMenu.PageAdd(new MenuPage("menu_audio", [
//    new MenuNodeText("AUDIO"),
//    new MenuNodeSeparator(""),
//    new MenuNodeSlider("Master Volume"),
//    new MenuNodeSlider("Music Volume"),
//    new MenuNodeSlider("SFX Volume"),
//    new MenuNodeButton("Back", function(){PagePop()}),
//]))
//mainMenu.PageAdd(new MenuPage("menu_video", [
//    new MenuNodeText("VIDEO"),
//    new MenuNodeSeparator(""),
//    new MenuNodeToggle("Fullscreen"),
//    new MenuNodeSelector("Resolution", [["640x360", 0],["1280x720", 1],["1920x1080", 2]], function(option){show_debug_message($"Resolution set to {option[0]}")}),
//    new MenuNodeToggle("Bloom"),
//    new MenuNodeToggle("VSync"),
//    new MenuNodeButton("Back", function(){PagePop()}),
//]))

//var _container = flexpanel_node_get_child(_panel, "container")
//data = flexpanel_node_layout_get_position(_container)
//var _data = flexpanel_node_get_struct(_panel)
//_data = json_stringify(_data, true)
//show_debug_message(_data)
