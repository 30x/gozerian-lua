
 package = "lua-gozerian"
 version = "scm-1"
 source = {
    url = "git://github.com/30x/lua-gozerian"
 }
 description = {
    summary = "Call gozerian runtime from nginx/openresty",
    detailed = [[
      This module runs gozerian functions from ngx/openresty
    ]],
    homepage = "https://github.com/30x/lua-gozerian",
    license = "Apache-2.0"
 }
 dependencies = {
    "lua ~> 5.1"
 }
 build = {
    type = "builtin",
    modules = {
      gozerian = "lib/resty/gozerian/index.lua"
    }
 }