
/// @ignore
function __MenuCache() {
    static data = {
        pages:  {},
        styles: {},
    }
    return data;
}

if (debug_mode) {
    global.cache = __MenuCache()
}
