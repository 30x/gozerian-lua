
 package = "lua-gozerian"
 version = "scm-2"
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
      ["lua-gozerian"] = "lib/resty/gozerian/index.lua"
    },
    install = {
      lua = {
        ["lib.init-weaver"] = "lib/resty/gozerian/lib/init-weaver.lua",
        ["lib.c"] = "lib/resty/gozerian/lib/c.lua",
        ["lib.weaver-body-filter"] = "lib/resty/gozerian/lib/weaver-body-filter.lua",
        ["lib.weaver-common"] = "lib/resty/gozerian/lib/weaver-common.lua",
        ["lib.weaver-header-filter"] = "lib/resty/gozerian/lib/weaver-header-filter.lua",
        ["lib.weaver-request"] = "lib/resty/gozerian/lib/weaver-request.lua"
      }
    }

 }