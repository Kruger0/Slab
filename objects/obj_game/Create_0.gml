pauseMenu = new SlabManager({style : "style_1"})
    .AddPage("page_pause")
    .AddPage("page_options")
    .AddPage("page_audio")
    .AddPage("page_video")
    
pauseMenu.PushPage("page_pause");

global.pause = false;