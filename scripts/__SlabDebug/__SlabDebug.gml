
function SlabDebugGetEnabled() {
    static cache = __SlabCache()
    return cache.debug;
}

function SlabDebugSetEnabled(enabled) {
    static cache = __SlabCache()
    cache.debug = enabled;
}

function __SlabTrace(msg) {
    show_debug_message($"[Slab] - {msg}")
}