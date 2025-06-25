return {
	["Common"] = {
		base = true,
		replacedBy = {},
	},
	["Uncommon"] = {
		base = true,
		replacedBy = {},
	},
	["Rare"] = {
		base = true,
		replacedBy = { "Rainbow", "Nebula", "Mythic", "Singularity" },
	},
	["Rainbow"] = {
		base = false,
		subsetOf = "Rare",
	},
	["Nebula"] = {
		base = false,
		subsetOf = "Rare",
	},
	["Mythic"] = {
		base = false,
		subsetOf = "Rare",
	},
	["Singularity"] = {
		base = false,
		subsetOf = "Rare",
	},
	["Secret"] = {
		base = false,
		canReplaceAny = true, --Very low chance to override any slot.
	},
}
