local utils = require("leetcode.api.utils")
local queries = require("leetcode.api.queries")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc.StudyPlanApi
local StudyPlan = {}

---@class lc.StudyPlan.Plan
---@field slug string
---@field name string
---@field desc string

--- Known study plans. Add new plans here.
---@type table<string, lc.StudyPlan.Plan>
StudyPlan.plans = {
	hot100 = {
		slug = "top-100-liked",
		name = "Hot 100",
		desc = "LeetCode 热题 100",
	},
	top150 = {
		slug = "top-interview-150",
		name = "Top Interview 150",
		desc = "面试经典 150 题",
	},
	leetcode75 = {
		slug = "leetcode-75",
		name = "LeetCode 75",
		desc = "必知必会 75 题",
	},
	dynamic_programming = {
		slug = "dynamic-programming",
		name = "Dynamic Programming",
		desc = "动态规划精选题",
	},
	binary_search = {
		slug = "binary-search",
		name = "Binary Search",
		desc = "二分查找精选题",
	},
	graph_theory = {
		slug = "graph-theory",
		name = "Graph Theory",
		desc = "图论精选题",
	},
	premium_algo = {
		slug = "premium-algo-100",
		name = "Premium Algo 100",
		desc = "算法面试题汇总",
	},
}

--- Get a plan by its key
---@param key string
---@return lc.StudyPlan.Plan|nil
function StudyPlan.get_plan(key)
	return StudyPlan.plans[key]
end

--- Fetch study plan questions from API
---@param plan lc.StudyPlan.Plan
---@param cb fun(titles: table[], err: lc.err|nil)
function StudyPlan.fetch(plan, cb)
	local query = queries.study_plan

	utils.query(query, { planSlug = plan.slug }, {
		callback = function(res, err)
			if err then
				return cb(nil, err)
			end

			local detail = (res.data or {}).studyPlanV2Detail
			if not detail then
				return cb(nil, { msg = "study plan not found: " .. plan.slug })
			end

			-- flatten all subgroups into one list of titleSlugs
			local slugs = {}
			for _, subgroup in ipairs(detail.planSubGroups or {}) do
				for _, q in ipairs(subgroup.questions or {}) do
					slugs[q.titleSlug] = true
				end
			end

			-- match against cached problem list
			local problems = require("leetcode.cache.problemlist")
			local all = problems.get()
			local matched = {}
			for _, p in ipairs(all) do
				if slugs[p.title_slug] then
					matched[#matched + 1] = p
				end
			end

			log.info(("%s: %d problems"):format(plan.name, #matched))
			cb(matched)
		end,
	})
end

--- Open picker with study plan problems
---@param key string
function StudyPlan.open(key)
	local plan = StudyPlan.get_plan(key)
	if not plan then
		log.error(("Unknown study plan: %s"):format(key))
		return
	end

	require("leetcode.utils").auth_guard()

	StudyPlan.fetch(plan, function(problems, err)
		if err then
			return log.err(err)
		end

		local picker = require("leetcode.picker")
		picker.question(problems)
	end)
end

return StudyPlan
