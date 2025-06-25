local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PackStructure = require(ReplicatedStorage.Shared["genesis-protocol"].PackStructure)
local Rarities = require(ReplicatedStorage.Shared["genesis-protocol"].Rarities)
local RarityOrder = require(ReplicatedStorage.Shared["genesis-protocol"].RarityOrder)

function simulatePackOpenings(packType, numberOfPacks)
	local counts = {}
	local totalCards = 0

	-- Open packs
	for i = 1, numberOfPacks do
		local pack = openPack(packType)
		for _, rarity in pairs(pack) do
			counts[rarity] = (counts[rarity] or 0) + 1
			totalCards = totalCards + 1
		end
	end

	-- Calculate percentages
	local results = {}
	for rarity, count in pairs(counts) do
		results[rarity] = {
			count = count,
			percentage = (count / totalCards) * 100,
		}
	end

	return results
end

function openPack(packType)
	local pack = {}
	local structure = PackStructure[packType]

	-- Check for secret rare first
	if math.random() < structure.secretRareChance then
		table.insert(pack, "Secret Rare")
	end

	-- Add regular cards
	for _, slot in pairs(structure.slots) do
		for i = 1, slot.amount do
			local rarity = rollRarity(slot.baseRarity)
			table.insert(pack, rarity)
		end
	end

	return pack
end

function rollRarity(baseRarity)
	local info = RarityOrder[baseRarity]

	-- If this rarity can't be replaced, return it
	if not info.replacedBy or #info.replacedBy == 0 then
		return baseRarity
	end

	-- Build weighted list: base rarity + all replacements
	local options = { { baseRarity, Rarities[baseRarity].pullRate } }

	for _, replacement in pairs(info.replacedBy) do
		table.insert(options, { replacement, Rarities[replacement].pullRate })
	end

	-- Pick weighted random
	local totalWeight = 0
	for _, option in pairs(options) do
		totalWeight = totalWeight + option[2]
	end

	local roll = math.random() * totalWeight
	local current = 0

	for _, option in pairs(options) do
		current = current + option[2]
		if roll <= current then
			return option[1]
		end
	end

	return baseRarity
end

-- Function to simulate opening a single pack and show what's pulled
function openSinglePackDetailed(packType)
	local pack = {}
	local structure = PackStructure[packType]

	-- Check for secret rare first
	local hasSecret = false
	if math.random() <= structure.secretRareChance then
		hasSecret = true
		table.insert(pack, {
			slot = "Secret",
			rarity = "Secret Rare",
			upgraded = true,
		})
	end

	-- Add regular cards
	for slotIndex, slot in pairs(structure.slots) do
		for cardIndex = 1, slot.amount do
			local finalRarity = rollRarity(slot.baseRarity)
			local wasUpgraded = (finalRarity ~= slot.baseRarity)

			table.insert(pack, {
				slot = slot.baseRarity .. " Slot " .. cardIndex,
				rarity = finalRarity,
				upgraded = wasUpgraded,
			})
		end
	end

	return pack, hasSecret
end

-- Function to print pack opening results nicely
function printPackOpening(packType)
	print("Opening " .. packType .. " pack...")
	print("================================")

	local pack, hasSecret = openSinglePackDetailed(packType)

	if hasSecret then
		print("🌟 SECRET RARE PULLED! 🌟")
		print("")
	end

	for i, card in pairs(pack) do
		local symbol = ""
		if card.rarity == "Secret Rare" then
			symbol = "🌟"
		elseif card.upgraded then
			symbol = "⬆️"
		end

		print("Card " .. i .. ": " .. card.rarity .. " " .. symbol)
		if card.upgraded and card.rarity ~= "Secret Rare" then
			print("  (Upgraded from " .. string.match(card.slot, "(%w+) Slot") .. ")")
		end
	end

	print("================================")
	print("Total cards: " .. #pack)
end

-- Simulation
--printPackOpening("Genesis Protocol")
--[[
local pack, hasSecret = openSinglePackDetailed("Genesis Protocol")
print("Got secret rare:", hasSecret)
for i, card in pairs(pack) do
	print(i, card.rarity, card.upgraded)
end
]]
