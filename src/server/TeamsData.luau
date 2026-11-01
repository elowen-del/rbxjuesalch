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
    {name = "Kylian Mbappé", role = "Delantero", posTag = "ST", speed = 98, shot = 94, pass = 82, defense = 38, dribble = 93, stamina = 89, control = 92, physical = 78},
    {name = "Erling Haaland", role = "Delantero", posTag = "ST", speed = 91, shot = 96, pass = 68, defense = 45, dribble = 80, stamina = 88, control = 85, physical = 91},
    {name = "Lionel Messi", role = "Delantero", posTag = "ST", speed = 82, shot = 95, pass = 94, defense = 35, dribble = 96, stamina = 75, control = 97, physical = 66},
    {name = "Cristiano Ronaldo", role = "Delantero", posTag = "ST", speed = 84, shot = 95, pass = 78, defense = 36, dribble = 82, stamina = 79, control = 88, physical = 84},
    {name = "Vinícius Júnior", role = "Delantero", posTag = "ST", speed = 97, shot = 88, pass = 82, defense = 34, dribble = 95, stamina = 87, control = 93, physical = 70},
    {name = "Robert Lewandowski", role = "Delantero", posTag = "ST", speed = 76, shot = 93, pass = 80, defense = 42, dribble = 84, stamina = 79, control = 89, physical = 83},
    {name = "Harry Kane", role = "Delantero", posTag = "ST", speed = 73, shot = 95, pass = 88, defense = 48, dribble = 83, stamina = 83, control = 89, physical = 84},
    {name = "Mohamed Salah", role = "Delantero", posTag = "ST", speed = 92, shot = 91, pass = 84, defense = 45, dribble = 90, stamina = 86, control = 89, physical = 76},
    {name = "Lamine Yamal", role = "Delantero", posTag = "ST", speed = 92, shot = 85, pass = 87, defense = 36, dribble = 92, stamina = 84, control = 90, physical = 68},
    {name = "Lautaro Martínez", role = "Delantero", posTag = "ST", speed = 83, shot = 90, pass = 76, defense = 48, dribble = 86, stamina = 86, control = 87, physical = 84},
    {name = "Victor Osimhen", role = "Delantero", posTag = "ST", speed = 90, shot = 88, pass = 66, defense = 42, dribble = 80, stamina = 84, control = 82, physical = 85},
    {name = "Julián Álvarez", role = "Delantero", posTag = "ST", speed = 86, shot = 88, pass = 82, defense = 55, dribble = 85, stamina = 90, control = 87, physical = 78},
    {name = "Antoine Griezmann", role = "Delantero", posTag = "ST", speed = 80, shot = 88, pass = 89, defense = 60, dribble = 87, stamina = 88, control = 89, physical = 74},
    {name = "Rodrygo Goes", role = "Delantero", posTag = "ST", speed = 90, shot = 85, pass = 82, defense = 38, dribble = 89, stamina = 83, control = 88, physical = 68},
    {name = "Rafael Leão", role = "Delantero", posTag = "ST", speed = 94, shot = 84, pass = 79, defense = 32, dribble = 91, stamina = 81, control = 88, physical = 79},
    {name = "Son Heung-min", role = "Delantero", posTag = "ST", speed = 88, shot = 90, pass = 82, defense = 44, dribble = 85, stamina = 84, control = 86, physical = 72},
    {name = "Bukayo Saka", role = "Delantero", posTag = "ST", speed = 87, shot = 85, pass = 84, defense = 58, dribble = 88, stamina = 87, control = 87, physical = 76},
    {name = "Darwin Núñez", role = "Delantero", posTag = "ST", speed = 91, shot = 84, pass = 72, defense = 46, dribble = 78, stamina = 86, control = 80, physical = 88},
    {name = "Neymar Jr", role = "Delantero", posTag = "ST", speed = 85, shot = 87, pass = 88, defense = 34, dribble = 94, stamina = 70, control = 94, physical = 63},
    {name = "Karim Benzema", role = "Delantero", posTag = "ST", speed = 78, shot = 90, pass = 84, defense = 40, dribble = 86, stamina = 76, control = 90, physical = 78},

    -- CENTROCAMPISTAS (CM)
    {name = "Kevin De Bruyne", role = "Central", posTag = "CM", speed = 74, shot = 88, pass = 95, defense = 65, dribble = 86, stamina = 82, control = 92, physical = 75},
    {name = "Jude Bellingham", role = "Central", posTag = "CM", speed = 83, shot = 87, pass = 86, defense = 80, dribble = 88, stamina = 92, control = 90, physical = 85},
    {name = "Rodri Hernández", role = "Central", posTag = "CM", speed = 68, shot = 82, pass = 90, defense = 89, dribble = 82, stamina = 93, control = 89, physical = 86},
    {name = "Luka Modrić", role = "Central", posTag = "CM", speed = 72, shot = 80, pass = 91, defense = 72, dribble = 88, stamina = 78, control = 92, physical = 67},
    {name = "Federico Valverde", role = "Central", posTag = "CM", speed = 90, shot = 85, pass = 84, defense = 80, dribble = 84, stamina = 96, control = 86, physical = 83},
    {name = "Pedri González", role = "Central", posTag = "CM", speed = 78, shot = 76, pass = 90, defense = 70, dribble = 90, stamina = 84, control = 92, physical = 68},
    {name = "Martin Ødegaard", role = "Central", posTag = "CM", speed = 77, shot = 83, pass = 91, defense = 62, dribble = 89, stamina = 87, control = 91, physical = 68},
    {name = "Bernardo Silva", role = "Central", posTag = "CM", speed = 78, shot = 80, pass = 89, defense = 68, dribble = 92, stamina = 93, control = 92, physical = 69},
    {name = "Declan Rice", role = "Central", posTag = "CM", speed = 76, shot = 74, pass = 83, defense = 88, dribble = 79, stamina = 93, control = 83, physical = 86},
    {name = "Toni Kroos", role = "Central", posTag = "CM", speed = 60, shot = 83, pass = 94, defense = 72, dribble = 81, stamina = 75, control = 92, physical = 70},
    {name = "Eduardo Camavinga", role = "Central", posTag = "CM", speed = 84, shot = 73, pass = 83, defense = 82, dribble = 84, stamina = 88, control = 86, physical = 81},
    {name = "Nicolò Barella", role = "Central", posTag = "CM", speed = 81, shot = 78, pass = 85, defense = 78, dribble = 85, stamina = 94, control = 86, physical = 76},
    {name = "Bruno Fernandes", role = "Central", posTag = "CM", speed = 75, shot = 86, pass = 90, defense = 68, dribble = 83, stamina = 92, control = 87, physical = 75},
    {name = "Frenkie de Jong", role = "Central", posTag = "CM", speed = 82, shot = 72, pass = 87, defense = 77, dribble = 89, stamina = 87, control = 90, physical = 78},
    {name = "Alexis Mac Allister", role = "Central", posTag = "CM", speed = 74, shot = 80, pass = 86, defense = 76, dribble = 83, stamina = 86, control = 86, physical = 75},
    {name = "Aurélien Tchouaméni", role = "Central", posTag = "CM", speed = 74, shot = 75, pass = 82, defense = 85, dribble = 79, stamina = 88, control = 83, physical = 85},
    {name = "Gavi Páez", role = "Central", posTag = "CM", speed = 78, shot = 70, pass = 81, defense = 76, dribble = 84, stamina = 92, control = 84, physical = 74},
    {name = "Hakan Çalhanoğlu", role = "Central", posTag = "CM", speed = 70, shot = 85, pass = 89, defense = 74, dribble = 82, stamina = 84, control = 86, physical = 73},
    {name = "Enzo Fernández", role = "Central", posTag = "CM", speed = 72, shot = 78, pass = 86, defense = 75, dribble = 81, stamina = 85, control = 85, physical = 77},
    {name = "N'Golo Kanté", role = "Central", posTag = "CM", speed = 78, shot = 66, pass = 78, defense = 87, dribble = 80, stamina = 93, control = 82, physical = 80},

    -- DEFENSAS (DEF)
    {name = "Virgil van Dijk", role = "Defensa", posTag = "DEF", speed = 80, shot = 60, pass = 74, defense = 92, dribble = 72, stamina = 85, control = 81, physical = 91},
    {name = "Rúben Dias", role = "Defensa", posTag = "DEF", speed = 73, shot = 45, pass = 72, defense = 90, dribble = 69, stamina = 88, control = 78, physical = 89},
    {name = "Antonio Rüdiger", role = "Defensa", posTag = "DEF", speed = 88, shot = 55, pass = 71, defense = 87, dribble = 68, stamina = 89, control = 76, physical = 90},
    {name = "William Saliba", role = "Defensa", posTag = "DEF", speed = 82, shot = 42, pass = 74, defense = 88, dribble = 72, stamina = 86, control = 80, physical = 85},
    {name = "Marquinhos Aoás", role = "Defensa", posTag = "DEF", speed = 78, shot = 53, pass = 75, defense = 88, dribble = 74, stamina = 84, control = 80, physical = 82},
    {name = "Alessandro Bastoni", role = "Defensa", posTag = "DEF", speed = 75, shot = 50, pass = 82, defense = 87, dribble = 76, stamina = 83, control = 82, physical = 84},
    {name = "Ronald Araújo", role = "Defensa", posTag = "DEF", speed = 84, shot = 50, pass = 66, defense = 87, dribble = 64, stamina = 84, control = 73, physical = 88},
    {name = "Éder Militão", role = "Defensa", posTag = "DEF", speed = 85, shot = 52, pass = 70, defense = 86, dribble = 71, stamina = 85, control = 77, physical = 84},
    {name = "Theo Hernández", role = "Defensa", posTag = "DEF", speed = 94, shot = 74, pass = 78, defense = 80, dribble = 84, stamina = 90, control = 82, physical = 84},
    {name = "Kyle Walker", role = "Defensa", posTag = "DEF", speed = 92, shot = 63, pass = 77, defense = 82, dribble = 78, stamina = 86, control = 79, physical = 84},
    {name = "Trent Alexander-Arnold", role = "Defensa", posTag = "DEF", speed = 78, shot = 76, pass = 91, defense = 76, dribble = 81, stamina = 85, control = 85, physical = 74},
    {name = "Dani Carvajal", role = "Defensa", posTag = "DEF", speed = 82, shot = 58, pass = 79, defense = 84, dribble = 80, stamina = 88, control = 82, physical = 82},
    {name = "Achraf Hakimi", role = "Defensa", posTag = "DEF", speed = 93, shot = 75, pass = 80, defense = 78, dribble = 83, stamina = 89, control = 82, physical = 78},
    {name = "Alphonso Davies", role = "Defensa", posTag = "DEF", speed = 95, shot = 68, pass = 78, defense = 76, dribble = 86, stamina = 86, control = 83, physical = 78},
    {name = "Jules Koundé", role = "Defensa", posTag = "DEF", speed = 84, shot = 48, pass = 74, defense = 86, dribble = 75, stamina = 84, control = 79, physical = 81},
    {name = "Gabriel Magalhães", role = "Defensa", posTag = "DEF", speed = 72, shot = 45, pass = 69, defense = 86, dribble = 65, stamina = 85, control = 74, physical = 87},
    {name = "Josko Gvardiol", role = "Defensa", posTag = "DEF", speed = 80, shot = 65, pass = 78, defense = 84, dribble = 79, stamina = 85, control = 81, physical = 85},
    {name = "Cristian Romero", role = "Defensa", posTag = "DEF", speed = 76, shot = 48, pass = 68, defense = 85, dribble = 66, stamina = 85, control = 73, physical = 86},
    {name = "Lisandro Martínez", role = "Defensa", posTag = "DEF", speed = 76, shot = 55, pass = 80, defense = 84, dribble = 76, stamina = 84, control = 80, physical = 82},
    {name = "Federico Dimarco", role = "Defensa", posTag = "DEF", speed = 82, shot = 76, pass = 85, defense = 77, dribble = 81, stamina = 86, control = 84, physical = 74},

    -- PORTEROS (GK)
    {name = "Thibaut Courtois", role = "Portero", posTag = "GK", speed = 55, shot = 35, pass = 74, defense = 91, dribble = 50, stamina = 80, control = 78, physical = 86},
    {name = "Alisson Becker", role = "Portero", posTag = "GK", speed = 58, shot = 35, pass = 85, defense = 90, dribble = 55, stamina = 82, control = 82, physical = 85},
    {name = "Marc-André ter Stegen", role = "Portero", posTag = "GK", speed = 56, shot = 32, pass = 88, defense = 89, dribble = 54, stamina = 80, control = 83, physical = 80},
    {name = "Ederson Moraes", role = "Portero", posTag = "GK", speed = 64, shot = 40, pass = 93, defense = 88, dribble = 65, stamina = 82, control = 85, physical = 82},
    {name = "Jan Oblak", role = "Portero", posTag = "GK", speed = 54, shot = 30, pass = 72, defense = 90, dribble = 48, stamina = 80, control = 77, physical = 84},
    {name = "Mike Maignan", role = "Portero", posTag = "GK", speed = 58, shot = 33, pass = 84, defense = 88, dribble = 56, stamina = 82, control = 81, physical = 83},
    {name = "Gianluigi Donnarumma", role = "Portero", posTag = "GK", speed = 54, shot = 30, pass = 75, defense = 89, dribble = 50, stamina = 80, control = 78, physical = 86},
    {name = "Emiliano Martínez", role = "Portero", posTag = "GK", speed = 56, shot = 33, pass = 80, defense = 88, dribble = 52, stamina = 83, control = 80, physical = 85},
    {name = "Yassine Bounou", role = "Portero", posTag = "GK", speed = 55, shot = 30, pass = 77, defense = 86, dribble = 52, stamina = 80, control = 78, physical = 82},
    {name = "David Raya", role = "Portero", posTag = "GK", speed = 60, shot = 35, pass = 86, defense = 85, dribble = 58, stamina = 82, control = 82, physical = 78}
}

function TeamsData.CalculateRarity(p)
    local overall = math.floor((p.speed + p.shot + p.pass + p.defense + p.dribble + p.stamina + p.control + p.physical) / 8)
    p.overall = overall
    if overall >= 88 then
        p.rarity = "Diamante"
        p.rarityIcon = "◆"
        p.rarityColor = Color3.fromRGB(0, 200, 255)
    elseif overall >= 80 then
        p.rarity = "Oro"
        p.rarityIcon = "★"
        p.rarityColor = Color3.fromRGB(255, 215, 0)
    elseif overall >= 72 then
        p.rarity = "Plata"
        p.rarityIcon = "●"
        p.rarityColor = Color3.fromRGB(205, 205, 215)
    else
        p.rarity = "Bronce"
        p.rarityIcon = "●"
        p.rarityColor = Color3.fromRGB(195, 120, 60)
    end
    return p
end

for _, p in ipairs(TeamsData.PLAYERS) do
    TeamsData.CalculateRarity(p)
end

return TeamsData
