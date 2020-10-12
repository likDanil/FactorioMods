local searcher = require "searcher/searcher"
local main_searcher = searcher:new()
main_searcher:add_type_plugin(require "plugins/items/items")
main_searcher:add_search_plugin(require "plugins/items/item_container")

main_searcher:add_type_plugin(require "plugins/signals/signals")
main_searcher:add_search_plugin(require "plugins/signals/signals_search")
return main_searcher
