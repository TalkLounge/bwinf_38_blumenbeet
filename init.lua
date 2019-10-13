local max_farben = {"blau", "gelb", "grün", "orange", "rosa", "rot", "türkis"}
local meine_farben = {}

local function table_copy(tbl)
	local newtbl = {}
	for key, value in pairs(tbl) do
		newtbl[key] = value
	end
	return newtbl
end

local function table_search(tbl, search)
	for key, value in pairs(tbl) do
		if value == search then
			return key
		end
	end
	return -1
end

local function getVerfuegbareFarben()
	local farben = table_copy(max_farben)
	for key, value in pairs(meine_farben) do
		table.remove(farben, table_search(farben, value))
	end
	return farben
end

-- Farben einlesen
while true do
	print("Bitte Farben (verfügbare: ".. table.concat(getVerfuegbareFarben(), ",") ..") eingeben oder c für cancel: ")
	local farbe = io.read()
	if farbe:lower() == "c" then
		break
	elseif table_search(max_farben, farbe) == -1 then
		print("Bei der Farbe vertippt?")
	elseif table_search(meine_farben, farbe) ~= -1 then
		print("Farbe existiert bereits")
	else
		table.insert(meine_farben, farbe)
	end
end

-- Debug Ausgabe
print(table.concat(meine_farben, ","))

local function string_split(str, sep)
	if sep == nil then
		sep = "%s"
	end
	local tbl = {}
	for str in string.gmatch(str, "([^"..sep.."]+)") do
		table.insert(tbl, str)
	end
	return tbl
end

local meine_paare = {}

-- Paare einlesen
while true do
	print("Bitte gute Paare angeben (Bsp: rot grün 3) oder c für cancel: ")
	local paar = io.read()
	paar = string_split(paar, " ")
	if paar[1]:lower() == "c" then
		break
	elseif #paar ~= 3 then
		print("Falsche Eingabe?")
	elseif table_search(meine_farben, paar[1]) == -1 or table_search(meine_farben, paar[2]) == -1 then
		print("Farben stehen nicht zur Verfügung")
	elseif paar[1] == paar[2] then
		print("Müssen unterschiedliche Farben sein")
	elseif not tonumber(paar[3]) or (tonumber(paar[3]) ~= 1 and tonumber(paar[3]) ~= 2 and tonumber(paar[3]) ~= 3) then
		print("Zahl muss 1, 2 oder 3 sein")
	else
		local updated = false
		for key, value in pairs(meine_paare) do
			if (value.farbe1 == paar[1] and value.farbe2 == paar[2]) or (value.farbe1 == paar[2] and value.farbe2 == paar[1]) then
				updated = true
				meine_paare[key].punkt = tonumber(paar[3])
			end
		end
		if not updated then
			table.insert(meine_paare, {farbe1 = paar[1], farbe2 = paar[2], punkt = tonumber(paar[3])})
		end
	end
end

-- Debug Ausgabe
for key, value in pairs(meine_paare) do
	print(value.farbe1, value.farbe2, value.punkt)
end

local anzahlFarben = {}
local anzahlFarbenBisher = 0

for key, value in pairs(meine_farben) do
	anzahlFarbenBisher = anzahlFarbenBisher + math.floor(9 / #meine_farben)
	anzahlFarben[value] = math.floor(9 / #meine_farben)
end

while anzahlFarbenBisher < 9 do
	local farbeRandom = math.random(1, #meine_farben)
	local ran = math.random(0, 1)
	if ran >= 0.5 then
		anzahlFarbenBisher = anzahlFarbenBisher + 1
		anzahlFarben[meine_farben[farbeRandom]] = anzahlFarben[meine_farben[farbeRandom]] + 1
	end
end

-- Debug Ausgabe
for key, value in pairs(anzahlFarben) do
	print(key ..": ".. value)
end

local koord = {{}, {}, {}}

local function getKoord(x, y)
	if koord[x] then
		return koord[x][y]
	end
end

local function setKoord(x, y, str)
	koord[x][y] = str
end

local x = 1
local y = 1

for key, value in pairs(anzahlFarben) do
	for i = 1, value do
		setKoord(x, y, key)
		x = x + 1
		if x > 3 then
			x = 1
			y = y + 1
		end
	end
end

local function realLength(str)
	if str:find("ü") then
		return str:len() - 1
	else
		return str:len()
	end
end

local function stretch(str)
	return str .. string.rep(" ", 6 - realLength(str))
end

local function displayKoord()
	local formatted = string.format("%%%ds | %%%ds | %%%ds", 5, 5, 5)
	print("")
	for y = 1, 3 do
		print(string.format(formatted, stretch(getKoord(1, y)), stretch(getKoord(2, y)), stretch(getKoord(3, y))))
		if y ~= 3 then
			print("------------------------")
		end
	end
	print("")
end

displayKoord()

local function koordIterator()
	local x
	local y
	return function()
		if not x and not y then
			x = 1
			y = 1
		else
			x = x + 1
			if x > 3 then
				x = 1
				y = y + 1
				if y > 3 then
					x = nil
					y = nil
				end
			end
		end
		return x, y
	end
end

local function berechnePunkte()
	local function berechne(x, y, eigeneFarbe, punkte)
		for key, value in pairs(meine_paare) do
			local nachbarFarbe = getKoord(x, y)
			if not nachbarFarbe then
				break
			end
			if (value.farbe1 == eigeneFarbe and value.farbe2 == nachbarFarbe) or (value.farbe1 == nachbarFarbe and value.farbe2 == eigeneFarbe) then
				punkte = punkte + value.punkt
			end
		end
		return punkte
	end
	
	local punkte = 0
	for x, y in koordIterator() do
		local eigeneFarbe = getKoord(x, y)
		punkte = berechne(x + 1, y, eigeneFarbe, punkte)
		punkte = berechne(x + 1, y + 1, eigeneFarbe, punkte)
		punkte = berechne(x, y + 1, eigeneFarbe, punkte)
		punkte = berechne(x - 1, y + 1, eigeneFarbe, punkte)
	end
	print("Punkte: ".. punkte)
end

berechnePunkte()
