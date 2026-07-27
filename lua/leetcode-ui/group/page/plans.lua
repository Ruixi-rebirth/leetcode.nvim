local cmd = require("leetcode.command")
local plan_mod = require("leetcode.api.study-plan")

local Title = require("leetcode-ui.lines.title")
local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Page = require("leetcode-ui.group.page")

local footer = require("leetcode-ui.lines.footer")
local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)
page:insert(Title({ "Menu" }, "Study Plans"))

local buttons = {}
for key, plan in pairs(plan_mod.plans) do
	buttons[#buttons + 1] = Button(plan.name, {
		icon = "",
		on_press = function()
			cmd.plan_open(key)
		end,
	})
end

-- sort alphabetically by key for consistent order
table.sort(buttons, function(a, b)
	return a._name < b._name
end)

local back = BackButton("menu")
buttons[#buttons + 1] = back

page:insert(Buttons(buttons))
page:insert(footer)

return page
