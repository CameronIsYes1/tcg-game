local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PackStructure = require(ReplicatedStorage.Shared["genesis-protocol"].PackStructure)
local Rarities = require(ReplicatedStorage.Shared["genesis-protocol"].Rarities)
local RarityOrder = require(ReplicatedStorage.Shared["genesis-protocol"].RarityOrder)

-- Pseudo function to simulate pack openings and calculate average pull rates
function simulatePackOpenings(packType, numberOfPacks)
	-- Initialize counters for each rarity
	local rarityCounts = {
		["Common"] = 0,
		["Uncommon"] = 0,
		["Rare"] = 0,
		["Rainbow"] = 0,
		["Nebula"] = 0,
		["Mythic"] = 0,
		["Singularity"] = 0,
		["Secret Rare"] = 0,
	}

	local totalCards = 0

	-- Get pack structure for the specified pack type
	local packStructure = PackStructure[packType]

	-- Simulate opening each pack
	for pack = 1, numberOfPacks do
		local packResults = openSinglePack(packStructure)

		-- Count the results from this pack
		for _, rarity in pairs(packResults) do
			rarityCounts[rarity] = rarityCounts[rarity] + 1
			totalCards = totalCards + 1
		end
	end

	-- Calculate percentages
	local pullRates = {}
	for rarity, count in pairs(rarityCounts) do
		pullRates[rarity] = {
			count = count,
			percentage = (count / totalCards) * 100,
		}
	end

	return pullRates, totalCards
end

function openSinglePack(packStructure)
	local packResults = {}

	-- First check for secret rare (can replace any slot)
	local hasSecretRare = false
	if math.random() <= packStructure.secretRareChance then
		hasSecretRare = true
		-- Remove one random slot and replace with Secret Rare
		local totalSlots = 0
		for _, slot in pairs(packStructure.slots) do
			totalSlots = totalSlots + slot.amount
		end
		local secretSlotPosition = math.random(1, totalSlots)
		table.insert(packResults, "Secret Rare")
	end

	-- Process each slot type in the pack
	for _, slotInfo in pairs(packStructure.slots) do
		local baseRarity = slotInfo.baseRarity
		local amount = slotInfo.amount

		-- If secret rare took one of these slots, reduce amount by 1
		if hasSecretRare then
			amount = amount - 1
			hasSecretRare = false -- Only reduce once
		end

		-- Generate cards for this slot type
		for i = 1, amount do
			local finalRarity = determineCardRarity(baseRarity)
			table.insert(packResults, finalRarity)
		end
	end

	return packResults
end

function determineCardRarity(baseRarity)
	-- Check if this rarity can be replaced by higher rarities
	local rarityInfo = RarityOrder[baseRarity]

	if rarityInfo and rarityInfo.replacedBy then
		-- Calculate total weight of replacement rarities
		local totalWeight = Rarities[baseRarity].pullRate

		for _, replacementRarity in pairs(rarityInfo.replacedBy) do
			totalWeight = totalWeight + Rarities[replacementRarity].pullRate
		end

		-- Generate random number and determine which rarity wins
		local roll = math.random() * totalWeight
		local currentWeight = 0

		-- Check base rarity first
		currentWeight = currentWeight + Rarities[baseRarity].pullRate
		if roll <= currentWeight then
			return baseRarity
		end

		-- Check replacement rarities
		for _, replacementRarity in pairs(rarityInfo.replacedBy) do
			currentWeight = currentWeight + Rarities[replacementRarity].pullRate
			if roll <= currentWeight then
				return replacementRarity
			end
		end
	end

	-- If no replacements possible, return base rarity
	return baseRarity
end

-- Simulation
local packs = 100000
local results, totalCards = simulatePackOpenings("Genesis Protocol", packs)
print(`Results from opening {packs} packs!`)
print("Total cards:", totalCards)
for rarity, data in pairs(results) do
	print(rarity .. ": " .. data.count .. " cards (" .. string.format("%.3f", data.percentage) .. "%)")
end
