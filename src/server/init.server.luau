local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

-- Helper seguro para math.clamp que corrige min > max automÃ¡ticamente
local function safeClamp(value: number, a: number, b: number): number
    local lo = math.min(a, b)
    local hi = math.max(a, b)
    return math.clamp(value, lo, hi)
end

local TeamsData = {}

TeamsData.CLUBS = {
    {
        name = "Real Madriz",
        league = "LaLiga",
        tacticStyle = "Posesion",
        primaryColor = Color3.fromRGB(245, 245, 245),
        secondaryColor = Color3.fromRGB(212, 175, 55),
        tactic = {
            passThreshold = 1.0,
            shotThreshold = 80,
            pressIntensity = 0.7,
            preferShortPass = true,
            maxShotRange = 95,
        }
    },
    {
        name = "FC Barzelona",
        league = "LaLiga",
        tacticStyle = "Posesion",
        primaryColor = Color3.fromRGB(0, 77, 152),
        secondaryColor = Color3.fromRGB(165, 0, 68),
        tactic = {
            passThreshold = 0.9,
            shotThreshold = 82,
            pressIntensity = 0.75,
            preferShortPass = true,
            maxShotRange = 90,
        }
    },
    {
        name = "Manchester Citi",
        league = "Premier League",
        tacticStyle = "Posesion",
        primaryColor = Color3.fromRGB(108, 171, 221),
        secondaryColor = Color3.fromRGB(255, 255, 255),
        tactic = {
            passThreshold = 1.1,
            shotThreshold = 78,
            pressIntensity = 0.85,
            preferShortPass = true,
            maxShotRange = 100,
        }
    },
    {
        name = "Liverpool FC",
        league = "Premier League",
        tacticStyle = "PresionAlta",
        primaryColor = Color3.fromRGB(200, 16, 46),
        secondaryColor = Color3.fromRGB(0, 178, 169),
        tactic = {
            passThreshold = 1.4,
            shotThreshold = 72,
            pressIntensity = 0.95,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Arsenall",
        league = "Premier League",
        tacticStyle = "PresionAlta",
        primaryColor = Color3.fromRGB(219, 0, 7),
        secondaryColor = Color3.fromRGB(255, 255, 255),
        tactic = {
            passThreshold = 1.2,
            shotThreshold = 75,
            pressIntensity = 0.9,
            preferShortPass = true,
            maxShotRange = 105,
        }
    },
    {
        name = "Bayern Munik",
        league = "Bundesliga",
        tacticStyle = "PresionAlta",
        primaryColor = Color3.fromRGB(220, 5, 45),
        secondaryColor = Color3.fromRGB(0, 102, 178),
        tactic = {
            passThreshold = 1.3,
            shotThreshold = 74,
            pressIntensity = 0.95,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Borussia Dorntmund",
        league = "Bundesliga",
        tacticStyle = "Contraataque",
        primaryColor = Color3.fromRGB(253, 225, 0),
        secondaryColor = Color3.fromRGB(17, 17, 17),
        tactic = {
            passThreshold = 1.8,
            shotThreshold = 68,
            pressIntensity = 0.7,
            preferShortPass = false,
            maxShotRange = 120,
        }
    },
    {
        name = "Juvetus",
        league = "Serie A",
        tacticStyle = "BloqueBajo",
        primaryColor = Color3.fromRGB(25, 25, 25),
        secondaryColor = Color3.fromRGB(240, 240, 240),
        tactic = {
            passThreshold = 2.0,
            shotThreshold = 65,
            pressIntensity = 0.5,
            preferShortPass = false,
            maxShotRange = 110,
        }
    },
    {
        name = "Inter Milano",
        league = "Serie A",
        tacticStyle = "BloqueBajo",
        primaryColor = Color3.fromRGB(1, 42, 107),
        secondaryColor = Color3.fromRGB(17, 17, 17),
        tactic = {
            passThreshold = 1.9,
            shotThreshold = 68,
            pressIntensity = 0.55,
            preferShortPass = false,
            maxShotRange = 110,
        }
    },
    {
        name = "Paris Saint-Germane",
        league = "Ligue 1",
        tacticStyle = "BandasRapido",
        primaryColor = Color3.fromRGB(0, 30, 70),
        secondaryColor = Color3.fromRGB(218, 41, 28),
        tactic = {
            passThreshold = 1.3,
            shotThreshold = 70,
            pressIntensity = 0.8,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Ajaks",
        league = "Eredivisie",
        tacticStyle = "Posesion",
        primaryColor = Color3.fromRGB(225, 30, 45),
        secondaryColor = Color3.fromRGB(250, 250, 250),
        tactic = {
            passThreshold = 1.0,
            shotThreshold = 79,
            pressIntensity = 0.85,
            preferShortPass = true,
            maxShotRange = 95,
        }
    },
    {
        name = "Benfika",
        league = "Primeira Liga",
        tacticStyle = "Posesion",
        primaryColor = Color3.fromRGB(220, 20, 30),
        secondaryColor = Color3.fromRGB(255, 255, 255),
        tactic = {
            passThreshold = 1.1,
            shotThreshold = 76,
            pressIntensity = 0.8,
            preferShortPass = true,
            maxShotRange = 100,
        }
    },
    {
        name = "Flamengoo",
        league = "Brasileirao",
        tacticStyle = "BandasRapido",
        primaryColor = Color3.fromRGB(195, 20, 30),
        secondaryColor = Color3.fromRGB(20, 20, 20),
        tactic = {
            passThreshold = 1.2,
            shotThreshold = 72,
            pressIntensity = 0.75,
            preferShortPass = false,
            maxShotRange = 110,
        }
    },
    {
        name = "Boca Juniores",
        league = "Liga Argentina",
        tacticStyle = "PresionAlta",
        primaryColor = Color3.fromRGB(0, 55, 140),
        secondaryColor = Color3.fromRGB(255, 205, 0),
        tactic = {
            passThreshold = 1.5,
            shotThreshold = 70,
            pressIntensity = 0.95,
            preferShortPass = false,
            maxShotRange = 120,
        }
    },
    {
        name = "Al-Hilal Stars",
        league = "Saudi Pro League",
        tacticStyle = "BandasRapido",
        primaryColor = Color3.fromRGB(0, 80, 200),
        secondaryColor = Color3.fromRGB(255, 255, 255),
        tactic = {
            passThreshold = 1.3,
            shotThreshold = 71,
            pressIntensity = 0.8,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Atletiko Madriz",
        league = "LaLiga",
        tacticStyle = "BloqueBajo",
        primaryColor = Color3.fromRGB(210, 30, 40),
        secondaryColor = Color3.fromRGB(15, 30, 80),
        tactic = {
            passThreshold = 2.1,
            shotThreshold = 66,
            pressIntensity = 0.6,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Manchestar Utd",
        league = "Premier League",
        tacticStyle = "Contraataque",
        primaryColor = Color3.fromRGB(218, 2, 14),
        secondaryColor = Color3.fromRGB(255, 255, 255),
        tactic = {
            passThreshold = 1.6,
            shotThreshold = 70,
            pressIntensity = 0.75,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Portoo FC",
        league = "Primeira Liga",
        tacticStyle = "PresionAlta",
        primaryColor = Color3.fromRGB(0, 60, 160),
        secondaryColor = Color3.fromRGB(255, 255, 255),
        tactic = {
            passThreshold = 1.3,
            shotThreshold = 74,
            pressIntensity = 0.85,
            preferShortPass = false,
            maxShotRange = 110,
        }
    },
    {
        name = "AC Milann",
        league = "Serie A",
        tacticStyle = "Contraataque",
        primaryColor = Color3.fromRGB(200, 20, 20),
        secondaryColor = Color3.fromRGB(15, 15, 15),
        tactic = {
            passThreshold = 1.7,
            shotThreshold = 69,
            pressIntensity = 0.7,
            preferShortPass = false,
            maxShotRange = 115,
        }
    },
    {
        name = "Sevillia FC",
        league = "LaLiga",
        tacticStyle = "BandasRapido",
        primaryColor = Color3.fromRGB(235, 235, 235),
        secondaryColor = Color3.fromRGB(200, 25, 35),
        tactic = {
            passThreshold = 1.25,
            shotThreshold = 74,
            pressIntensity = 0.8,
            preferShortPass = false,
            maxShotRange = 105,
        }
    }
}

TeamsData.PLAYERS = {
    -- DELANTEROS (ST)
    {name = "Kylian MbappÃ©", role = "Delantero", posTag = "ST", speed = 98, shot = 94, pass = 82, defense = 38, dribble = 93, stamina = 89, control = 92, physical = 78},
    {name = "Erling Haaland", role = "Delantero", posTag = "ST", speed = 91, shot = 96, pass = 68, defense = 45, dribble = 80, stamina = 88, control = 85, physical = 91},
    {name = "Lionel Messi", role = "Delantero", posTag = "ST", speed = 82, shot = 95, pass = 94, defense = 35, dribble = 96, stamina = 75, control = 97, physical = 66},
    {name = "Cristiano Ronaldo", role = "Delantero", posTag = "ST", speed = 84, shot = 95, pass = 78, defense = 36, dribble = 82, stamina = 79, control = 88, physical = 84},
    {name = "VinÃ­cius JÃºnior", role = "Delantero", posTag = "ST", speed = 97, shot = 88, pass = 82, defense = 34, dribble = 95, stamina = 87, control = 93, physical = 70},
    {name = "Robert Lewandowski", role = "Delantero", posTag = "ST", speed = 76, shot = 93, pass = 80, defense = 42, dribble = 84, stamina = 79, control = 89, physical = 83},
    {name = "Harry Kane", role = "Delantero", posTag = "ST", speed = 73, shot = 95, pass = 88, defense = 48, dribble = 83, stamina = 83, control = 89, physical = 84},
    {name = "Mohamed Salah", role = "Delantero", posTag = "ST", speed = 92, shot = 91, pass = 84, defense = 45, dribble = 90, stamina = 86, control = 89, physical = 76},
    {name = "Lamine Yamal", role = "Delantero", posTag = "ST", speed = 92, shot = 85, pass = 87, defense = 36, dribble = 92, stamina = 84, control = 90, physical = 68},
    {name = "Lautaro MartÃ­nez", role = "Delantero", posTag = "ST", speed = 83, shot = 90, pass = 76, defense = 48, dribble = 86, stamina = 86, control = 87, physical = 84},
    {name = "Victor Osimhen", role = "Delantero", posTag = "ST", speed = 90, shot = 88, pass = 66, defense = 42, dribble = 80, stamina = 84, control = 82, physical = 85},
    {name = "JuliÃ¡n Ãlvarez", role = "Delantero", posTag = "ST", speed = 86, shot = 88, pass = 82, defense = 55, dribble = 85, stamina = 90, control = 87, physical = 78},
    {name = "Antoine Griezmann", role = "Delantero", posTag = "ST", speed = 80, shot = 88, pass = 89, defense = 60, dribble = 87, stamina = 88, control = 89, physical = 74},
    {name = "Rodrygo Goes", role = "Delantero", posTag = "ST", speed = 90, shot = 85, pass = 82, defense = 38, dribble = 89, stamina = 83, control = 88, physical = 68},
    {name = "Rafael LeÃ£o", role = "Delantero", posTag = "ST", speed = 94, shot = 84, pass = 79, defense = 32, dribble = 91, stamina = 81, control = 88, physical = 79},
    {name = "Son Heung-min", role = "Delantero", posTag = "ST", speed = 88, shot = 90, pass = 82, defense = 44, dribble = 85, stamina = 84, control = 86, physical = 72},
    {name = "Bukayo Saka", role = "Delantero", posTag = "ST", speed = 87, shot = 85, pass = 84, defense = 58, dribble = 88, stamina = 87, control = 87, physical = 76},
    {name = "Darwin NÃºÃ±ez", role = "Delantero", posTag = "ST", speed = 91, shot = 84, pass = 72, defense = 46, dribble = 78, stamina = 86, control = 80, physical = 88},
    {name = "Neymar Jr", role = "Delantero", posTag = "ST", speed = 85, shot = 87, pass = 88, defense = 34, dribble = 94, stamina = 70, control = 94, physical = 63},
    {name = "Karim Benzema", role = "Delantero", posTag = "ST", speed = 78, shot = 90, pass = 84, defense = 40, dribble = 86, stamina = 76, control = 90, physical = 78},

    -- CENTROCAMPISTAS (CM)
    {name = "Kevin De Bruyne", role = "Central", posTag = "CM", speed = 74, shot = 88, pass = 95, defense = 65, dribble = 86, stamina = 82, control = 92, physical = 75},
    {name = "Jude Bellingham", role = "Central", posTag = "CM", speed = 83, shot = 87, pass = 86, defense = 80, dribble = 88, stamina = 92, control = 90, physical = 85},
    {name = "Rodri HernÃ¡ndez", role = "Central", posTag = "CM", speed = 68, shot = 82, pass = 90, defense = 89, dribble = 82, stamina = 93, control = 89, physical = 86},
    {name = "Luka ModriÄ‡", role = "Central", posTag = "CM", speed = 72, shot = 80, pass = 91, defense = 72, dribble = 88, stamina = 78, control = 92, physical = 67},
    {name = "Federico Valverde", role = "Central", posTag = "CM", speed = 90, shot = 85, pass = 84, defense = 80, dribble = 84, stamina = 96, control = 86, physical = 83},
    {name = "Pedri GonzÃ¡lez", role = "Central", posTag = "CM", speed = 78, shot = 76, pass = 90, defense = 70, dribble = 90, stamina = 84, control = 92, physical = 68},
    {name = "Martin Ã˜degaard", role = "Central", posTag = "CM", speed = 77, shot = 83, pass = 91, defense = 62, dribble = 89, stamina = 87, control = 91, physical = 68},
    {name = "Bernardo Silva", role = "Central", posTag = "CM", speed = 78, shot = 80, pass = 89, defense = 68, dribble = 92, stamina = 93, control = 92, physical = 69},
    {name = "Declan Rice", role = "Central", posTag = "CM", speed = 76, shot = 74, pass = 83, defense = 88, dribble = 79, stamina = 93, control = 83, physical = 86},
    {name = "Toni Kroos", role = "Central", posTag = "CM", speed = 60, shot = 83, pass = 94, defense = 72, dribble = 81, stamina = 75, control = 92, physical = 70},
    {name = "Eduardo Camavinga", role = "Central", posTag = "CM", speed = 84, shot = 73, pass = 83, defense = 82, dribble = 84, stamina = 88, control = 86, physical = 81},
    {name = "NicolÃ² Barella", role = "Central", posTag = "CM", speed = 81, shot = 78, pass = 85, defense = 78, dribble = 85, stamina = 94, control = 86, physical = 76},
    {name = "Bruno Fernandes", role = "Central", posTag = "CM", speed = 75, shot = 86, pass = 90, defense = 68, dribble = 83, stamina = 92, control = 87, physical = 75},
    {name = "Frenkie de Jong", role = "Central", posTag = "CM", speed = 82, shot = 72, pass = 87, defense = 77, dribble = 89, stamina = 87, control = 90, physical = 78},
    {name = "Alexis Mac Allister", role = "Central", posTag = "CM", speed = 74, shot = 80, pass = 86, defense = 76, dribble = 83, stamina = 86, control = 86, physical = 75},
    {name = "AurÃ©lien TchouamÃ©ni", role = "Central", posTag = "CM", speed = 74, shot = 75, pass = 82, defense = 85, dribble = 79, stamina = 88, control = 83, physical = 85},
    {name = "Gavi PÃ¡ez", role = "Central", posTag = "CM", speed = 78, shot = 70, pass = 81, defense = 76, dribble = 84, stamina = 92, control = 84, physical = 74},
    {name = "Hakan Ã‡alhanoÄŸlu", role = "Central", posTag = "CM", speed = 70, shot = 85, pass = 89, defense = 74, dribble = 82, stamina = 84, control = 86, physical = 73},
    {name = "Enzo FernÃ¡ndez", role = "Central", posTag = "CM", speed = 72, shot = 78, pass = 86, defense = 75, dribble = 81, stamina = 85, control = 85, physical = 77},
    {name = "N'Golo KantÃ©", role = "Central", posTag = "CM", speed = 78, shot = 66, pass = 78, defense = 87, dribble = 80, stamina = 93, control = 82, physical = 80},

    -- DEFENSAS (DEF)
    {name = "Virgil van Dijk", role = "Defensa", posTag = "DEF", speed = 80, shot = 60, pass = 74, defense = 92, dribble = 72, stamina = 85, control = 81, physical = 91},
    {name = "RÃºben Dias", role = "Defensa", posTag = "DEF", speed = 73, shot = 45, pass = 72, defense = 90, dribble = 69, stamina = 88, control = 78, physical = 89},
    {name = "Antonio RÃ¼diger", role = "Defensa", posTag = "DEF", speed = 88, shot = 55, pass = 71, defense = 87, dribble = 68, stamina = 89, control = 76, physical = 90},
    {name = "William Saliba", role = "Defensa", posTag = "DEF", speed = 82, shot = 42, pass = 74, defense = 88, dribble = 72, stamina = 86, control = 80, physical = 85},
    {name = "Marquinhos AoÃ¡s", role = "Defensa", posTag = "DEF", speed = 78, shot = 53, pass = 75, defense = 88, dribble = 74, stamina = 84, control = 80, physical = 82},
    {name = "Alessandro Bastoni", role = "Defensa", posTag = "DEF", speed = 75, shot = 50, pass = 82, defense = 87, dribble = 76, stamina = 83, control = 82, physical = 84},
    {name = "Ronald AraÃºjo", role = "Defensa", posTag = "DEF", speed = 84, shot = 50, pass = 66, defense = 87, dribble = 64, stamina = 84, control = 73, physical = 88},
    {name = "Ã‰der MilitÃ£o", role = "Defensa", posTag = "DEF", speed = 85, shot = 52, pass = 70, defense = 86, dribble = 71, stamina = 85, control = 77, physical = 84},
    {name = "Theo HernÃ¡ndez", role = "Defensa", posTag = "DEF", speed = 94, shot = 74, pass = 78, defense = 80, dribble = 84, stamina = 90, control = 82, physical = 84},
    {name = "Kyle Walker", role = "Defensa", posTag = "DEF", speed = 92, shot = 63, pass = 77, defense = 82, dribble = 78, stamina = 86, control = 79, physical = 84},
    {name = "Trent Alexander-Arnold", role = "Defensa", posTag = "DEF", speed = 78, shot = 76, pass = 91, defense = 76, dribble = 81, stamina = 85, control = 85, physical = 74},
    {name = "Dani Carvajal", role = "Defensa", posTag = "DEF", speed = 82, shot = 58, pass = 79, defense = 84, dribble = 80, stamina = 88, control = 82, physical = 82},
    {name = "Achraf Hakimi", role = "Defensa", posTag = "DEF", speed = 93, shot = 75, pass = 80, defense = 78, dribble = 83, stamina = 89, control = 82, physical = 78},
    {name = "Alphonso Davies", role = "Defensa", posTag = "DEF", speed = 95, shot = 68, pass = 78, defense = 76, dribble = 86, stamina = 86, control = 83, physical = 78},
    {name = "Jules KoundÃ©", role = "Defensa", posTag = "DEF", speed = 84, shot = 48, pass = 74, defense = 86, dribble = 75, stamina = 84, control = 79, physical = 81},
    {name = "Gabriel MagalhÃ£es", role = "Defensa", posTag = "DEF", speed = 72, shot = 45, pass = 69, defense = 86, dribble = 65, stamina = 85, control = 74, physical = 87},
    {name = "Josko Gvardiol", role = "Defensa", posTag = "DEF", speed = 80, shot = 65, pass = 78, defense = 84, dribble = 79, stamina = 85, control = 81, physical = 85},
    {name = "Cristian Romero", role = "Defensa", posTag = "DEF", speed = 76, shot = 48, pass = 68, defense = 85, dribble = 66, stamina = 85, control = 73, physical = 86},
    {name = "Lisandro MartÃ­nez", role = "Defensa", posTag = "DEF", speed = 76, shot = 55, pass = 80, defense = 84, dribble = 76, stamina = 84, control = 80, physical = 82},
    {name = "Federico Dimarco", role = "Defensa", posTag = "DEF", speed = 82, shot = 76, pass = 85, defense = 77, dribble = 81, stamina = 86, control = 84, physical = 74},

    -- PORTEROS (GK)
    {name = "Thibaut Courtois", role = "Portero", posTag = "GK", speed = 55, shot = 35, pass = 74, defense = 91, dribble = 50, stamina = 80, control = 78, physical = 86},
    {name = "Alisson Becker", role = "Portero", posTag = "GK", speed = 58, shot = 35, pass = 85, defense = 90, dribble = 55, stamina = 82, control = 82, physical = 85},
    {name = "Marc-AndrÃ© ter Stegen", role = "Portero", posTag = "GK", speed = 56, shot = 32, pass = 88, defense = 89, dribble = 54, stamina = 80, control = 83, physical = 80},
    {name = "Ederson Moraes", role = "Portero", posTag = "GK", speed = 64, shot = 40, pass = 93, defense = 88, dribble = 65, stamina = 82, control = 85, physical = 82},
    {name = "Jan Oblak", role = "Portero", posTag = "GK", speed = 54, shot = 30, pass = 72, defense = 90, dribble = 48, stamina = 80, control = 77, physical = 84},
    {name = "Mike Maignan", role = "Portero", posTag = "GK", speed = 58, shot = 33, pass = 84, defense = 88, dribble = 56, stamina = 82, control = 81, physical = 83},
    {name = "Gianluigi Donnarumma", role = "Portero", posTag = "GK", speed = 54, shot = 30, pass = 75, defense = 89, dribble = 50, stamina = 80, control = 78, physical = 86},
    {name = "Emiliano MartÃ­nez", role = "Portero", posTag = "GK", speed = 56, shot = 33, pass = 80, defense = 88, dribble = 52, stamina = 83, control = 80, physical = 85},
    {name = "Yassine Bounou", role = "Portero", posTag = "GK", speed = 55, shot = 30, pass = 77, defense = 86, dribble = 52, stamina = 80, control = 78, physical = 82},
    {name = "David Raya", role = "Portero", posTag = "GK", speed = 60, shot = 35, pass = 86, defense = 85, dribble = 58, stamina = 82, control = 82, physical = 78}
}

function TeamsData.CalculateRarity(p)
    local overall = math.floor((p.speed + p.shot + p.pass + p.defense + p.dribble + p.stamina + p.control + p.physical) / 8)
    p.overall = overall
    if overall >= 88 then
        p.rarity = "Diamante"
        p.rarityIcon = "â—†"
        p.rarityColor = Color3.fromRGB(0, 200, 255)
    elseif overall >= 80 then
        p.rarity = "Oro"
        p.rarityIcon = "â˜…"
        p.rarityColor = Color3.fromRGB(255, 215, 0)
    elseif overall >= 72 then
        p.rarity = "Plata"
        p.rarityIcon = "â—"
        p.rarityColor = Color3.fromRGB(205, 205, 215)
    else
        p.rarity = "Bronce"
        p.rarityIcon = "â—"
        p.rarityColor = Color3.fromRGB(195, 120, 60)
    end
    return p
end

for _, p in ipairs(TeamsData.PLAYERS) do
    TeamsData.CalculateRarity(p)
end

-- Base de datos inicializada



print("==========================================================================")
print("[SERVIDOR] Futbol Total Avanzado: 10 Grandes Ligas, IA TÃ¡ctica y Rarezas")
print("==========================================================================")

--------------------------------------------------------------------------------
-- 1. CONFIGURACIÃ“N DE COLISIONES
--------------------------------------------------------------------------------
pcall(function()
    PhysicsService:RegisterCollisionGroup("CharactersGroup")
    PhysicsService:RegisterCollisionGroup("SoccerBallGroup")
    PhysicsService:CollisionGroupSetCollidable("SoccerBallGroup", "CharactersGroup", false)
    PhysicsService:CollisionGroupSetCollidable("SoccerBallGroup", "Default", true)
    -- Los jugadores colisionan entre sÃ­ sÃ³lidamente para no traspasarse ni montarse unos sobre otros
    PhysicsService:CollisionGroupSetCollidable("CharactersGroup", "CharactersGroup", true)
end)

local function setupCharacterCollision(character: Model)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CollisionGroup = "CharactersGroup"
            end)
        end
    end
    character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            pcall(function()
                descendant.CollisionGroup = "CharactersGroup"
            end)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupCharacterCollision)
    if player.Character then
        setupCharacterCollision(player.Character)
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        setupCharacterCollision(p.Character)
    end
end

--------------------------------------------------------------------------------
-- 2. CONSTRUCCIÃ“N DEL GRAN ESTADIO REGLAMENTARIO (300 x 200 STUDS)
--------------------------------------------------------------------------------
local FIELD_SIZE = Vector2.new(300, 200)
local WALL_HEIGHT = 28
local WALL_THICKNESS = 3

-- PorterÃ­a: 22 studs de ancho por 12 studs de alto (medidas interiores)
local GOAL_WIDTH = 22
local GOAL_HEIGHT = 12
local GOAL_DEPTH = 14

-- Ãrea grande (Penal): 50 studs de ancho por 25 studs de profundidad
local PENALTY_AREA_DEPTH = 25
local PENALTY_AREA_WIDTH = 50

-- Ãrea pequeÃ±a (Meta): 20 studs de ancho por 10 studs de profundidad
local GOAL_AREA_DEPTH = 10
local GOAL_AREA_WIDTH = 20

-- Punto de penal: Ubicado a 35 studs de la lÃ­nea de meta
local PENALTY_SPOT_DIST = 35

-- CÃ­rculo central: Radio de 30 studs
local CENTER_CIRCLE_RADIUS = 30

-- Margen exterior de 15 studs
local FIELD_MARGIN = 15

local FIELD_Y = 0.51

local pitchFolder = workspace:FindFirstChild("SoccerPitch")
if pitchFolder then
    pitchFolder:Destroy()
end
pitchFolder = Instance.new("Folder")
pitchFolder.Name = "SoccerPitch"
pitchFolder.Parent = workspace

local function createFieldPart(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material, transparency: number?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = pitchFolder
    return p
end

local function createFieldLine(name: string, size: Vector3, position: Vector3): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = Color3.fromRGB(245, 245, 245)
    p.Material = Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = pitchFolder
    return p
end

-- CÃ©sped principal (300 x 200 studs) y margen exterior (15 studs a cada lado)
createFieldPart("CespedePrincipal", Vector3.new(FIELD_SIZE.X, 1, FIELD_SIZE.Y), Vector3.new(0, 0, 0), Color3.fromRGB(38, 140, 52), Enum.Material.Grass)
createFieldPart("BandaExterior", Vector3.new(FIELD_SIZE.X + (FIELD_MARGIN * 2), 0.95, FIELD_SIZE.Y + (FIELD_MARGIN * 2)), Vector3.new(0, -0.05, 0), Color3.fromRGB(32, 115, 42), Enum.Material.Grass)

local halfX = FIELD_SIZE.X / 2
local halfY = FIELD_SIZE.Y / 2
local lineThick = 1.0
local lineH = 0.02

createFieldLine("LineaBandaNorte", Vector3.new(FIELD_SIZE.X, lineH, lineThick), Vector3.new(0, FIELD_Y, -halfY))
createFieldLine("LineaBandaSur", Vector3.new(FIELD_SIZE.X, lineH, lineThick), Vector3.new(0, FIELD_Y, halfY))
createFieldLine("LineaFondoOeste", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(-halfX, FIELD_Y, 0))
createFieldLine("LineaFondoEste", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(halfX, FIELD_Y, 0))
createFieldLine("LineaCentro", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(0, FIELD_Y, 0))

-- AroCentralHueco con orientaciÃ³n CFrame en X = 90 grados
local ringMeshPart = Instance.new("Part")
ringMeshPart.Name = "AroCentralHueco"
ringMeshPart.Size = Vector3.new(CENTER_CIRCLE_RADIUS * 2, lineH, CENTER_CIRCLE_RADIUS * 2)
ringMeshPart.CFrame = CFrame.new(0, FIELD_Y, 0) * CFrame.Angles(math.rad(90), 0, 0)
ringMeshPart.Color = Color3.fromRGB(245, 245, 245)
ringMeshPart.Material = Enum.Material.SmoothPlastic
ringMeshPart.Anchored = true
ringMeshPart.CanCollide = false
ringMeshPart.Parent = pitchFolder

local ringSpecialMesh = Instance.new("SpecialMesh")
ringSpecialMesh.MeshType = Enum.MeshType.FileMesh
ringSpecialMesh.MeshId = "rbxassetid://3270017"
ringSpecialMesh.Scale = Vector3.new(CENTER_CIRCLE_RADIUS, CENTER_CIRCLE_RADIUS, 0.02)
ringSpecialMesh.Parent = ringMeshPart

-- Punto central en coordenada (0, 0) relativa al centro
local centerDot = Instance.new("Part")
centerDot.Name = "PuntoCentralBalon"
centerDot.Shape = Enum.PartType.Cylinder
centerDot.Size = Vector3.new(lineH, 2.0, 2.0)
centerDot.CFrame = CFrame.new(0, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
centerDot.Color = Color3.fromRGB(245, 245, 245)
centerDot.Material = Enum.Material.SmoothPlastic
centerDot.Anchored = true
centerDot.CanCollide = false
centerDot.Parent = pitchFolder

-- Arcos de cÃ³rner en las 4 esquinas (radio de 3 studs)
local function makeCornerArc(name: string, posX: number, posZ: number)
    local corner = Instance.new("Part")
    corner.Name = name
    corner.Shape = Enum.PartType.Cylinder
    corner.Size = Vector3.new(lineH, 6, 6)
    corner.CFrame = CFrame.new(posX, FIELD_Y, posZ) * CFrame.Angles(0, 0, math.rad(90))
    corner.Color = Color3.fromRGB(245, 245, 245)
    corner.Material = Enum.Material.SmoothPlastic
    corner.Anchored = true
    corner.CanCollide = false
    corner.Parent = pitchFolder
end

makeCornerArc("CornerNW", -halfX, -halfY)
makeCornerArc("CornerNE", halfX, -halfY)
makeCornerArc("CornerSW", -halfX, halfY)
makeCornerArc("CornerSE", halfX, halfY)

local function buildGoalAreas(sideSign: number, teamTag: string)
    local goalLineX = halfX * sideSign
    local inwardDir = -sideSign

    local pAreaFrontX = goalLineX + (inwardDir * PENALTY_AREA_DEPTH)
    local pAreaCenterX = goalLineX + (inwardDir * (PENALTY_AREA_DEPTH / 2))
    createFieldLine("AreaGrande_Front_" .. teamTag, Vector3.new(lineThick, lineH, PENALTY_AREA_WIDTH), Vector3.new(pAreaFrontX, FIELD_Y, 0))
    createFieldLine("AreaGrande_Top_" .. teamTag, Vector3.new(PENALTY_AREA_DEPTH, lineH, lineThick), Vector3.new(pAreaCenterX, FIELD_Y, -PENALTY_AREA_WIDTH/2))
    createFieldLine("AreaGrande_Bottom_" .. teamTag, Vector3.new(PENALTY_AREA_DEPTH, lineH, lineThick), Vector3.new(pAreaCenterX, FIELD_Y, PENALTY_AREA_WIDTH/2))

    local gAreaFrontX = goalLineX + (inwardDir * GOAL_AREA_DEPTH)
    local gAreaCenterX = goalLineX + (inwardDir * (GOAL_AREA_DEPTH / 2))
    createFieldLine("AreaPequena_Front_" .. teamTag, Vector3.new(lineThick, lineH, GOAL_AREA_WIDTH), Vector3.new(gAreaFrontX, FIELD_Y, 0))
    createFieldLine("AreaPequena_Top_" .. teamTag, Vector3.new(GOAL_AREA_DEPTH, lineH, lineThick), Vector3.new(gAreaCenterX, FIELD_Y, -GOAL_AREA_WIDTH/2))
    createFieldLine("AreaPequena_Bottom_" .. teamTag, Vector3.new(GOAL_AREA_DEPTH, lineH, lineThick), Vector3.new(gAreaCenterX, FIELD_Y, GOAL_AREA_WIDTH/2))

    local penaltySpotX = goalLineX + (inwardDir * PENALTY_SPOT_DIST)
    local penSpot = Instance.new("Part")
    penSpot.Name = "PuntoPenalti_" .. teamTag
    penSpot.Shape = Enum.PartType.Cylinder
    penSpot.Size = Vector3.new(lineH, 1.8, 1.8)
    penSpot.CFrame = CFrame.new(penaltySpotX, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
    penSpot.Color = Color3.fromRGB(245, 245, 245)
    penSpot.Material = Enum.Material.SmoothPlastic
    penSpot.Anchored = true
    penSpot.CanCollide = false
    penSpot.Parent = pitchFolder
end

buildGoalAreas(-1, "Azul")
buildGoalAreas(1, "Rojo")

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("SpawnLocation") then
        obj.Transparency = 1
        obj.CanCollide = false
        local decal = obj:FindFirstChildOfClass("Decal")
        if decal then decal.Transparency = 1 end
    end
end
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("SpawnLocation") then
        obj.Transparency = 1
        obj.CanCollide = false
        local decal = obj:FindFirstChildOfClass("Decal")
        if decal then decal.Transparency = 1 end
    end
end)

local wallY = WALL_HEIGHT / 2
local totalX = FIELD_SIZE.X + (FIELD_MARGIN * 2)
local totalY = FIELD_SIZE.Y + (FIELD_MARGIN * 2)
-- Paredes de cristal eliminadas a peticiÃ³n del usuario para permitir juego abierto y saques reglamentarios (banda / cÃ³rner)

local function buildGoal(teamName: string, posX: number, primaryColor: Color3): Part
    local goalFolder = Instance.new("Folder")
    goalFolder.Name = "Porteria_" .. teamName
    goalFolder.Parent = pitchFolder

    local dirSign = if posX < 0 then -1 else 1
    local postThick = 1.0
    local barColor = Color3.fromRGB(245, 245, 245)

    local function makePost(size: Vector3, pos: Vector3): Part
        local p = Instance.new("Part")
        p.Size = size
        p.Position = pos
        p.Color = barColor
        p.Material = Enum.Material.Metal
        p.Anchored = true
        p.CanCollide = true
        p.Parent = goalFolder
        return p
    end

    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(posX, GOAL_HEIGHT/2, -GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(posX, GOAL_HEIGHT/2, GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, postThick, GOAL_WIDTH + postThick), Vector3.new(posX, GOAL_HEIGHT, 0))

    local backX = posX + (dirSign * GOAL_DEPTH)
    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(backX, GOAL_HEIGHT/2, -GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, GOAL_HEIGHT, postThick), Vector3.new(backX, GOAL_HEIGHT/2, GOAL_WIDTH/2))
    makePost(Vector3.new(postThick, postThick, GOAL_WIDTH + postThick), Vector3.new(backX, GOAL_HEIGHT, 0))

    makePost(Vector3.new(GOAL_DEPTH, postThick, postThick), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT, -GOAL_WIDTH/2))
    makePost(Vector3.new(GOAL_DEPTH, postThick, postThick), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT, GOAL_WIDTH/2))

    local netColor = primaryColor
    local function makeNet(size: Vector3, pos: Vector3)
        local n = Instance.new("Part")
        n.Size = size
        n.Position = pos
        n.Color = netColor
        n.Material = Enum.Material.DiamondPlate
        n.Transparency = 0.45
        n.Anchored = true
        n.CanCollide = true
        -- Propiedades fÃ­sicas para atrapar el balÃ³n en la red (alta fricciÃ³n y sin rebote)
        n.CustomPhysicalProperties = PhysicalProperties.new(1.0, 1.5, 0.0, 1.0, 1.0)
        n.Parent = goalFolder
    end

    makeNet(Vector3.new(1, GOAL_HEIGHT, GOAL_WIDTH), Vector3.new(backX, GOAL_HEIGHT/2, 0))
    makeNet(Vector3.new(GOAL_DEPTH, 1, GOAL_WIDTH), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT, 0))
    makeNet(Vector3.new(GOAL_DEPTH, GOAL_HEIGHT, 1), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT/2, -GOAL_WIDTH/2))
    makeNet(Vector3.new(GOAL_DEPTH, GOAL_HEIGHT, 1), Vector3.new(posX + (dirSign * GOAL_DEPTH/2), GOAL_HEIGHT/2, GOAL_WIDTH/2))

    local sensor = Instance.new("Part")
    sensor.Name = "GoalSensor_" .. teamName
    sensor.Size = Vector3.new(GOAL_DEPTH - 2, GOAL_HEIGHT - 1, GOAL_WIDTH - 2)
    sensor.Position = Vector3.new(posX + (dirSign * (GOAL_DEPTH/2)), GOAL_HEIGHT/2, 0)
    sensor.Transparency = 1
    sensor.Anchored = true
    sensor.CanCollide = false
    sensor.CanTouch = true
    sensor.Parent = goalFolder
    return sensor
end

local sensorAzul = buildGoal("Azul", -halfX, Color3.fromRGB(0, 150, 255))
local sensorRojo = buildGoal("Rojo", halfX, Color3.fromRGB(255, 50, 50))

--------------------------------------------------------------------------------
-- 3. REMOTE EVENTS
--------------------------------------------------------------------------------
local remoteFolder = ReplicatedStorage:FindFirstChild("SoccerRemotes")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "SoccerRemotes"
    remoteFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name: string): RemoteEvent
    local remote = remoteFolder:FindFirstChild(name) :: RemoteEvent?
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remoteFolder
    end
    return remote
end

local startChargeEvent = getOrCreateRemote("StartCharge")
local releaseShotEvent = getOrCreateRemote("ReleaseShot")
local quickShotEvent = getOrCreateRemote("QuickShot")
local ballPossessionEvent = getOrCreateRemote("BallPossession")
local goalScoredEvent = getOrCreateRemote("GoalScored")
local updateScoreEvent = getOrCreateRemote("UpdateScore")
local shotCooldownEvent = getOrCreateRemote("ShotCooldown")
local matchTimeEvent = getOrCreateRemote("MatchTimeUpdate")
local goalAnnouncementEvent = getOrCreateRemote("GoalAnnouncement")
local toggleMatchEvent = getOrCreateRemote("ToggleMatch")

--------------------------------------------------------------------------------
-- 4. CLUBES Y GRADAS CON ESPECTADORES
--------------------------------------------------------------------------------
local standsFolder: Folder? = nil

local function buildStadiumStands(clubAData, clubBData)
    if standsFolder then standsFolder:Destroy() end
    standsFolder = Instance.new("Folder")
    standsFolder.Name = "StadiumStands"
    standsFolder.Parent = workspace

    local function spawnFanAt(xPos: number, yPos: number, zPos: number, club)
        local fan = Instance.new("Part")
        fan.Name = "Fan"
        fan.Size = Vector3.new(2.0, 2.6, 1.4)
        fan.Position = Vector3.new(xPos, yPos, zPos)
        fan.Color = if math.random() > 0.4 then club.primaryColor else club.secondaryColor
        fan.Material = Enum.Material.SmoothPlastic
        fan.Anchored = true
        fan.CanCollide = false
        fan.Parent = standsFolder

        local fanHead = Instance.new("Part")
        fanHead.Name = "Head"
        fanHead.Shape = Enum.PartType.Ball
        fanHead.Size = Vector3.new(1.3, 1.3, 1.3)
        fanHead.Position = Vector3.new(xPos, yPos + 1.9, zPos)
        fanHead.Color = Color3.fromRGB(240, 200, 160)
        fanHead.Material = Enum.Material.SmoothPlastic
        fanHead.Anchored = true
        fanHead.CanCollide = false
        fanHead.Parent = standsFolder
    end

    -- Gradas laterales (Norte y Sur a lo largo de las bandas)
    local function makeSideStand(sideZ: number, club)
        local baseZ = sideZ
        local numTiers = 4
        for tier = 1, numTiers do
            local tierPart = Instance.new("Part")
            tierPart.Name = "GradaBanda_" .. club.name .. "_T" .. tier
            tierPart.Size = Vector3.new(FIELD_SIZE.X + 30, 3, 15)
            tierPart.Position = Vector3.new(0, (tier - 1) * 3 + 1.5, baseZ + (math.sign(sideZ) * (tier - 1) * 13))
            tierPart.Color = club.primaryColor
            tierPart.Material = Enum.Material.Concrete
            tierPart.Anchored = true
            tierPart.CanCollide = true
            tierPart.Parent = standsFolder
        end

        for i = 1, 35 do
            local xPos = -halfX + 10 + (i * 8.5) + math.random(-1, 1)
            local tier = math.random(1, numTiers)
            local yPos = (tier - 1) * 3 + 3.2
            local zPos = baseZ + (math.sign(sideZ) * (tier - 1) * 13) + math.random(-1, 1)
            spawnFanAt(xPos, yPos, zPos, club)
        end
    end

    -- Gradas detrÃ¡s de las porterÃ­as y esquinas (Este y Oeste)
    local function makeEndStand(sideX: number, club)
        local baseX = sideX
        local numTiers = 4
        for tier = 1, numTiers do
            local tierPart = Instance.new("Part")
            tierPart.Name = "GradaGol_" .. club.name .. "_T" .. tier
            tierPart.Size = Vector3.new(15, 3, FIELD_SIZE.Y + 40)
            tierPart.Position = Vector3.new(baseX + (math.sign(sideX) * (tier - 1) * 13), (tier - 1) * 3 + 1.5, 0)
            tierPart.Color = club.secondaryColor
            tierPart.Material = Enum.Material.Concrete
            tierPart.Anchored = true
            tierPart.CanCollide = true
            tierPart.Parent = standsFolder
        end

        for i = 1, 28 do
            local zPos = -halfY + 8 + (i * 7.5) + math.random(-1, 1)
            local tier = math.random(1, numTiers)
            local yPos = (tier - 1) * 3 + 3.2
            local xPos = baseX + (math.sign(sideX) * (tier - 1) * 13) + math.random(-1, 1)
            spawnFanAt(xPos, yPos, zPos, club)
        end
    end

    -- 4 Lados completos con esquinas cubiertas
    makeSideStand(-halfY - 20, clubAData)
    makeSideStand(halfY + 20, clubBData)
    makeEndStand(-halfX - 22, clubAData)
    makeEndStand(halfX + 22, clubBData)
end

--------------------------------------------------------------------------------
-- 5. TIPOS Y ESTRUCTURA DE JUGADORES
--------------------------------------------------------------------------------
type PlayerStats = {
    name: string,
    role: string,
    posTag: string,
    speed: number,
    shot: number,
    pass: number,
    defense: number,
    dribble: number,
    stamina: number,
    control: number,
    physical: number,
    overall: number,
    rarity: string,
    rarityIcon: string,
    rarityColor: Color3,
}

type TacticConfig = {
    passThreshold: number,
    shotThreshold: number,
    pressIntensity: number,
    preferShortPass: boolean,
    maxShotRange: number,
}

type BotSlot = {
    model: Model,
    role: string,
    roleId: string,
    teamName: string,
    basePosition: Vector3,
    stats: PlayerStats,
    tactic: TacticConfig,
    clubName: string,
    lastPassTime: number,
    lastShotTime: number,
    lastStealTime: number,
}

local currentClubA = TeamsData.CLUBS[1]
local currentClubB = TeamsData.CLUBS[2]

local characterStats: { [Model]: PlayerStats } = {}
local characterClub: { [Model]: string } = {}

local function getWalkSpeedFromStat(speedStat: number): number
    return 20 + (speedStat / 100) * 16 -- 26 a 36 studs/s
end

local function getStealRadiusFromStat(defenseStat: number): number
    return 10.0 + (defenseStat / 100) * 6.0 -- 14 a 16 studs (defensa mÃ¡s contundente)
end

local function getStealCooldownFromStat(defenseStat: number): number
    return 1.4 - (defenseStat / 100) * 0.8 -- 0.6s a 1.0s (recuperaciÃ³n rÃ¡pida)
end

local function getShotPowerMultiplier(shotStat: number): number
    return 0.85 + (shotStat / 100) * 0.85 -- 1.2x a 1.7x
end

--------------------------------------------------------------------------------
-- 6. VARIABLES DEL PARTIDO Y BALÃ“N
--------------------------------------------------------------------------------
local BALL_SIZE = Vector3.new(1.6, 1.6, 1.6)
local BALL_ATTACH_OFFSET = Vector3.new(0, -2.2, -1.9)

local MAX_CHARGE_DURATION = 1.6
local BASE_MIN_SPEED = 40
local BASE_MAX_SPEED = 240
local SHOT_COOLDOWN_TIME = 4.5
local lastPlayerShotTime: { [Player]: number } = {}

local currentBall: Part? = nil
local currentOwner: Model? = nil
local lastToucherModel: Model? = nil
local lastToucherClub: string = ""
local activeWeld: WeldConstraint? = nil
local serverChargeStartTime: number? = nil
local isKickOnCooldown = false
local isGoalCelebrating = false

local scoreBlue = 0
local scoreRed = 0

local BLUE_GOAL_CENTER = Vector3.new(-halfX, 4, 0)
local RED_GOAL_CENTER = Vector3.new(halfX, 4, 0)

local goalkeeperBlue: Model? = nil
local goalkeeperRed: Model? = nil
local gkSlotBlue: BotSlot? = nil
local gkSlotRed: BotSlot? = nil
local refereeModel: Model? = nil

--------------------------------------------------------------------------------
-- 7. SISTEMA DE TIEMPO DE PARTIDO: 90 MINUTOS (5 MIN REALES)
--------------------------------------------------------------------------------
local MATCH_STATE_FIRST_HALF = "1ST_HALF"
local MATCH_STATE_FIRST_EXTRA = "1ST_EXTRA"
local MATCH_STATE_HALFTIME = "HALFTIME"
local MATCH_STATE_SECOND_HALF = "2ND_HALF"
local MATCH_STATE_SECOND_EXTRA = "2ND_EXTRA"
local MATCH_STATE_FULLTIME = "FULLTIME"

local currentMatchState = MATCH_STATE_FIRST_HALF
local matchGameSeconds = 0
local firstHalfAddedMins = 0
local secondHalfAddedMins = 0
local halftimeRealSecondsLeft = 60
local fulltimeRealSecondsLeft = 60
local isMatchPaused = true
local isMatchStarted = false
local currentPeriodSideSwapped = false

local function getFormattedGameMinute(): string
    if currentMatchState == MATCH_STATE_FIRST_EXTRA then
        local extraMin = math.max(0, math.round((matchGameSeconds - 45 * 60) / 60))
        return string.format("45+%d'", extraMin)
    elseif currentMatchState == MATCH_STATE_SECOND_EXTRA then
        local extraMin = math.max(0, math.round((matchGameSeconds - 90 * 60) / 60))
        return string.format("90+%d'", extraMin)
    else
        return string.format("%d'", safeClamp(math.round(matchGameSeconds / 60), 0, 90))
    end
end

--------------------------------------------------------------------------------
-- 8. EFECTOS VISUALES DEL BALÃ“N
--------------------------------------------------------------------------------
local function igniteBallInFlames(duration: number)
    if not currentBall then return end

    local existingFire = currentBall:FindFirstChild("BallFire")
    if existingFire then existingFire:Destroy() end
    local existingLight = currentBall:FindFirstChild("BallFireLight")
    if existingLight then existingLight:Destroy() end

    local fire = Instance.new("Fire")
    fire.Name = "BallFire"
    fire.Size = 7
    fire.Heat = 20
    fire.Color = Color3.fromRGB(255, 80, 20)
    fire.SecondaryColor = Color3.fromRGB(255, 220, 0)
    fire.Parent = currentBall

    local light = Instance.new("PointLight")
    light.Name = "BallFireLight"
    light.Color = Color3.fromRGB(255, 100, 20)
    light.Range = 20
    light.Brightness = 7
    light.Parent = currentBall

    task.delay(duration, function()
        if fire and fire.Parent then fire:Destroy() end
        if light and light.Parent then light:Destroy() end
    end)
end

local function removeAuraRing(character: Model?)
    if character then
        local ring = character:FindFirstChild("BallControlRing")
        if ring then ring:Destroy() end
    end
end

local function createAuraRing(character: Model, color: Color3): Part?
    local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return nil end

    removeAuraRing(character)

    local ring = Instance.new("Part")
    ring.Name = "BallControlRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.15, 5.5, 5.5)
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.Transparency = 0.25
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CanQuery = false
    ring.CastShadow = false
    ring.Massless = true
    pcall(function() ring.CollisionGroup = "SoccerBallGroup" end)

    local weld = Instance.new("Weld")
    weld.Part0 = hrp
    weld.Part1 = ring
    weld.C0 = CFrame.new(0, -2.85, 0) * CFrame.Angles(0, 0, math.rad(90))
    weld.Parent = ring

    ring.Parent = character
    return ring
end

--------------------------------------------------------------------------------
-- 9. POSESIÃ“N Y SOLDADURA DEL BALÃ“N
--------------------------------------------------------------------------------
local function releaseBall()
    if activeWeld then
        activeWeld:Destroy()
        activeWeld = nil
    end

    if currentOwner then
        removeAuraRing(currentOwner)
        local prevPlayer = Players:GetPlayerFromCharacter(currentOwner)
        if prevPlayer then
            ballPossessionEvent:FireClient(prevPlayer, false)
        end
    end

    currentOwner = nil
    serverChargeStartTime = nil

    if currentBall then
        currentBall.Massless = false
    end
end

local function attachBallToPlayer(character: Model)
    if isMatchPaused or currentOwner == character or not currentBall or isKickOnCooldown or isGoalCelebrating then return end

    local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    releaseBall()

    currentOwner = character
    lastToucherModel = character
    lastToucherClub = characterClub[character] or (if string.find(character.Name, "Rojo") then currentClubB.name else currentClubA.name)

    currentBall.Massless = true
    currentBall.CFrame = hrp.CFrame * CFrame.new(BALL_ATTACH_OFFSET)
    currentBall.AssemblyLinearVelocity = Vector3.zero
    currentBall.AssemblyAngularVelocity = Vector3.zero

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = currentBall
    weld.Parent = currentBall
    activeWeld = weld

    local isRed = string.find(character.Name, "Rojo") ~= nil
    local ringColor = if isRed then currentClubB.primaryColor else currentClubA.primaryColor
    createAuraRing(character, ringColor)

    local player = Players:GetPlayerFromCharacter(character)
    if player then
        ballPossessionEvent:FireClient(player, true)
    end
end

--------------------------------------------------------------------------------
-- 10. FORMACIONES Y CONSTRUCCIÃ“N DE BOTS 11v11 CON RAREZA E ICONOS
--------------------------------------------------------------------------------
local teamBlueBots: { [string]: BotSlot } = {}
local teamRedBots: { [string]: BotSlot } = {}

-- FormaciÃ³n 11v11: 4 Defensas, 3 Centrocampistas, 3 Delanteros + 1 Portero (4-3-3 clÃ¡sico)
local FORMATION_WEST: { [string]: { role: string, pos: Vector3 } } = {
    ["LB"]  = { role = "Defensa", pos = Vector3.new(-105, 3, -60) },
    ["CB1"] = { role = "Defensa", pos = Vector3.new(-120, 3, -20) },
    ["CB2"] = { role = "Defensa", pos = Vector3.new(-120, 3, 20)  },
    ["RB"]  = { role = "Defensa", pos = Vector3.new(-105, 3, 60)  },
    ["CDM"] = { role = "Central", pos = Vector3.new(-75, 3, 0)    },
    ["CM1"] = { role = "Central", pos = Vector3.new(-50, 3, -32)  },
    ["CM2"] = { role = "Central", pos = Vector3.new(-50, 3, 32)   },
    ["LW"]  = { role = "Delantero", pos = Vector3.new(-20, 3, -50)},
    ["ST"]  = { role = "Delantero", pos = Vector3.new(-15, 3, 0)  },
    ["RW"]  = { role = "Delantero", pos = Vector3.new(-20, 3, 50) },
}

local FORMATION_EAST: { [string]: { role: string, pos: Vector3 } } = {
    ["LB"]  = { role = "Defensa", pos = Vector3.new(105, 3, 60)   },
    ["CB1"] = { role = "Defensa", pos = Vector3.new(120, 3, 20)   },
    ["CB2"] = { role = "Defensa", pos = Vector3.new(120, 3, -20)  },
    ["RB"]  = { role = "Defensa", pos = Vector3.new(105, 3, -60)  },
    ["CDM"] = { role = "Central", pos = Vector3.new(75, 3, 0)     },
    ["CM1"] = { role = "Central", pos = Vector3.new(50, 3, 32)    },
    ["CM2"] = { role = "Central", pos = Vector3.new(50, 3, -32)   },
    ["LW"]  = { role = "Delantero", pos = Vector3.new(20, 3, 50)  },
    ["ST"]  = { role = "Delantero", pos = Vector3.new(15, 3, 0)   },
    ["RW"]  = { role = "Delantero", pos = Vector3.new(20, 3, -50) },
}

local function attachRarityBillboard(head: Part, playerStats: PlayerStats)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerCardUI"
    billboard.Size = UDim2.new(0, 160, 0, 38)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "RarityIcon"
    iconLabel.Size = UDim2.new(1, 0, 0.42, 0)
    iconLabel.Position = UDim2.new(0, 0, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = playerStats.rarityIcon
    iconLabel.TextColor3 = playerStats.rarityColor
    iconLabel.Font = Enum.Font.GothamBlack
    iconLabel.TextSize = 14
    iconLabel.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(1, 0, 0.58, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.42, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerStats.name
    nameLabel.TextColor3 = Color3.fromRGB(250, 250, 250)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = billboard

    local textStroke = Instance.new("UIStroke")
    textStroke.Color = Color3.fromRGB(20, 20, 20)
    textStroke.Thickness = 1.5
    textStroke.Parent = nameLabel
end

local function buildSoccerBot(
    teamName: string,
    roleId: string,
    role: string,
    basePos: Vector3,
    clubData,
    usedNames: { [string]: boolean }
): BotSlot

    local pool: {PlayerStats} = {}
    for _, item in ipairs(TeamsData.PLAYERS) do
        if item.role == role and not usedNames[item.name] then
            table.insert(pool, item)
        end
    end
    if #pool == 0 then
        for _, item in ipairs(TeamsData.PLAYERS) do
            if item.role == role then table.insert(pool, item) end
        end
    end
    if #pool == 0 then pool = TeamsData.PLAYERS end

    local statsTemplate = pool[math.random(1, #pool)]
    usedNames[statsTemplate.name] = true

    local bot = Instance.new("Model")
    bot.Name = string.format("Bot_%s_%s_%s", teamName, roleId, statsTemplate.name)

    local function makePart(pName: string, size: Vector3, color: Color3): Part
        local p = Instance.new("Part")
        p.Name = pName
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.CanCollide = true
        p.Parent = bot
        return p
    end

    local hrp = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(150, 150, 150))
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.CFrame = CFrame.new(basePos)

    local torso = makePart("Torso", Vector3.new(2, 2, 1), clubData.primaryColor)
    local head = makePart("Head", Vector3.new(1.25, 1.25, 1.25), Color3.fromRGB(240, 200, 160))
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    headMesh.Parent = head

    local leftArm = makePart("Left Arm", Vector3.new(1, 2, 1), clubData.secondaryColor)
    local rightArm = makePart("Right Arm", Vector3.new(1, 2, 1), clubData.secondaryColor)
    local leftLeg = makePart("Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(25, 25, 25))
    local rightLeg = makePart("Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(25, 25, 25))

    local function makeMotor(mName: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
        local m = Instance.new("Motor6D")
        m.Name = mName
        m.Part0 = part0
        m.Part1 = part1
        m.C0 = c0
        m.C1 = c1
        m.Parent = part0
    end

    makeMotor("RootJoint", hrp, torso, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
    makeMotor("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
    makeMotor("Left Shoulder", torso, leftArm, CFrame.new(-1, 0.5, 0), CFrame.new(0.5, 0.5, 0))
    makeMotor("Right Shoulder", torso, rightArm, CFrame.new(1, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
    makeMotor("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
    makeMotor("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.WalkSpeed = getWalkSpeedFromStat(statsTemplate.speed)
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    humanoid.Parent = bot

    attachRarityBillboard(head, statsTemplate)

    bot.PrimaryPart = hrp
    setupCharacterCollision(bot)

    characterStats[bot] = statsTemplate
    characterClub[bot] = clubData.name
    bot.Parent = workspace

    local slot: BotSlot = {
        model = bot,
        role = role,
        roleId = roleId,
        teamName = teamName,
        basePosition = basePos,
        stats = statsTemplate,
        tactic = clubData.tactic,
        clubName = clubData.name,
        lastPassTime = 0,
        lastShotTime = 0,
        lastStealTime = 0,
    }

    return slot
end

local function cleanTeam(teamSlots: { [string]: BotSlot })
    for roleId, slot in pairs(teamSlots) do
        if slot.model and slot.model.Parent then
            if currentOwner == slot.model then releaseBall() end
            characterStats[slot.model] = nil
            characterClub[slot.model] = nil
            slot.model:Destroy()
        end
        teamSlots[roleId] = nil
    end
end

--------------------------------------------------------------------------------
-- 11. PORTEROS INTELIGENTES CON IDENTIDAD Y RAREZA
--------------------------------------------------------------------------------
local function setupGoalkeeperModel(
    teamName: string,
    posX: number,
    clubData,
    gkStats: PlayerStats,
    existingModel: Model?
): (Model, BotSlot)

    local gk: Model
    if existingModel and existingModel.Parent then
        gk = existingModel
        local hrp = gk:FindFirstChild("HumanoidRootPart") :: BasePart?
        if hrp then hrp.CFrame = CFrame.new(posX, 3, 0) end
        local shield = gk:FindFirstChild("ImpossibleShield") :: BasePart?
        if shield then shield.Position = Vector3.new(posX, GOAL_HEIGHT/2, 0) end
    else
        gk = Instance.new("Model")
        gk.Name = "Portero_" .. teamName

        local function makePart(pName: string, size: Vector3, color: Color3): Part
            local p = Instance.new("Part")
            p.Name = pName
            p.Size = size
            p.Color = color
            p.Material = Enum.Material.SmoothPlastic
            p.CanCollide = true
            p.Parent = gk
            return p
        end

        local hrp = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(120, 120, 120))
        hrp.Transparency = 1
        hrp.CanCollide = false
        hrp.CFrame = CFrame.new(posX, 3, 0)

        local torso = makePart("Torso", Vector3.new(2.4, 2, 1.2), clubData.primaryColor)
        local head = makePart("Head", Vector3.new(1.3, 1.3, 1.3), Color3.fromRGB(240, 200, 160))
        local headMesh = Instance.new("SpecialMesh")
        headMesh.MeshType = Enum.MeshType.Head
        headMesh.Scale = Vector3.new(1.3, 1.3, 1.3)
        headMesh.Parent = head

        local leftArm = makePart("Left Arm", Vector3.new(1.3, 2.4, 1.3), Color3.fromRGB(255, 230, 50))
        local rightArm = makePart("Right Arm", Vector3.new(1.3, 2.4, 1.3), Color3.fromRGB(255, 230, 50))
        local leftLeg = makePart("Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(30, 30, 30))
        local rightLeg = makePart("Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(30, 30, 30))

        local function makeMotor(mName: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
            local m = Instance.new("Motor6D")
            m.Name = mName
            m.Part0 = part0
            m.Part1 = part1
            m.C0 = c0
            m.C1 = c1
            m.Parent = part0
        end

        makeMotor("RootJoint", hrp, torso, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
        makeMotor("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
        makeMotor("Left Shoulder", torso, leftArm, CFrame.new(-1.2, 0.5, 0), CFrame.new(0.5, 0.5, 0))
        makeMotor("Right Shoulder", torso, rightArm, CFrame.new(1.2, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
        makeMotor("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
        makeMotor("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

        local humanoid = Instance.new("Humanoid")
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        humanoid.WalkSpeed = 38
        humanoid.JumpPower = 52
        humanoid.JumpHeight = 7.5
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid.Parent = gk

        local impossibleShield = Instance.new("Part")
        impossibleShield.Name = "ImpossibleShield"
        impossibleShield.Size = Vector3.new(3.5, GOAL_HEIGHT, GOAL_WIDTH * 0.95)
        impossibleShield.Position = Vector3.new(posX, GOAL_HEIGHT/2, 0)
        impossibleShield.Transparency = 1
        impossibleShield.Anchored = true
        impossibleShield.CanCollide = false
        impossibleShield.CanTouch = true
        impossibleShield.Parent = gk

        for _, p in ipairs(gk:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "ImpossibleShield" then
                p.CanCollide = true
                p.CollisionGroup = "Default"
                p.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.4, 0.8, 1, 1)
            end
        end

        gk.PrimaryPart = hrp
        setupCharacterCollision(gk)
        gk.Parent = workspace
    end

    local head = gk:FindFirstChild("Head") :: Part?
    if head then
        local oldUI = head:FindFirstChild("PlayerCardUI")
        if oldUI then oldUI:Destroy() end
        attachRarityBillboard(head, gkStats)
    end

    characterStats[gk] = gkStats
    characterClub[gk] = clubData.name

    local slot: BotSlot = {
        model = gk,
        role = "Portero",
        roleId = "GK",
        teamName = teamName,
        basePosition = Vector3.new(posX, 3, 0),
        stats = gkStats,
        tactic = clubData.tactic,
        clubName = clubData.name,
        lastPassTime = 0,
        lastShotTime = 0,
        lastStealTime = 0,
    }

    return gk, slot
end

local function spawnReferee(): Model
    if refereeModel and refereeModel.Parent then refereeModel:Destroy() end

    local ref = Instance.new("Model")
    ref.Name = "Arbitro_Principal"

    local function makePart(pName: string, size: Vector3, color: Color3): Part
        local p = Instance.new("Part")
        p.Name = pName
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        p.CanCollide = true
        p.Parent = ref
        return p
    end

    local hrp = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), Color3.fromRGB(150, 150, 150))
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.CFrame = CFrame.new(0, 3, 20)

    -- Uniforme tradicional de Ã¡rbitro (camiseta amarillo flÃºor / negro con silbato)
    local torso = makePart("Torso", Vector3.new(2, 2, 1), Color3.fromRGB(240, 240, 20))
    local head = makePart("Head", Vector3.new(1.25, 1.25, 1.25), Color3.fromRGB(240, 200, 160))
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    headMesh.Parent = head

    local leftArm = makePart("Left Arm", Vector3.new(1, 2, 1), Color3.fromRGB(20, 20, 20))
    local rightArm = makePart("Right Arm", Vector3.new(1, 2, 1), Color3.fromRGB(20, 20, 20))
    local leftLeg = makePart("Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(20, 20, 20))
    local rightLeg = makePart("Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(20, 20, 20))

    local function makeMotor(mName: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
        local m = Instance.new("Motor6D")
        m.Name = mName
        m.Part0 = part0
        m.Part1 = part1
        m.C0 = c0
        m.C1 = c1
        m.Parent = part0
    end

    makeMotor("RootJoint", hrp, torso, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
    makeMotor("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
    makeMotor("Left Shoulder", torso, leftArm, CFrame.new(-1, 0.5, 0), CFrame.new(0.5, 0.5, 0))
    makeMotor("Right Shoulder", torso, rightArm, CFrame.new(1, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
    makeMotor("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
    makeMotor("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.WalkSpeed = 26
    humanoid.Parent = ref

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RefereeUI"
    billboard.Size = UDim2.new(0, 140, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3.0, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "âš–ï¸ ÃRBITRO"
    label.TextColor3 = Color3.fromRGB(255, 235, 50)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard

    ref.PrimaryPart = hrp
    setupCharacterCollision(ref)
    ref.Parent = workspace
    refereeModel = ref
    return ref
end

local function areColorsTooSimilar(c1: Color3, c2: Color3): boolean
    local dr = c1.R - c2.R
    local dg = c1.G - c2.G
    local db = c1.B - c2.B
    local dist = math.sqrt(dr * dr + dg * dg + db * db)
    return dist < 0.42
end

local function selectClubsWithDifferentKits(): (any, any)
    local numClubs = #TeamsData.CLUBS
    local cIndexA = math.random(1, numClubs)
    local clubA = TeamsData.CLUBS[cIndexA]

    local candidateIndices: {number} = {}
    for i = 1, numClubs do
        if i ~= cIndexA then
            local clubB = TeamsData.CLUBS[i]
            if not areColorsTooSimilar(clubA.primaryColor, clubB.primaryColor) then
                table.insert(candidateIndices, i)
            end
        end
    end

    local cIndexB: number
    if #candidateIndices > 0 then
        cIndexB = candidateIndices[math.random(1, #candidateIndices)]
    else
        cIndexB = math.random(1, numClubs)
        while cIndexB == cIndexA do
            cIndexB = math.random(1, numClubs)
        end
    end

    return clubA, TeamsData.CLUBS[cIndexB]
end

local function spawnFull6v6Match()
    cleanTeam(teamBlueBots)
    cleanTeam(teamRedBots)

    currentClubA, currentClubB = selectClubsWithDifferentKits()
    print(string.format("[PARTIDO] Enfrentamiento: %s vs %s (Kits contrastados garantizados)", currentClubA.name, currentClubB.name))

    buildStadiumStands(currentClubA, currentClubB)
    updateScoreEvent:FireAllClients(scoreBlue, scoreRed, currentClubA.name, currentClubB.name)

    local usedNames: { [string]: boolean } = {}

    local gkPool: {PlayerStats} = {}
    for _, p in ipairs(TeamsData.PLAYERS) do
        if p.role == "Portero" then table.insert(gkPool, p) end
    end
    local blueGkStats = gkPool[math.random(1, #gkPool)]
    usedNames[blueGkStats.name] = true

    local redGkStats = gkPool[math.random(1, #gkPool)]
    while redGkStats.name == blueGkStats.name do
        redGkStats = gkPool[math.random(1, #gkPool)]
    end
    usedNames[redGkStats.name] = true

    local blueForm = if currentPeriodSideSwapped then FORMATION_EAST else FORMATION_WEST
    local redForm = if currentPeriodSideSwapped then FORMATION_WEST else FORMATION_EAST

    for roleId, data in pairs(blueForm) do
        local slot = buildSoccerBot("Azul", roleId, data.role, data.pos, currentClubA, usedNames)
        teamBlueBots[roleId] = slot
    end

    for roleId, data in pairs(redForm) do
        local slot = buildSoccerBot("Rojo", roleId, data.role, data.pos, currentClubB, usedNames)
        teamRedBots[roleId] = slot
    end

    local blueGKX = if currentPeriodSideSwapped then (halfX - 4) else (-halfX + 4)
    local redGKX = if currentPeriodSideSwapped then (-halfX + 4) else (halfX - 4)

    goalkeeperBlue, gkSlotBlue = setupGoalkeeperModel("Azul", blueGKX, currentClubA, blueGkStats, goalkeeperBlue)
    goalkeeperRed, gkSlotRed = setupGoalkeeperModel("Rojo", redGKX, currentClubB, redGkStats, goalkeeperRed)

    spawnReferee()

    print("[SERVIDOR] Â¡11v11 jugadores, porteros y Ãrbitro listos en el campo!")
end

--------------------------------------------------------------------------------
-- 12. SPAWN DEL BALÃ“N Y GESTIÃ“N DE GOLES CON ANUNCIO DETALLADO
--------------------------------------------------------------------------------
local function spawnBall(spawnCFrame: CFrame)
    if currentBall and currentBall.Parent then
        currentBall:Destroy()
    end
    releaseBall()

    local ball = Instance.new("Part")
    ball.Name = "SoccerBall"
    ball.Shape = Enum.PartType.Ball
    ball.Size = BALL_SIZE
    ball.CFrame = spawnCFrame
    ball.Material = Enum.Material.SmoothPlastic
    ball.Color = Color3.fromRGB(245, 245, 245)
    ball.TopSurface = Enum.SurfaceType.Smooth
    ball.BottomSurface = Enum.SurfaceType.Smooth
    ball.CanCollide = true
    ball.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.4, 0.8, 1, 1)

    pcall(function()
        ball.CollisionGroup = "SoccerBallGroup"
    end)

    local soccerMesh = Instance.new("SpecialMesh")
    soccerMesh.MeshType = Enum.MeshType.Sphere
    soccerMesh.Scale = Vector3.new(1, 1, 1)
    soccerMesh.Parent = ball

    ball.Touched:Connect(function(hit)
        if isMatchPaused or isKickOnCooldown or currentOwner ~= nil or isGoalCelebrating then return end
        local character = hit.Parent
        if character and character:IsA("Model") then
            attachBallToPlayer(character)
        end
    end)

    ball.Parent = workspace
    currentBall = ball
end

local function resetPositionsToField()
    for roleId, slot in pairs(teamBlueBots) do
        if slot.model and slot.model.Parent then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if hrp then
                hrp.CFrame = CFrame.new(slot.basePosition + Vector3.new(0, 0, math.random(-4, 4)))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end

    for roleId, slot in pairs(teamRedBots) do
        if slot.model and slot.model.Parent then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if hrp then
                hrp.CFrame = CFrame.new(slot.basePosition + Vector3.new(0, 0, math.random(-4, 4)))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end

    local blueGKX = if currentPeriodSideSwapped then (halfX - 4) else (-halfX + 4)
    local redGKX = if currentPeriodSideSwapped then (-halfX + 4) else (halfX - 4)

    if goalkeeperBlue and goalkeeperBlue.Parent then
        local bHrp = goalkeeperBlue:FindFirstChild("HumanoidRootPart") :: BasePart?
        if bHrp then bHrp.CFrame = CFrame.new(blueGKX, 3, 0) end
        local shield = goalkeeperBlue:FindFirstChild("ImpossibleShield") :: BasePart?
        if shield then shield.Position = Vector3.new(blueGKX, GOAL_HEIGHT/2, 0) end
    end

    if goalkeeperRed and goalkeeperRed.Parent then
        local rHrp = goalkeeperRed:FindFirstChild("HumanoidRootPart") :: BasePart?
        if rHrp then rHrp.CFrame = CFrame.new(redGKX, 3, 0) end
        local shield = goalkeeperRed:FindFirstChild("ImpossibleShield") :: BasePart?
        if shield then shield.Position = Vector3.new(redGKX, GOAL_HEIGHT/2, 0) end
    end

    local humanSpawnX = if currentPeriodSideSwapped then 60 else -60
    for _, p in ipairs(Players:GetPlayers()) do
        local pChar = p.Character
        local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
        if pHrp then
            pHrp.CFrame = CFrame.new(0, 180, 0)
            pHrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function onGoalScored(goalSide: string)
    if isGoalCelebrating or isMatchPaused then return end
    isGoalCelebrating = true

    local scoringTeam = ""
    local scoredOnTeam = ""

    if not currentPeriodSideSwapped then
        if goalSide == "Azul" then
            scoreRed = scoreRed + 1
            scoringTeam = "Rojo"
            scoredOnTeam = "Azul"
        else
            scoreBlue = scoreBlue + 1
            scoringTeam = "Azul"
            scoredOnTeam = "Rojo"
        end
    else
        if goalSide == "Azul" then
            scoreBlue = scoreBlue + 1
            scoringTeam = "Azul"
            scoredOnTeam = "Rojo"
        else
            scoreRed = scoreRed + 1
            scoringTeam = "Rojo"
            scoredOnTeam = "Azul"
        end
    end

    local scorerName = "Futbolista"
    local scorerClub = if scoringTeam == "Azul" then currentClubA.name else currentClubB.name
    local isOwnGoal = false

    if lastToucherModel and lastToucherModel.Parent then
        local stats = characterStats[lastToucherModel]
        if stats then scorerName = stats.name end
        local touchIsRed = string.find(lastToucherModel.Name, "Rojo") ~= nil
        local touchTeam = if touchIsRed then "Rojo" else "Azul"

        if touchTeam == scoredOnTeam then
            isOwnGoal = true
            scorerClub = if touchTeam == "Azul" then currentClubA.name else currentClubB.name
        else
            scorerClub = if touchTeam == "Azul" then currentClubA.name else currentClubB.name
        end
    end

    local minuteText = getFormattedGameMinute()
    print(string.format("[GOL] %s - %s (%s) [Propia: %s]", scorerClub, scorerName, minuteText, tostring(isOwnGoal)))

    updateScoreEvent:FireAllClients(scoreBlue, scoreRed, currentClubA.name, currentClubB.name)
    goalScoredEvent:FireAllClients(scoringTeam)
    goalAnnouncementEvent:FireAllClients(scorerName, scorerClub, minuteText, isOwnGoal)

    releaseBall()

    -- Enganchar el balÃ³n dentro de la red amortiguando su velocidad
    if currentBall then
        currentBall.AssemblyLinearVelocity = currentBall.AssemblyLinearVelocity * 0.1
        currentBall.AssemblyAngularVelocity = Vector3.zero
    end

    task.delay(2.5, function()
        resetPositionsToField()
        spawnBall(CFrame.new(0, 2.5, 0))
        isGoalCelebrating = false
    end)
end

sensorAzul.Touched:Connect(function(hit)
    if hit == currentBall then
        onGoalScored("Azul")
    end
end)

sensorRojo.Touched:Connect(function(hit)
    if hit == currentBall then
        onGoalScored("Rojo")
    end
end)

task.defer(function()
    spawnBall(CFrame.new(0, 2.5, 0))
end)

--------------------------------------------------------------------------------
-- 13. DISPARO DEL JUGADOR HUMANO
--------------------------------------------------------------------------------
local function checkPlayerCooldown(player: Player): boolean
    local lastTime = lastPlayerShotTime[player] or 0
    return (os.clock() - lastTime) >= SHOT_COOLDOWN_TIME
end

local function applyPlayerCooldown(player: Player)
    lastPlayerShotTime[player] = os.clock()
    shotCooldownEvent:FireClient(player, SHOT_COOLDOWN_TIME)
end

startChargeEvent.OnServerEvent:Connect(function(player)
    local char = player.Character
    if char and currentOwner == char and not isKickOnCooldown and not isGoalCelebrating and not isMatchPaused and checkPlayerCooldown(player) then
        serverChargeStartTime = os.clock()
    end
end)

releaseShotEvent.OnServerEvent:Connect(function(player, clientAimDirection: Vector3)
    local char = player.Character
    if not char or currentOwner ~= char or not currentBall or isKickOnCooldown or isGoalCelebrating or isMatchPaused then
        return
    end

    if not checkPlayerCooldown(player) then return end
    applyPlayerCooldown(player)

    local startTime = serverChargeStartTime or os.clock()
    local elapsed = os.clock() - startTime
    local powerRatio = safeClamp(elapsed / MAX_CHARGE_DURATION, 0.01, 1.0)

    local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local shootDir: Vector3
    if typeof(clientAimDirection) == "Vector3" and clientAimDirection.Magnitude > 0.1 then
        shootDir = clientAimDirection.Unit
    elseif hrp then
        shootDir = hrp.CFrame.LookVector
    else
        shootDir = Vector3.new(0, 0, -1)
    end

    local stats = characterStats[char]
    local shotMultiplier = if stats then getShotPowerMultiplier(stats.shot) else 1.0

    lastToucherModel = char
    lastToucherClub = currentClubA.name
    releaseBall()
    isKickOnCooldown = true

    pcall(function() currentBall:SetNetworkOwner(player) end)

    local speed = (BASE_MIN_SPEED + (powerRatio * (BASE_MAX_SPEED - BASE_MIN_SPEED))) * shotMultiplier
    local lift = 8 + (powerRatio * 34)
    if shootDir.Y > 0.1 then lift = lift + (shootDir.Y * 35) end

    currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
    currentBall.AssemblyLinearVelocity = (Vector3.new(shootDir.X, 0, shootDir.Z).Unit * speed) + Vector3.new(0, lift, 0)
    currentBall.AssemblyAngularVelocity = Vector3.new(-shootDir.Z, 0, shootDir.X) * (20 + (powerRatio * 60))

    task.delay(0.5, function()
        isKickOnCooldown = false
        pcall(function()
            if currentBall then currentBall:SetNetworkOwner(nil) end
        end)
    end)
end)

quickShotEvent.OnServerEvent:Connect(function(player, clientAimDirection: Vector3)
    local char = player.Character
    if not char or currentOwner ~= char or not currentBall or isKickOnCooldown or isGoalCelebrating or isMatchPaused then
        return
    end

    if not checkPlayerCooldown(player) then return end
    applyPlayerCooldown(player)

    local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local shootDir = if (typeof(clientAimDirection) == "Vector3" and clientAimDirection.Magnitude > 0.1)
        then clientAimDirection.Unit
        elseif hrp then hrp.CFrame.LookVector
        else Vector3.new(0, 0, -1)

    local stats = characterStats[char]
    local shotMultiplier = if stats then getShotPowerMultiplier(stats.shot) else 1.0

    lastToucherModel = char
    lastToucherClub = currentClubA.name
    releaseBall()
    isKickOnCooldown = true

    pcall(function() currentBall:SetNetworkOwner(player) end)

    local speed = 160 * shotMultiplier
    local lift = 18
    if shootDir.Y > 0.1 then lift = lift + (shootDir.Y * 30) end

    currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
    currentBall.AssemblyLinearVelocity = (Vector3.new(shootDir.X, 0, shootDir.Z).Unit * speed) + Vector3.new(0, lift, 0)

    task.delay(0.5, function()
        isKickOnCooldown = false
        pcall(function()
            if currentBall then currentBall:SetNetworkOwner(nil) end
        end)
    end)
end)

--------------------------------------------------------------------------------
-- 14. SISTEMA DE PASES AVANZADO Y DISPARO INTELIGENTE
--------------------------------------------------------------------------------
local function findBestPassTarget(
    passerSlot: BotSlot,
    allyTeam: { [string]: BotSlot },
    enemyTeam: { [string]: BotSlot },
    tactic: TacticConfig
): (BotSlot?, number, string)

    local passerHrp = passerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not passerHrp then return nil, 0, "short_ground" end

    local passerPos = passerHrp.Position
    local bestTarget: BotSlot? = nil
    local bestScore = -9999
    local chosenType = "short_ground"

    for roleId, candidate in pairs(allyTeam) do
        if candidate ~= passerSlot and candidate.model and candidate.model.Parent then
            local cHumanoid = candidate.model:FindFirstChildOfClass("Humanoid")
            local cHrp = candidate.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if cHumanoid and cHumanoid.Health > 0 and cHrp then
                local toCandidate = cHrp.Position - passerPos
                local dist = toCandidate.Magnitude

                if dist > 14 and dist < 140 then
                    local passDir = Vector3.new(toCandidate.X, 0, toCandidate.Z).Unit
                    local enemiesInLine = 0

                    for _, enemySlot in pairs(enemyTeam) do
                        if enemySlot.model and enemySlot.model.Parent then
                            local eHrp = enemySlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                            if eHrp then
                                local toEnemy = eHrp.Position - passerPos
                                local proj = toEnemy:Dot(passDir)
                                if proj > 0 and proj < dist then
                                    local perpDist = (toEnemy - (passDir * proj)).Magnitude
                                    if perpDist < 9.5 then
                                        enemiesInLine = enemiesInLine + 1
                                    end
                                end
                            end
                        end
                    end

                    local passType = "short_ground"
                    local canPass = true

                    if enemiesInLine > 0 then
                        if dist >= 45 and (passerSlot.stats.pass >= 72) then
                            passType = "lofted"
                        else
                            canPass = false
                        end
                    else
                        local isFlank = math.abs(passerPos.Z) > 42
                        local candidateInBox = (candidate.role == "Delantero" and math.abs(cHrp.Position.Z) < 40)

                        if isFlank and candidateInBox and dist > 28 then
                            passType = "cross"
                        elseif dist < 45 and tactic.preferShortPass then
                            passType = "short_ground"
                        elseif dist >= 60 then
                            passType = "through_ball"
                        else
                            passType = "medium_ground"
                        end
                    end

                    if canPass then
                        local forwardBonus = if passerSlot.teamName == "Azul" then (cHrp.Position.X - passerPos.X) else (passerPos.X - cHrp.Position.X)
                        local roleBonus = if candidate.role == "Delantero" then 45 elseif candidate.role == "Central" then 25 else 10
                        local tacticBonus = if tactic.preferShortPass and dist < 45 then 30 else 0
                        local crossBonus = if passType == "cross" then 40 else 0

                        local totalScore = forwardBonus + roleBonus + tacticBonus + crossBonus - (dist * 0.15)
                        if totalScore > bestScore then
                            bestScore = totalScore
                            bestTarget = candidate
                            chosenType = passType
                        end
                    end
                end
            end
        end
    end

    return bestTarget, bestScore, chosenType
end

local function executePass(passerSlot: BotSlot, targetSlot: BotSlot, passType: string)
    if not currentBall or isKickOnCooldown or currentOwner ~= passerSlot.model then return end
    local passerHrp = passerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetHrp = targetSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not passerHrp or not targetHrp then return end

    lastToucherModel = passerSlot.model
    lastToucherClub = passerSlot.clubName
    releaseBall()
    isKickOnCooldown = true

    local targetVel = targetHrp.AssemblyLinearVelocity
    local dist = (targetHrp.Position - passerHrp.Position).Magnitude
    local leadFactor = if passType == "through_ball" then 0.65 else 0.25
    local leadPos = targetHrp.Position + Vector3.new(targetVel.X, 0, targetVel.Z) * leadFactor

    local passDir = (leadPos - passerHrp.Position)
    local unitDir = if passDir.Magnitude > 0.1 then passDir.Unit else passerHrp.CFrame.LookVector

    local passSpeed = 60
    local liftY = 2

    if passType == "short_ground" then
        passSpeed = safeClamp(dist * 1.3, 40, 68)
        liftY = 2
    elseif passType == "medium_ground" then
        passSpeed = safeClamp(dist * 1.4, 55, 82)
        liftY = 4
    elseif passType == "lofted" then
        passSpeed = safeClamp(dist * 1.35, 70, 105)
        liftY = math.random(18, 26)
    elseif passType == "through_ball" then
        passSpeed = safeClamp(dist * 1.5, 65, 95)
        liftY = 3.5
    elseif passType == "cross" then
        passSpeed = math.random(85, 115)
        liftY = math.random(22, 30)
    end

    currentBall.CFrame = currentBall.CFrame + (unitDir * 2.2) + Vector3.new(0, 0.4, 0)
    currentBall.AssemblyLinearVelocity = (unitDir * passSpeed) + Vector3.new(0, liftY, 0)

    passerSlot.lastPassTime = os.clock()
    task.delay(0.4, function() isKickOnCooldown = false end)
end

local function executeClearance(botSlot: BotSlot, enemyGoalPos: Vector3)
    if not currentBall or isKickOnCooldown or currentOwner ~= botSlot.model then return end
    local hrp = botSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    local allySlots = if botSlot.teamName == "Azul" then teamBlueBots else teamRedBots
    local enemySlots = if botSlot.teamName == "Azul" then teamRedBots else teamBlueBots
    local safePassTarget, score, pType = findBestPassTarget(botSlot, allySlots, enemySlots, botSlot.tactic)
    if safePassTarget and score > 20 then
        executePass(botSlot, safePassTarget, pType)
        return
    end

    lastToucherModel = botSlot.model
    lastToucherClub = botSlot.clubName
    releaseBall()
    isKickOnCooldown = true

    local flankTarget = enemyGoalPos + Vector3.new(0, 0, if math.random() > 0.5 then 55 else -55)
    local clearDir = (flankTarget - hrp.Position).Unit
    local liftY = math.random(24, 34)
    local speed = math.random(90, 120)

    currentBall.CFrame = currentBall.CFrame + (clearDir * 2.5) + Vector3.new(0, 1.0, 0)
    currentBall.AssemblyLinearVelocity = (clearDir * speed) + Vector3.new(0, liftY, 0)
    currentBall.AssemblyAngularVelocity = Vector3.new(-clearDir.Z, 0, clearDir.X) * 35

    task.delay(0.5, function() isKickOnCooldown = false end)
end

local function evaluateShotOpportunity(
    slot: BotSlot,
    enemyGoalPos: Vector3,
    enemyTeam: { [string]: BotSlot },
    gkPos: Vector3
): boolean

    local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return false end

    local dist = (enemyGoalPos - hrp.Position).Magnitude
    local tactic = slot.tactic

    if dist > tactic.maxShotRange then return false end

    local lateralOffset = math.abs(hrp.Position.Z)
    local angleScore = safeClamp(1 - (lateralOffset / (GOAL_WIDTH * 1.1)), 0.1, 1.0)

    local toGoalDir = (enemyGoalPos - hrp.Position).Unit
    local blockers = 0
    for _, eSlot in pairs(enemyTeam) do
        if eSlot.model and eSlot.model.Parent then
            local eHrp = eSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if eHrp then
                local toEnemy = eHrp.Position - hrp.Position
                local proj = toEnemy:Dot(toGoalDir)
                if proj > 0 and proj < dist then
                    local perpDist = (toEnemy - (toGoalDir * proj)).Magnitude
                    if perpDist < 11 then blockers = blockers + 1 end
                end
            end
        end
    end

    local distBonus = 0
    if dist < 40 then
        distBonus = 40
    elseif dist < 70 then
        distBonus = 20
    else
        distBonus = -25 - ((dist - 70) * 0.8)
    end

    local shooterQuality = (slot.stats.shot - 70) * 0.6
    local totalScore = (angleScore * 60) + distBonus - (blockers * 22) + shooterQuality

    return totalScore >= tactic.shotThreshold
end

--------------------------------------------------------------------------------
-- 15. POSICIONAMIENTO TÃCTICO POR ROL Y TRANSICIONES
--------------------------------------------------------------------------------
local function getTacticalPosition(
    slot: BotSlot,
    hasTeamPossession: boolean,
    hasEnemyPossession: boolean,
    ballPos: Vector3,
    enemyGoalPos: Vector3,
    allyTeam: { [string]: BotSlot }?,
    enemyTeam: { [string]: BotSlot }?
): Vector3

    local role = slot.role
    local base = slot.basePosition
    local attackDirX = if enemyGoalPos.X > 0 then 1 else -1

    if role == "Delantero" then
        if hasTeamPossession then
            -- DESMARQUES Y LÃNEA OFENSIVA
            -- Si es delantero centro (ST), busca desmarcarse al espacio a la espalda de centrales
            -- Si es extremo (LW / RW), busca abrir campo a banda o diagonal al segundo palo
            local roleId = slot.roleId
            local baseZ = base.Z
            local targetZ = baseZ

            if roleId == "ST" then
                -- Desmarque en profundidad o arrastre hacia espacio libre
                local offsideLimitX = (halfX - 26) * attackDirX
                local leadX = safeClamp(ballPos.X + (38 * attackDirX), -halfX + 30, halfX - 30)
                -- Buscar el lado opuesto al balÃ³n para desmarque al hueco
                targetZ = if ballPos.Z > 10 then -18 elseif ballPos.Z < -10 then 18 else (if math.sin(os.clock() * 1.5) > 0 then 15 else -15)
                return Vector3.new(leadX, 3, targetZ)
            elseif roleId == "LW" then
                -- Extremo izquierdo pegado a banda para desbordar y centrar (amplitud mÃ¡xima)
                targetZ = 78
                local minX = math.min(-halfX + 45, (halfX - 25) * attackDirX)
                local maxX = math.max(-halfX + 45, (halfX - 25) * attackDirX)
                local advX = safeClamp(ballPos.X + (35 * attackDirX), minX, maxX)
                return Vector3.new(advX, 3, targetZ)
            elseif roleId == "RW" then
                -- Extremo derecho pegado a banda para desbordar y centrar (amplitud mÃ¡xima)
                targetZ = -78
                local minX = math.min(-halfX + 45, (halfX - 25) * attackDirX)
                local maxX = math.max(-halfX + 45, (halfX - 25) * attackDirX)
                local advX = safeClamp(ballPos.X + (35 * attackDirX), minX, maxX)
                return Vector3.new(advX, 3, targetZ)
            else
                local attackX = (halfX - 30) * attackDirX
                local flankZ = safeClamp(ballPos.Z * 0.6, -35, 35)
                return Vector3.new(attackX, 3, flankZ)
            end
        elseif hasEnemyPossession then
            return Vector3.new(18 * attackDirX, 3, safeClamp(ballPos.Z * 0.35, -35, 35))
        else
            return Vector3.new(35 * attackDirX, 3, base.Z * 0.5)
        end

    elseif role == "Central" then
        if hasTeamPossession then
            if slot.roleId == "CDM" then
                -- Pivote de apoyo seguro detrÃ¡s de la lÃ­nea de pase
                local safeX = (ballPos.X * 0.5) + (10 * attackDirX)
                local safeZ = safeClamp(ballPos.Z * 0.35, -25, 25)
                return Vector3.new(safeClamp(safeX, -halfX + 60, halfX - 60), 3, safeZ)
            else
                -- Interiores (CM1, CM2): se abren activamente para ofrecer lÃ­nea de pase limpia
                local advancedX = (ballPos.X * 0.6) + (35 * attackDirX)
                local sideOffset = if slot.roleId == "CM1" then 32 else -32
                -- Si el portador estÃ¡ en el mismo cuadrante Z, abrirse hacia la banda libre
                local laneZ = sideOffset
                if math.abs(ballPos.Z - sideOffset) < 18 then
                    laneZ = sideOffset + (if sideOffset > 0 then 18 else -18)
                end
                return Vector3.new(safeClamp(advancedX, -halfX + 75, halfX - 45), 3, safeClamp(laneZ, -75, 75))
            end
        elseif hasEnemyPossession then
            local ownGoalX = -enemyGoalPos.X
            local shieldX = ownGoalX + (85 * attackDirX)
            return Vector3.new(shieldX, 3, base.Z * 0.7)
        else
            return Vector3.new(base.X + (25 * attackDirX), 3, base.Z)
        end

    elseif role == "Defensa" then
        if hasEnemyPossession then
            local ownGoalX = -enemyGoalPos.X
            -- Los laterales (LB, RB) vigilan sus bandas y entran a tapar si el balÃ³n o un extremo rival estÃ¡ abierto
            if slot.roleId == "LB" or slot.roleId == "RB" then
                local defLineX = ownGoalX + (55 * attackDirX)
                local trackZ = if math.abs(ballPos.Z - base.Z) < 35 then ballPos.Z else base.Z
                return Vector3.new(defLineX, 3, trackZ)
            else
                -- Los centrales (CB1, CB2) forman el embudo central
                local defLineX = ownGoalX + (42 * attackDirX)
                local shiftedZ = safeClamp(base.Z + (ballPos.Z * 0.35), -38, 38)
                return Vector3.new(defLineX, 3, shiftedZ)
            end
        elseif hasTeamPossession then
            -- Laterales (LB, RB) doblan por la banda y ofrecen salida activa
            if slot.roleId == "LB" or slot.roleId == "RB" then
                local wingX = safeClamp(ballPos.X - (5 * attackDirX), -halfX + 70, halfX - 40)
                return Vector3.new(wingX, 3, base.Z)
            else
                -- Centrales aseguran la retaguardia
                local ownGoalX = -enemyGoalPos.X
                local safeLineX = ownGoalX + (90 * attackDirX)
                return Vector3.new(safeLineX, 3, base.Z)
            end
        else
            return base
        end
    end

    return base
end

--------------------------------------------------------------------------------
-- 16. SISTEMA GLOBAL DE MARCAJE AL HOMBRE Y VIGILANCIA (1v1 Direct Man-Marking)
--------------------------------------------------------------------------------
local ROLE_MARK_TARGETS: { [string]: {string} } = {
    ["ST"]  = { "CB1", "CB2", "CDM" },
    ["LW"]  = { "RB", "CB2", "CM2" },
    ["RW"]  = { "LB", "CB1", "CM1" },
    ["CM1"] = { "CM2", "CDM", "CM1" },
    ["CM2"] = { "CM1", "CDM", "CM2" },
    ["CDM"] = { "ST", "CM1", "CM2" },
    ["LB"]  = { "RW", "ST", "CM2" },
    ["RB"]  = { "LW", "ST", "CM1" },
    ["CB1"] = { "ST", "RW", "CM1" },
    ["CB2"] = { "ST", "LW", "CM2" },
}

local function getAssignedMarkTarget(slot: BotSlot, enemyTeam: { [string]: BotSlot }): BotSlot?
    local targets = ROLE_MARK_TARGETS[slot.roleId]
    if targets then
        for _, tRoleId in ipairs(targets) do
            local oppSlot = enemyTeam[tRoleId]
            if oppSlot and oppSlot.model and oppSlot.model ~= currentOwner and oppSlot.model.Parent then
                local oHum = oppSlot.model:FindFirstChildOfClass("Humanoid")
                if oHum and oHum.Health > 0 then
                    return oppSlot
                end
            end
        end
    end

    local hrp = slot.model and slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return nil end

    local closest: BotSlot? = nil
    local minD = 9999
    for _, oppSlot in pairs(enemyTeam) do
        if oppSlot.model and oppSlot.model ~= currentOwner and oppSlot.model.Parent and oppSlot.role ~= "Portero" then
            local oHrp = oppSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if oHrp then
                local d = (oHrp.Position - hrp.Position).Magnitude
                if d < minD then
                    minD = d
                    closest = oppSlot
                end
            end
        end
    end
    return closest
end

local function updateBotSlotAI(
    slot: BotSlot,
    allyTeam: { [string]: BotSlot },
    enemyTeam: { [string]: BotSlot },
    designatedPresser: BotSlot?,
    enemyGoalPos: Vector3,
    gkPos: Vector3,
    now: number
)
    local bot = slot.model
    if not bot or not bot.Parent or isGoalCelebrating or isMatchPaused then return end

    local hrp = bot:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0

    local botStats = slot.stats
    local ballPos = if currentBall then currentBall.Position else Vector3.zero
    local distToBall = if currentBall then (ballPos - hrp.Position).Magnitude else 999

    local isOwner = (currentOwner == bot)
    local isAllyOwner = false
    local isEnemyOwner = false

    if currentOwner then
        local isRedOwner = (string.find(currentOwner.Name, "Rojo") ~= nil)
        local isSlotRed = (slot.teamName == "Rojo")
        if isRedOwner == isSlotRed then
            isAllyOwner = true
        else
            isEnemyOwner = true
        end
    end

    -- 1. POSESIÃ“N INDIVIDUAL
    if isOwner then
        local ownGoalX = -enemyGoalPos.X
        local distToOwnGoal = math.abs(hrp.Position.X - ownGoalX)
        if slot.role == "Defensa" and distToOwnGoal < 48 then
            executeClearance(slot, enemyGoalPos)
            return
        end

        local shouldShoot = evaluateShotOpportunity(slot, enemyGoalPos, enemyTeam, gkPos)

        if shouldShoot and (now - slot.lastShotTime >= 2.5) and not isKickOnCooldown then
            slot.lastShotTime = now
            lastToucherModel = bot
            lastToucherClub = slot.clubName
            releaseBall()
            isKickOnCooldown = true

            local shotMultiplier = getShotPowerMultiplier(botStats.shot)
            local goalPostTarget = enemyGoalPos
            if botStats.shot >= 85 then
                local sideOffset = if math.random() > 0.5 then (GOAL_WIDTH / 2 - 3) else -(GOAL_WIDTH / 2 - 3)
                goalPostTarget = enemyGoalPos + Vector3.new(0, math.random(2, 6), sideOffset)
            else
                local errorSpread = (100 - botStats.shot) * 0.12
                goalPostTarget = enemyGoalPos + Vector3.new(0, 0, (math.random() - 0.5) * errorSpread)
            end

            local shootDir = (goalPostTarget - hrp.Position).Unit
            local isAerial = (math.random(1, 100) <= 45)
            local liftY = if isAerial then math.random(18, 28) else math.random(6, 12)
            local speed = (135 * shotMultiplier)

            currentBall.CFrame = currentBall.CFrame + (shootDir * 2.5)
            currentBall.AssemblyLinearVelocity = (shootDir * speed) + Vector3.new(0, liftY, 0)
            currentBall.AssemblyAngularVelocity = Vector3.new(-shootDir.Z, 0, shootDir.X) * 50
            if botStats.shot >= 88 then igniteBallInFlames(2.5) end

            task.delay(0.4, function() isKickOnCooldown = false end)
            return
        end

        local timeSincePass = now - slot.lastPassTime
        if timeSincePass > slot.tactic.passThreshold and not isKickOnCooldown then
            local bestTarget, targetScore, passType = findBestPassTarget(slot, allyTeam, enemyTeam, slot.tactic)
            if bestTarget and targetScore > 8 then
                executePass(slot, bestTarget, passType)
                return
            end
        end

        local forwardDir = (Vector3.new(enemyGoalPos.X, 0, enemyGoalPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Unit
        local moveTarget = hrp.Position + (forwardDir * 35)

        -- SISTEMA DE REGATES Y ENCARAR DEFENSAS (1v1 Dribbling Skill Moves)
        local nearestEnemyDist = 999
        local nearestEnemyHrp: BasePart? = nil

        for _, eSlot in pairs(enemyTeam) do
            if eSlot.model and eSlot.model.Parent then
                local eHrp = eSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                if eHrp then
                    local toRival = eHrp.Position - hrp.Position
                    if toRival.Magnitude < nearestEnemyDist then
                        nearestEnemyDist = toRival.Magnitude
                        nearestEnemyHrp = eHrp
                    end
                end
            end
        end

        if nearestEnemyHrp and nearestEnemyDist < 26 then
            local toRival = nearestEnemyHrp.Position - hrp.Position
            if forwardDir:Dot(toRival.Unit) > 0.15 then
                -- Opciones de regate segÃºn el stat de regate del jugador
                local perpLeft = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
                local perpRight = Vector3.new(forwardDir.Z, 0, -forwardDir.X)
                
                -- Si el defensor tiene velocidad lateral, amagar al lado contrario
                local dodgeDir = if perpLeft:Dot(nearestEnemyHrp.AssemblyLinearVelocity) > 0 then perpRight else perpLeft

                -- Si tiene buen regate (>= 80), realiza cambio de ritmo / aceleraciÃ³n explosiva
                local normalSpeed = getWalkSpeedFromStat(botStats.speed)
                if botStats.dribble >= 80 then
                    humanoid.WalkSpeed = normalSpeed * 1.25
                else
                    humanoid.WalkSpeed = normalSpeed
                end

                -- Finta / recorte hacia espacio libre
                moveTarget = hrp.Position + ((forwardDir * 0.5 + dodgeDir * 0.7).Unit * 28)
            end
        else
            humanoid.WalkSpeed = getWalkSpeedFromStat(botStats.speed)
        end

        humanoid:MoveTo(moveTarget)
        return
    end

    -- 2. BLOQUE DEFENSIVO O PRESIÃ“N
    if isEnemyOwner then
        local stealRadius = getStealRadiusFromStat(botStats.defense)
        local stealCooldown = getStealCooldownFromStat(botStats.defense)

        if designatedPresser == slot and currentOwner then
            -- Solo el presser designado va a por el balÃ³n agresivamente
            local carrierHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
            if carrierHrp then
                humanoid:MoveTo(carrierHrp.Position)
                if (carrierHrp.Position - hrp.Position).Magnitude < stealRadius and (now - slot.lastStealTime >= stealCooldown) and not isKickOnCooldown then
                    slot.lastStealTime = now
                    
                    -- DUELO TÃCTICO: PROBABILIDAD DE ROBO VS REGATE
                    local carrierStats = characterStats[currentOwner]
                    local carrierDribble = if carrierStats then carrierStats.dribble else 70
                    local defenderDef = botStats.defense

                    -- Probabilidad calculada segÃºn los atributos reales
                    local stealChance = safeClamp(50 + (defenderDef - carrierDribble) * 1.1, 20, 85)
                    local roll = math.random(1, 100)

                    if roll <= stealChance then
                        attachBallToPlayer(bot)
                    else
                        -- El atacante supera la entrada con un regate exitoso (pequeÃ±o boost de evasiÃ³n)
                        isKickOnCooldown = true
                        task.delay(0.35, function() isKickOnCooldown = false end)
                    end
                end
                return
            end
        else
            -- Marcaje zonal / al hombre activo:
            local ownGoalX = -enemyGoalPos.X
            local distToOurGoal = math.abs(hrp.Position.X - ownGoalX)

            -- 1. Si el rival con balÃ³n se acerca peligrosamente a la frontal (menos de 55 studs de la porterÃ­a o 30 studs del defensa), entra a tapar/robar
            if (slot.role == "Defensa" or slot.roleId == "CDM") and distToBall < 38 then
                humanoid:MoveTo(ballPos)
                if distToBall < stealRadius and (now - slot.lastStealTime >= stealCooldown) and not isKickOnCooldown then
                    slot.lastStealTime = now
                    local carrierStats = characterStats[currentOwner]
                    local carrierDribble = if carrierStats then carrierStats.dribble else 70
                    local stealChance = safeClamp(50 + (botStats.defense - carrierDribble) * 1.1, 20, 85)
                    if math.random(1, 100) <= stealChance then
                        attachBallToPlayer(bot)
                    end
                end
                return
            end

            -- 2. MARCAJE AL HOMBRE ESTRICTO PARA TODOS LOS JUGADORES
            -- Vigilar, anticipar y limitar los movimientos del adversario emparejado
            local assignedOpp = getAssignedMarkTarget(slot, enemyTeam)
            if assignedOpp and assignedOpp.model and assignedOpp.model.Parent then
                local oppHrp = assignedOpp.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                if oppHrp then
                    -- PosiciÃ³n de marca: entre el adversario y nuestra porterÃ­a, pegado a 4.0 studs
                    local toOwnGoal = (Vector3.new(ownGoalX, 3, 0) - oppHrp.Position).Unit
                    -- Anticipar movimiento del rival segÃºn su velocidad lineal
                    local oppVel = oppHrp.AssemblyLinearVelocity
                    local leadVector = Vector3.new(oppVel.X, 0, oppVel.Z) * 0.25
                    local markPosition = oppHrp.Position + (toOwnGoal * 4.0) + leadVector
                    humanoid:MoveTo(markPosition)
                    return
                end
            end

            -- Si no tiene marca directa, mantener la formaciÃ³n tÃ¡ctica
            local tacticalPos = getTacticalPosition(slot, false, true, ballPos, enemyGoalPos)
            humanoid:MoveTo(tacticalPos)
            return
        end
    end

    -- 3. BALÃ“N SUELTO
    if currentOwner == nil and currentBall then
        local stealRadius = getStealRadiusFromStat(botStats.defense)

        -- Solo acude el presser designado o si el balÃ³n estÃ¡ muy pegado (< 20 studs)
        if designatedPresser == slot or distToBall < 20 then
            local bVel = currentBall.AssemblyLinearVelocity
            local interceptPos = if bVel.Magnitude > 10 then ballPos + Vector3.new(bVel.X, 0, bVel.Z) * 0.4 else ballPos
            humanoid:MoveTo(interceptPos)

            if distToBall < stealRadius and not isKickOnCooldown then
                attachBallToPlayer(bot)
            end
            return
        else
            local tacticalPos = getTacticalPosition(slot, false, false, ballPos, enemyGoalPos)
            humanoid:MoveTo(tacticalPos)
            return
        end
    end

    -- 4. APOYO AL COMPAÃ‘ERO EN ATAQUE
    if isAllyOwner then
        local tacticalPos = getTacticalPosition(slot, true, false, ballPos, enemyGoalPos)
        humanoid:MoveTo(tacticalPos)
        return
    end
end

local function runTeamCoordinator(
    allyTeam: { [string]: BotSlot },
    enemyTeam: { [string]: BotSlot },
    enemyGoalPos: Vector3,
    gkPos: Vector3,
    now: number
)
    local bestPresserSlot: BotSlot? = nil
    local minDistance = 9999

    local targetItemPos = if currentBall then currentBall.Position else Vector3.zero
    if currentOwner then
        local cHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
        if cHrp then targetItemPos = cHrp.Position end
    end

    -- Si el rival avanza por el centro hacia nuestra porterÃ­a, los centrales y el pivote tienen mÃ¡xima prioridad para salir al paso
    local ownGoalX = -enemyGoalPos.X
    local distToOurGoal = math.abs(targetItemPos.X - ownGoalX)

    for roleId, slot in pairs(allyTeam) do
        if slot.model and slot.model.Parent and slot.role ~= "Portero" then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            local hum = slot.model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - targetItemPos).Magnitude
                local distWeight = dist

                -- Si el portador viene por el centro hacia el Ã¡rea propia, CBs y CDM deben salir a frenarlo sin penalizaciÃ³n
                if slot.roleId == "CDM" and math.abs(targetItemPos.Z) < 35 then
                    distWeight = distWeight * 0.7
                elseif (slot.roleId == "CB1" or slot.roleId == "CB2") and distToOurGoal < 85 then
                    distWeight = distWeight * 0.75
                elseif (slot.roleId == "LB" or slot.roleId == "RB") and math.abs(targetItemPos.Z - slot.basePosition.Z) < 30 then
                    distWeight = distWeight * 0.7
                end

                if distWeight < minDistance then
                    minDistance = distWeight
                    bestPresserSlot = slot
                end
            end
        end
    end

    for roleId, slot in pairs(allyTeam) do
        updateBotSlotAI(slot, allyTeam, enemyTeam, bestPresserSlot, enemyGoalPos, gkPos, now)
    end
end

--------------------------------------------------------------------------------
-- 17. IA DE PORTEROS (DISTRIBUCIÃ“N Y PARADAS)
--------------------------------------------------------------------------------
local function updateGoalkeeperAI(gk: Model?, goalX: number)
    if isMatchPaused or not gk or not gk.Parent or isGoalCelebrating then return end
    local hrp = gk:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = gk:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local goalCenter = Vector3.new(goalX, 3, 0)
    local isLeftGoal = (goalX < 0)

    if currentBall and currentBall.Parent then
        local ballPos = currentBall.Position
        local ballVel = currentBall.AssemblyLinearVelocity

        local predictedZ = ballPos.Z
        local timeToReach = 0
        local headingTowardsGoal = false

        if isLeftGoal and ballVel.X < -5 then
            timeToReach = (goalX - ballPos.X) / ballVel.X
            if timeToReach > 0 and timeToReach < 2.5 then
                predictedZ = ballPos.Z + (ballVel.Z * timeToReach)
                headingTowardsGoal = true
            end
        elseif (not isLeftGoal) and ballVel.X > 5 then
            timeToReach = (goalX - ballPos.X) / ballVel.X
            if timeToReach > 0 and timeToReach < 2.5 then
                predictedZ = ballPos.Z + (ballVel.Z * timeToReach)
                headingTowardsGoal = true
            end
        end

        local reactionJitter = (math.sin(os.clock() * 5) * 0.4)

        if headingTowardsGoal then
            local targetZ = safeClamp(predictedZ + reactionJitter, -(GOAL_WIDTH / 2 - 1.5), (GOAL_WIDTH / 2 - 1.5))
            local distZ = math.abs(hrp.Position.Z - targetZ)

            local isBallHigh = (ballPos.Y > 6 or (ballVel.Y > 5 and timeToReach < 1.0))
            if isBallHigh and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            if distZ > 4 and timeToReach < 0.8 then
                humanoid.WalkSpeed = 52
                local diveDir = Vector3.new(0, 0, math.sign(targetZ - hrp.Position.Z))
                hrp.AssemblyLinearVelocity = Vector3.new(0, 10, diveDir.Z * 36)
            else
                humanoid.WalkSpeed = 42
            end
            humanoid:MoveTo(Vector3.new(goalX, 3, targetZ))
        else
            local toBall = (ballPos - goalCenter)
            local flatDir = Vector3.new(toBall.X, 0, toBall.Z).Unit
            local advance = safeClamp(toBall.Magnitude * 0.08, 0, 10)
            local targetPos = goalCenter + (flatDir * advance)
            
            targetPos = Vector3.new(
                if isLeftGoal then safeClamp(targetPos.X, goalX, goalX + 11) else safeClamp(targetPos.X, goalX - 11, goalX),
                3,
                safeClamp(targetPos.Z, -(GOAL_WIDTH / 2 - 2), (GOAL_WIDTH / 2 - 2))
            )

            humanoid.WalkSpeed = 26
            humanoid:MoveTo(targetPos)
        end
    else
        humanoid.WalkSpeed = 20
        humanoid:MoveTo(goalCenter)
    end
end

local isGkHandling = false
local function handleGkCatch(gk: Model, teamName: string, posX: number)
    if isMatchPaused or not currentBall or isKickOnCooldown or isGoalCelebrating or isGkHandling then return end

    local hrp = gk:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    local ballSpeed = currentBall.AssemblyLinearVelocity.Magnitude
    if ballSpeed > 130 then
        local failChance = safeClamp((ballSpeed - 130) * 1.5, 5, 25)
        if math.random(1, 100) <= failChance then
            local deflectDir = Vector3.new(if posX < 0 then 1 else -1, 0.4, (math.random() - 0.5) * 1.5).Unit
            currentBall.AssemblyLinearVelocity = deflectDir * (ballSpeed * 0.65)
            return
        end
    end

    isGkHandling = true
    lastToucherModel = gk
    lastToucherClub = characterClub[gk] or ""
    releaseBall()
    isKickOnCooldown = true

    currentBall.AssemblyLinearVelocity = Vector3.zero
    currentBall.AssemblyAngularVelocity = Vector3.zero
    currentBall.CFrame = hrp.CFrame * CFrame.new(0, -1, -2.5)

    task.delay(0.5, function()
        if not currentBall then
            isGkHandling = false
            isKickOnCooldown = false
            return
        end

        local allySlots = if teamName == "Azul" then teamBlueBots else teamRedBots
        local enemySlots = if teamName == "Azul" then teamRedBots else teamBlueBots
        local tactic = if teamName == "Azul" then currentClubA.tactic else currentClubB.tactic

        local bestTarget, score, passType = findBestPassTarget(
            if teamName == "Azul" then gkSlotBlue else gkSlotRed,
            allySlots,
            enemySlots,
            tactic
        )

        local outwardX = if posX < 0 then 1 else -1
        local unitDir: Vector3
        local speed: number
        local liftY: number

        if bestTarget then
            local bHrp = bestTarget.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if bHrp then
                local toTarget = (bHrp.Position - hrp.Position)
                unitDir = Vector3.new(toTarget.X, 0, toTarget.Z).Unit
                local dist = toTarget.Magnitude
                if dist < 65 then
                    speed = safeClamp(dist * 1.35, 45, 75)
                    liftY = 4
                else
                    speed = safeClamp(dist * 1.4, 70, 105)
                    liftY = 18
                end
            else
                unitDir = Vector3.new(outwardX, 0, 0)
                speed = 85
                liftY = 16
            end
        else
            unitDir = Vector3.new(outwardX, 0, (math.random() - 0.5) * 0.8).Unit
            speed = 90
            liftY = 18
        end

        currentBall.CFrame = currentBall.CFrame + (unitDir * 2.5) + Vector3.new(0, 0.6, 0)
        currentBall.AssemblyLinearVelocity = (unitDir * speed) + Vector3.new(0, liftY, 0)

        task.delay(0.5, function()
            isKickOnCooldown = false
            isGkHandling = false
        end)
    end)
end

--------------------------------------------------------------------------------
-- 18. BUCLE DEL RELOJ DE PARTIDO
--------------------------------------------------------------------------------
local lastClockTick = os.clock()

local function updateMatchClock()
    local realDt = os.clock() - lastClockTick
    lastClockTick = os.clock()

    if not isMatchStarted or isMatchPaused then
        if not isMatchStarted then
            matchTimeEvent:FireAllClients("00:00", "EN ESPERA", false)
        end
        return
    end

    local gameDt = realDt * 18

    if currentMatchState == MATCH_STATE_FIRST_HALF then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)

        if curMinute >= 45 then
            currentMatchState = MATCH_STATE_FIRST_EXTRA
            firstHalfAddedMins = math.random(1, 10)
            print(string.format("[PARTIDO] Tiempo aÃ±adido 1ra parte: +%d minutos", firstHalfAddedMins))
        else
            local timeText = string.format("%02d:%02d", curMinute, curSec)
            matchTimeEvent:FireAllClients(timeText, "PRIMERA PARTE", false)
        end

    elseif currentMatchState == MATCH_STATE_FIRST_EXTRA then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)
        local timeText = string.format("45+%d' (%02d:%02d)", firstHalfAddedMins, curMinute, curSec)
        matchTimeEvent:FireAllClients(timeText, "TIEMPO AÃ‘ADIDO", true)

        if curMinute >= (45 + firstHalfAddedMins) then
            currentMatchState = MATCH_STATE_HALFTIME
            isMatchPaused = true
            halftimeRealSecondsLeft = 60
            releaseBall()

            -- El Ã¡rbitro recoge el balÃ³n para el descanso
            if refereeModel and currentBall then
                attachBallToPlayer(refereeModel)
                local rHum = refereeModel:FindFirstChildOfClass("Humanoid")
                if rHum then rHum:MoveTo(Vector3.new(0, 3, 25)) end
            end
            print("[PARTIDO] Â¡DESCANSO! El Ã¡rbitro se lleva el balÃ³n a vestuarios.")
        end

    elseif currentMatchState == MATCH_STATE_HALFTIME then
        halftimeRealSecondsLeft = halftimeRealSecondsLeft - realDt
        local statusMsg = string.format("DESCANSO (%ds)", math.max(0, math.ceil(halftimeRealSecondsLeft)))
        matchTimeEvent:FireAllClients("45:00", statusMsg, true)

        if halftimeRealSecondsLeft <= 0 then
            currentPeriodSideSwapped = true
            currentMatchState = MATCH_STATE_SECOND_HALF
            matchGameSeconds = 45 * 60
            isMatchPaused = false

            for roleId, data in pairs(FORMATION_EAST) do
                if teamBlueBots[roleId] then teamBlueBots[roleId].basePosition = data.pos end
            end
            for roleId, data in pairs(FORMATION_WEST) do
                if teamRedBots[roleId] then teamRedBots[roleId].basePosition = data.pos end
            end

            resetPositionsToField()
            spawnBall(CFrame.new(0, 2.5, 0))
            print("[PARTIDO] Â¡Comienza la Segunda Parte! Equipos cambian de lado.")
        end

    elseif currentMatchState == MATCH_STATE_SECOND_HALF then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)

        if curMinute >= 90 then
            currentMatchState = MATCH_STATE_SECOND_EXTRA
            secondHalfAddedMins = math.random(1, 10)
            print(string.format("[PARTIDO] Tiempo aÃ±adido 2da parte: +%d minutos", secondHalfAddedMins))
        else
            local timeText = string.format("%02d:%02d", curMinute, curSec)
            matchTimeEvent:FireAllClients(timeText, "SEGUNDA PARTE", false)
        end

    elseif currentMatchState == MATCH_STATE_SECOND_EXTRA then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)
        local timeText = string.format("90+%d' (%02d:%02d)", secondHalfAddedMins, curMinute, curSec)
        matchTimeEvent:FireAllClients(timeText, "TIEMPO AÃ‘ADIDO", true)

        if curMinute >= (90 + secondHalfAddedMins) then
            currentMatchState = MATCH_STATE_FULLTIME
            isMatchPaused = true
            fulltimeRealSecondsLeft = 60
            releaseBall()

            -- El Ã¡rbitro recoge el balÃ³n tras el pitido final
            if refereeModel and currentBall then
                attachBallToPlayer(refereeModel)
                local rHum = refereeModel:FindFirstChildOfClass("Humanoid")
                if rHum then rHum:MoveTo(Vector3.new(0, 3, 25)) end
            end
            print(string.format("[PARTIDO] Â¡FINAL DEL PARTIDO! %s %d - %d %s. El Ã¡rbitro se lleva el balÃ³n.", currentClubA.name, scoreBlue, scoreRed, currentClubB.name))
        end

    elseif currentMatchState == MATCH_STATE_FULLTIME then
        fulltimeRealSecondsLeft = fulltimeRealSecondsLeft - realDt
        local statusMsg = string.format("FINAL DEL PARTIDO (%ds)", math.max(0, math.ceil(fulltimeRealSecondsLeft)))
        matchTimeEvent:FireAllClients("90:00", statusMsg, true)

        if fulltimeRealSecondsLeft <= 0 then
            currentPeriodSideSwapped = false
            currentMatchState = MATCH_STATE_FIRST_HALF
            matchGameSeconds = 0
            firstHalfAddedMins = 0
            secondHalfAddedMins = 0
            scoreBlue = 0
            scoreRed = 0
            isMatchPaused = false

            spawnFull6v6Match()
            resetPositionsToField()
            spawnBall(CFrame.new(0, 2.5, 0))
            print("[PARTIDO] Nuevo encuentro iniciado automÃ¡ticamente (00:00).")
        end
    end
end

--------------------------------------------------------------------------------
-- 19. BUCLE PRINCIPAL HEARTBEAT
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    updateMatchClock()

    local blueGKX = if currentPeriodSideSwapped then (halfX - 4) else (-halfX + 4)
    local redGKX = if currentPeriodSideSwapped then (-halfX + 4) else (halfX - 4)

    updateGoalkeeperAI(goalkeeperBlue, blueGKX)
    updateGoalkeeperAI(goalkeeperRed, redGKX)

    if currentBall and not isKickOnCooldown and not isMatchPaused and not isGoalCelebrating then
        if goalkeeperBlue and goalkeeperBlue.Parent then
            local shield = goalkeeperBlue:FindFirstChild("ImpossibleShield") :: BasePart?
            if shield and (shield.Position - currentBall.Position).Magnitude < 14 then
                handleGkCatch(goalkeeperBlue, "Azul", blueGKX)
            end
        end
        if goalkeeperRed and goalkeeperRed.Parent then
            local shield = goalkeeperRed:FindFirstChild("ImpossibleShield") :: BasePart?
            if shield and (shield.Position - currentBall.Position).Magnitude < 14 then
                handleGkCatch(goalkeeperRed, "Rojo", redGKX)
            end
        end
    end

    local now = os.clock()

    -- CONTROL REGLAMENTARIO DE LÃMITES: SAQUES DE BANDA Y CÃ“RNERS
    if currentBall and not isGoalCelebrating and isMatchStarted then
        local bPos = currentBall.Position
        local outOfBounds = false
        local isSideline = false
        local isCorner = false
        local restartPos = Vector3.new(0, 2.5, 0)

        -- 1. Saque de Banda (LÃ­neas Norte y Sur)
        if math.abs(bPos.Z) > (halfY + 2) then
            outOfBounds = true
            isSideline = true
            local restartX = safeClamp(bPos.X, -halfX + 10, halfX - 10)
            local restartZ = if bPos.Z > 0 then (halfY - 4) else (-halfY + 4)
            restartPos = Vector3.new(restartX, 2.5, restartZ)

        -- 2. Fondo / CÃ³rner (LÃ­neas Este y Oeste fuera de porterÃ­a)
        elseif math.abs(bPos.X) > (halfX + 2) then
            -- Solo si no es gol (si no estÃ¡ dentro del marco de la porterÃ­a)
            if math.abs(bPos.Z) > (GOAL_WIDTH / 2 + 1) or bPos.Y > (GOAL_HEIGHT + 1) then
                outOfBounds = true
                isCorner = true
                -- Ubicar en el cÃ³rner mÃ¡s cercano
                local cornerX = if bPos.X > 0 then (halfX - 4) else (-halfX + 4)
                local cornerZ = if bPos.Z > 0 then (halfY - 4) else (-halfY + 4)
                restartPos = Vector3.new(cornerX, 2.5, cornerZ)
            end
        end

        if outOfBounds and not isKickOnCooldown then
            releaseBall()
            isKickOnCooldown = true

            -- Reubicar balÃ³n en el punto de saque
            currentBall.AssemblyLinearVelocity = Vector3.zero
            currentBall.AssemblyAngularVelocity = Vector3.zero
            currentBall.CFrame = CFrame.new(restartPos)

            -- Determinar a quiÃ©n le toca sacar (al equipo contrario del que tocÃ³ por Ãºltima vez)
            local lastWasRed = (lastToucherModel and string.find(lastToucherModel.Name, "Rojo") ~= nil)
            local awardTeam = if lastWasRed then "Azul" else "Rojo"
            local awardBots = if awardTeam == "Azul" then teamBlueBots else teamRedBots

            -- Encontrar el bot mÃ¡s cercano al punto de saque para ejecutarlo
            local takerSlot: BotSlot? = nil
            local minTakerDist = 9999
            for _, slot in pairs(awardBots) do
                if slot.model and slot.role ~= "Portero" then
                    local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if hrp then
                        local d = (hrp.Position - restartPos).Magnitude
                        if d < minTakerDist then
                            minTakerDist = d
                            takerSlot = slot
                        end
                    end
                end
            end

            if takerSlot and takerSlot.model then
                local takerHrp = takerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                if takerHrp then
                    takerHrp.CFrame = CFrame.new(restartPos + Vector3.new(0, 0, (if restartPos.Z > 0 then 4 else -4)))
                    task.delay(0.6, function()
                        attachBallToPlayer(takerSlot.model)
                        isKickOnCooldown = false
                    end)
                else
                    task.delay(0.8, function() isKickOnCooldown = false end)
                end
            else
                task.delay(0.8, function() isKickOnCooldown = false end)
            end

            if isCorner then
                print(string.format("[REGLAMENTO] Â¡CÃ“RNER para el equipo %s!", awardTeam))
            elseif isSideline then
                print(string.format("[REGLAMENTO] Â¡SAQUE DE BANDA para el equipo %s!", awardTeam))
            end
        end
    end

    if not isMatchPaused then
        local blueTargetGoal = if currentPeriodSideSwapped then BLUE_GOAL_CENTER else RED_GOAL_CENTER
        local redTargetGoal  = if currentPeriodSideSwapped then RED_GOAL_CENTER else BLUE_GOAL_CENTER

        local redGkPos = if goalkeeperRed and goalkeeperRed.Parent and goalkeeperRed.PrimaryPart then goalkeeperRed.PrimaryPart.Position else redTargetGoal
        local blueGkPos = if goalkeeperBlue and goalkeeperBlue.Parent and goalkeeperBlue.PrimaryPart then goalkeeperBlue.PrimaryPart.Position else blueTargetGoal

        runTeamCoordinator(teamBlueBots, teamRedBots, blueTargetGoal, redGkPos, now)
        runTeamCoordinator(teamRedBots, teamBlueBots, redTargetGoal, blueGkPos, now)

        -- IA del Ãrbitro en juego: sigue la acciÃ³n manteniÃ©ndose en diagonal a una distancia neutral
        if refereeModel and refereeModel.Parent and currentBall then
            local refHrp = refereeModel:FindFirstChild("HumanoidRootPart") :: BasePart?
            local refHum = refereeModel:FindFirstChildOfClass("Humanoid")
            if refHrp and refHum then
                local bPos = currentBall.Position
                -- Se coloca a unos 22 studs en diagonal al balÃ³n sin obstaculizar las jugadas
                local refTarget = Vector3.new(bPos.X * 0.85, 3, bPos.Z * 0.4 + (if bPos.Z > 0 then -22 else 22))
                refHum:MoveTo(refTarget)
            end
        end

        if currentOwner and currentBall and not isKickOnCooldown then
            for _, pl in ipairs(Players:GetPlayers()) do
                local pChar = pl.Character
                if pChar and pChar ~= currentOwner then
                    local pHrp = pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
                    local pStats = characterStats[pChar]
                    local pRadius = if pStats then getStealRadiusFromStat(pStats.defense) else 4.5
                    if pHrp and (pHrp.Position - currentBall.Position).Magnitude < pRadius then
                        attachBallToPlayer(pChar)
                        break
                    end
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- 20. COMANDOS DE CHAT
--------------------------------------------------------------------------------
local function handleChatMessage(player: Player, rawMessage: string)
    local clean = string.lower(string.match(rawMessage, "^%s*(.-)%s*$") or rawMessage)
    
    if clean == "/bot" or clean == "bot" or clean == "!bot" then
        currentPeriodSideSwapped = false
        currentMatchState = MATCH_STATE_FIRST_HALF
        matchGameSeconds = 0
        scoreBlue = 0
        scoreRed = 0
        isMatchPaused = false
        isMatchStarted = true
        spawnFull6v6Match()
        resetPositionsToField()
        spawnBall(CFrame.new(0, 2.5, 0))
    elseif clean == "/limpiar" or clean == "/stop" or clean == "!stop" then
        cleanTeam(teamBlueBots)
        cleanTeam(teamRedBots)
        releaseBall()
        isMatchStarted = false
        isMatchPaused = true
        matchTimeEvent:FireAllClients("00:00", "EN ESPERA", false)
        print("[SERVIDOR] Partido detenido y bots eliminados.")
    elseif clean == "ball!" or clean == "/ball!" or clean == "ball" then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        local cf = (hrp and (hrp.CFrame * CFrame.new(0, 0, -4))) or CFrame.new(0, 2.5, 0)
        spawnBall(cf)
    end
end

pcall(function()
    local textChannels = TextChatService:FindFirstChild("TextChannels")
    if textChannels then
        local function attachChannel(channel: Instance)
            if channel:IsA("TextChannel") then
                channel.MessageReceived:Connect(function(textChatMessage)
                    local textSource = textChatMessage.TextSource
                    if textSource then
                        local sender = Players:GetPlayerByUserId(textSource.UserId)
                        if sender then
                            handleChatMessage(sender, textChatMessage.Text)
                        end
                    end
                end)
            end
        end
        for _, ch in ipairs(textChannels:GetChildren()) do
            attachChannel(ch)
        end
        textChannels.ChildAdded:Connect(attachChannel)
    end

    TextChatService.MessageReceived:Connect(function(textChatMessage)
        local textSource = textChatMessage.TextSource
        if textSource then
            local sender = Players:GetPlayerByUserId(textSource.UserId)
            if sender then
                handleChatMessage(sender, textChatMessage.Text)
            end
        end
    end)
end)

toggleMatchEvent.OnServerEvent:Connect(function(player)
    if not isMatchStarted then
        currentPeriodSideSwapped = false
        currentMatchState = MATCH_STATE_FIRST_HALF
        matchGameSeconds = 0
        scoreBlue = 0
        scoreRed = 0
        isMatchPaused = false
        isMatchStarted = true
        spawnFull6v6Match()
        resetPositionsToField()
        spawnBall(CFrame.new(0, 2.5, 0))
    else
        cleanTeam(teamBlueBots)
        cleanTeam(teamRedBots)
        releaseBall()
        isMatchStarted = false
        isMatchPaused = true
        matchTimeEvent:FireAllClients("00:00", "EN ESPERA", false)
        print("[SERVIDOR] Partido detenido desde botÃ³n de interfaz.")
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
        local hum = character:WaitForChild("Humanoid", 5) :: Humanoid?
        if hrp then
            hrp.Anchored = true
            hrp.CFrame = CFrame.new(0, 180, 0)
        end
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end)
    player.Chatted:Connect(function(msg)
        handleChatMessage(player, msg)
    end)
    updateScoreEvent:FireClient(player, scoreBlue, scoreRed, currentClubA.name, currentClubB.name)
end)

Players.PlayerRemoving:Connect(function(player)
    if currentOwner and currentOwner.Name == player.Name then
        releaseBall()
    end
end)
