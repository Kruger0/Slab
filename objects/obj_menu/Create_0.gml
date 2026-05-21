
mainMenu = new SlabManager({style: "main"})
    .AddPage("page_main")
    .AddPage("page_options")
    .AddPage("page_audio")
    .AddPage("page_video")

mainMenu.PushPage("page_main").SetEnabled(true);
