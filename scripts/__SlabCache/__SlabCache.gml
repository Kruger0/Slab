
/// @ignore
function __SlabCache() {
    static data = {
        debug:  false,
        pages:  {},
        styles: {},
    }
    return data;
}

if (debug_mode) {
    global.cache = __SlabCache()
}
