pauseMenu = new MenuManager({style : "style_1"})
    .PageAdd("page_pause")
    .PageAdd("page_options")
    .PageAdd("page_audio")
    .PageAdd("page_video")
    
pauseMenu.PagePush("page_pause");

global.pause = false;