local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

print("==========================================================================")
print("[SERVIDOR] Futbol Total: Bloque Bajo, Ataque Dinámico, 90 Minutos y Porterías")
print("==========================================================================")

--------------------------------------------------------------------------------
-- 1. CONFIGURACIÓN DE COLISIONES
--------------------------------------------------------------------------------
pcall(function()
    PhysicsService:RegisterCollisionGroup("CharactersGroup")
    PhysicsService:RegisterCollisionGroup("SoccerBallGroup")
    PhysicsService:CollisionGroupSetCollidable("SoccerBallGroup", "CharactersGroup", false)
    PhysicsService:CollisionGroupSetCollidable("SoccerBallGroup", "Default", true)
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
-- 2. CONSTRUCCIÓN DEL GRAN ESTADIO REGLAMENTARIO
--------------------------------------------------------------------------------
local FIELD_SIZE = Vector2.new(380, 230)
local WALL_HEIGHT = 28
local WALL_THICKNESS = 3

-- PORTERÍAS MÁS AMPLIAS (Adaptadas al juego)
local GOAL_WIDTH = 42
local GOAL_HEIGHT = 15
local GOAL_DEPTH = 18

-- Dimensiones de áreas reglamentarias (en studs)
local PENALTY_AREA_DEPTH = 62
local PENALTY_AREA_WIDTH = 140
local GOAL_AREA_DEPTH = 24
local GOAL_AREA_WIDTH = 70
local PENALTY_SPOT_DIST = 40
local CENTER_CIRCLE_RADIUS = 34

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

-- Césped principal (Campo gigante)
createFieldPart("CespedePrincipal", Vector3.new(FIELD_SIZE.X, 1, FIELD_SIZE.Y), Vector3.new(0, 0, 0), Color3.fromRGB(38, 140, 52), Enum.Material.Grass)
createFieldPart("BandaExterior", Vector3.new(FIELD_SIZE.X + 34, 0.95, FIELD_SIZE.Y + 34), Vector3.new(0, -0.05, 0), Color3.fromRGB(32, 115, 42), Enum.Material.Grass)

-- Líneas perimetrales y central
local halfX = FIELD_SIZE.X / 2
local halfY = FIELD_SIZE.Y / 2
local lineThick = 1.2
local lineH = 0.02

createFieldLine("LineaBandaNorte", Vector3.new(FIELD_SIZE.X, lineH, lineThick), Vector3.new(0, FIELD_Y, -halfY))
createFieldLine("LineaBandaSur", Vector3.new(FIELD_SIZE.X, lineH, lineThick), Vector3.new(0, FIELD_Y, halfY))
createFieldLine("LineaFondoOeste", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(-halfX, FIELD_Y, 0))
createFieldLine("LineaFondoEste", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(halfX, FIELD_Y, 0))
createFieldLine("LineaCentro", Vector3.new(lineThick, lineH, FIELD_SIZE.Y), Vector3.new(0, FIELD_Y, 0))

-- Círculo central
local ringMeshPart = Instance.new("Part")
ringMeshPart.Name = "AroCentralHueco"
ringMeshPart.Size = Vector3.new(CENTER_CIRCLE_RADIUS * 2, lineH, CENTER_CIRCLE_RADIUS * 2)
ringMeshPart.Position = Vector3.new(0, FIELD_Y, 0)
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

-- Punto central
local centerDot = Instance.new("Part")
centerDot.Name = "PuntoCentralBalon"
centerDot.Shape = Enum.PartType.Cylinder
centerDot.Size = Vector3.new(lineH, 2.4, 2.4)
centerDot.CFrame = CFrame.new(0, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
centerDot.Color = Color3.fromRGB(245, 245, 245)
centerDot.Material = Enum.Material.SmoothPlastic
centerDot.Anchored = true
centerDot.CanCollide = false
centerDot.Parent = pitchFolder

-- Construcción de áreas y puntos de penalti
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
    penSpot.Size = Vector3.new(lineH, 2.0, 2.0)
    penSpot.CFrame = CFrame.new(penaltySpotX, FIELD_Y, 0) * CFrame.Angles(0, 0, math.rad(90))
    penSpot.Color = Color3.fromRGB(245, 245, 245)
    penSpot.Material = Enum.Material.SmoothPlastic
    penSpot.Anchored = true
    penSpot.CanCollide = false
    penSpot.Parent = pitchFolder
end

buildGoalAreas(-1, "Azul")
buildGoalAreas(1, "Rojo")

-- Spawns transparentes
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

-- Muros perimetrales
local wallY = WALL_HEIGHT / 2
createFieldPart("MuroNorte", Vector3.new(FIELD_SIZE.X + WALL_THICKNESS*2, WALL_HEIGHT, WALL_THICKNESS), Vector3.new(0, wallY, -halfY - (WALL_THICKNESS/2)), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroSur", Vector3.new(FIELD_SIZE.X + WALL_THICKNESS*2, WALL_HEIGHT, WALL_THICKNESS), Vector3.new(0, wallY, halfY + (WALL_THICKNESS/2)), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)

local sideWallLen = (FIELD_SIZE.Y - GOAL_WIDTH) / 2
local sideWallOffset = (GOAL_WIDTH + sideWallLen) / 2
createFieldPart("MuroOesteArriba", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(-halfX - (WALL_THICKNESS/2), wallY, -sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroOesteAbajo", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(-halfX - (WALL_THICKNESS/2), wallY, sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroEsteArriba", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(halfX + (WALL_THICKNESS/2), wallY, -sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)
createFieldPart("MuroEsteAbajo", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, sideWallLen), Vector3.new(halfX + (WALL_THICKNESS/2), wallY, sideWallOffset), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, 0.5)

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

--------------------------------------------------------------------------------
-- 4. STATS INTERNOS Y NOMBRES ESTILO ROBLOX (SIN MOSTRAR EN PANTALLA)
--------------------------------------------------------------------------------
type PlayerStats = {
    name: string,
    role: string, -- "Delantero", "Central", "Defensa"
    speed: number,
    shot: number,
    defense: number,
}

-- Nombres ficticios estilo Roblox inspirados en futbolistas reales
local ROBLOX_PLAYERS_DATA: {PlayerStats} = {
    -- Delanteros
    {name = "Bloxappé", role = "Delantero", speed = 98, shot = 91, defense = 40},
    {name = "Robland", role = "Delantero", speed = 90, shot = 96, defense = 45},
    {name = "Noobssi", role = "Delantero", speed = 83, shot = 97, defense = 42},
    {name = "CristiNoob", role = "Delantero", speed = 86, shot = 95, defense = 44},
    {name = "ViniBlox", role = "Delantero", speed = 97, shot = 86, defense = 38},
    {name = "LewanBlox", role = "Delantero", speed = 76, shot = 93, defense = 48},
    {name = "LamineBlox", role = "Delantero", speed = 91, shot = 85, defense = 40},
    {name = "Bloxinho", role = "Delantero", speed = 88, shot = 92, defense = 40},

    -- Centrales
    {name = "Modriq", role = "Central", speed = 75, shot = 84, defense = 78},
    {name = "BruyneBlox", role = "Central", speed = 78, shot = 90, defense = 72},
    {name = "ZidaneBlox", role = "Central", speed = 79, shot = 89, defense = 75},
    {name = "IniestaRob", role = "Central", speed = 80, shot = 83, defense = 74},
    {name = "XaviRob", role = "Central", speed = 77, shot = 81, defense = 76},
    {name = "BellingBlox", role = "Central", speed = 84, shot = 87, defense = 79},

    -- Defensas
    {name = "VanDijkRob", role = "Defensa", speed = 81, shot = 60, defense = 96},
    {name = "RamosBlox", role = "Defensa", speed = 78, shot = 72, defense = 94},
    {name = "PuyolNoob", role = "Defensa", speed = 77, shot = 55, defense = 97},
    {name = "MaldiniRob", role = "Defensa", speed = 83, shot = 58, defense = 98},
    {name = "NestaBlox", role = "Defensa", speed = 80, shot = 52, defense = 95},
}

local characterStats: { [Model]: PlayerStats } = {}

local function getWalkSpeedFromStat(speedStat: number): number
    return 14 + (speedStat / 100) * 10
end

local function getSprintSpeedFromStat(speedStat: number): number
    return 22 + (speedStat / 100) * 14
end

local function getStealRadiusFromStat(defenseStat: number): number
    return 4.2 + (defenseStat / 100) * 3.4
end

local function getStealCooldownFromStat(defenseStat: number): number
    return 3.5 - (defenseStat / 100) * 1.8
end

local function getShotPowerMultiplier(shotStat: number): number
    return 0.6 + (shotStat / 100) * 0.75
end

local function getShotRangeFromStat(shotStat: number): number
    return 42 + (shotStat / 100) * 58
end

--------------------------------------------------------------------------------
-- 5. VARIABLES DEL PARTIDO Y BALÓN
--------------------------------------------------------------------------------
local BALL_SIZE = Vector3.new(1.6, 1.6, 1.6)
local BALL_ATTACH_OFFSET = Vector3.new(0, -2.2, -1.9)
local RING_COLOR_BLUE = Color3.fromRGB(0, 195, 255)
local RING_COLOR_RED = Color3.fromRGB(255, 65, 65)

local MAX_CHARGE_DURATION = 1.6
local BASE_MIN_SPEED = 40
local BASE_MAX_SPEED = 240
local SHOT_COOLDOWN_TIME = 4.5
local lastPlayerShotTime: { [Player]: number } = {}

local currentBall: Part? = nil
local currentOwner: Model? = nil
local activeWeld: WeldConstraint? = nil
local serverChargeStartTime: number? = nil
local isKickOnCooldown = false
local isGoalCelebrating = false

local scoreBlue = 0
local scoreRed = 0

-- Coordenadas de porterías (por defecto Azul en Oeste, Rojo en Este)
local BLUE_GOAL_CENTER = Vector3.new(-halfX, 4, 0)
local RED_GOAL_CENTER = Vector3.new(halfX, 4, 0)

local goalkeeperBlue: Model? = nil
local goalkeeperRed: Model? = nil

--------------------------------------------------------------------------------
-- 6. SISTEMA DE TIEMPO DE PARTIDO: 90 MINUTOS FUTBOLÍSTICOS
--------------------------------------------------------------------------------
-- 90 minutos de partido = exactamente 300 segundos reales (5 minutos reales).
-- Velocidad del reloj: 1 segundo real = 0.30 minutos futbolísticos (18 segundos de partido).
local MATCH_STATE_FIRST_HALF = "1ST_HALF"
local MATCH_STATE_FIRST_EXTRA = "1ST_EXTRA"
local MATCH_STATE_HALFTIME = "HALFTIME"
local MATCH_STATE_SECOND_HALF = "2ND_HALF"
local MATCH_STATE_SECOND_EXTRA = "2ND_EXTRA"
local MATCH_STATE_FULLTIME = "FULLTIME"

local currentMatchState = MATCH_STATE_FIRST_HALF
local matchGameSeconds = 0 -- En segundos de partido futbolístico (0 a 90 * 60)
local firstHalfAddedMins = 0
local secondHalfAddedMins = 0
local halftimeRealSecondsLeft = 60
local fulltimeRealSecondsLeft = 60
local isMatchPaused = false
local currentPeriodSideSwapped = false -- true en la 2da parte al cambiar de portería

--------------------------------------------------------------------------------
-- 7. EFECTO DE FUEGO EN EL BALÓN
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

--------------------------------------------------------------------------------
-- 8. ARO NEÓN EN LOS PIES
--------------------------------------------------------------------------------
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
-- 9. POSESIÓN Y SOLDADURA DEL BALÓN
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
    createAuraRing(character, if isRed then RING_COLOR_RED else RING_COLOR_BLUE)

    local player = Players:GetPlayerFromCharacter(character)
    if player then
        ballPossessionEvent:FireClient(player, true)
    end
end

--------------------------------------------------------------------------------
-- 10. ESTRUCTURA Y COORDINADOR DE EQUIPOS (6v6 BOTS)
--------------------------------------------------------------------------------
type BotSlot = {
    model: Model,
    role: string,            -- "Delantero", "Central", "Defensa"
    roleId: string,          -- "ST", "CM1", "CM2", "DEF1", "DEF2", "DEF3"
    teamName: string,        -- "Azul" | "Rojo"
    basePosition: Vector3,
    stats: PlayerStats,
    lastPassTime: number,
    lastShotTime: number,
    lastStealTime: number,
}

local teamBlueBots: { [string]: BotSlot } = {}
local teamRedBots: { [string]: BotSlot } = {}

-- Posiciones base para lado normal (Azul en Oeste, Rojo en Este)
local FORMATION_BLUE: { [string]: { role: string, pos: Vector3 } } = {
    ["DEF1"] = { role = "Defensa", pos = Vector3.new(-130, 3, -50) },
    ["DEF2"] = { role = "Defensa", pos = Vector3.new(-140, 3, 0)   },
    ["DEF3"] = { role = "Defensa", pos = Vector3.new(-130, 3, 50)  },
    ["CM1"]  = { role = "Central", pos = Vector3.new(-75, 3, -32)  },
    ["CM2"]  = { role = "Central", pos = Vector3.new(-75, 3, 32)   },
    ["ST"]   = { role = "Delantero", pos = Vector3.new(-25, 3, 0)  },
}

local FORMATION_RED: { [string]: { role: string, pos: Vector3 } } = {
    ["DEF1"] = { role = "Defensa", pos = Vector3.new(130, 3, 50)   },
    ["DEF2"] = { role = "Defensa", pos = Vector3.new(140, 3, 0)    },
    ["DEF3"] = { role = "Defensa", pos = Vector3.new(130, 3, -50)  },
    ["CM1"]  = { role = "Central", pos = Vector3.new(75, 3, 32)   },
    ["CM2"]  = { role = "Central", pos = Vector3.new(75, 3, -32)  },
    ["ST"]   = { role = "Delantero", pos = Vector3.new(25, 3, 0)   },
}

-- Construir Bot con NOMBRE LIMPIO estilo Roblox (sin stats ni porcentajes visibles)
local function buildSoccerBot(teamName: string, roleId: string, role: string, basePos: Vector3, jerseyColor: Color3, usedNames: { [string]: boolean }): BotSlot
    local pool: {PlayerStats} = {}
    for _, item in ipairs(ROBLOX_PLAYERS_DATA) do
        if item.role == role and not usedNames[item.name] then
            table.insert(pool, item)
        end
    end
    if #pool == 0 then
        for _, item in ipairs(ROBLOX_PLAYERS_DATA) do
            if item.role == role then table.insert(pool, item) end
        end
    end
    if #pool == 0 then pool = ROBLOX_PLAYERS_DATA end

    local statsTemplate = pool[math.random(1, #pool)]
    usedNames[statsTemplate.name] = true
    local cleanName = statsTemplate.name

    local bot = Instance.new("Model")
    bot.Name = string.format("Bot_%s_%s_%s", teamName, roleId, cleanName)

    local function makePart(name: string, size: Vector3, color: Color3): Part
        local p = Instance.new("Part")
        p.Name = name
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

    local torso = makePart("Torso", Vector3.new(2, 2, 1), jerseyColor)
    local head = makePart("Head", Vector3.new(1.25, 1.25, 1.25), Color3.fromRGB(240, 200, 160))
    local headMesh = Instance.new("SpecialMesh")
    headMesh.MeshType = Enum.MeshType.Head
    headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
    headMesh.Parent = head

    local leftArm = makePart("Left Arm", Vector3.new(1, 2, 1), jerseyColor)
    local rightArm = makePart("Right Arm", Vector3.new(1, 2, 1), jerseyColor)
    local leftLeg = makePart("Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(25, 25, 25))
    local rightLeg = makePart("Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(25, 25, 25))

    local function makeMotor(name: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame)
        local m = Instance.new("Motor6D")
        m.Name = name
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

    -- VISUALIZACIÓN LIMPIA: ÚNICAMENTE EL NOMBRE
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 140, 0, 26)
    billboard.StudsOffset = Vector3.new(0, 2.7, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = cleanName
    nameLabel.TextColor3 = Color3.fromRGB(250, 250, 250)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    local textStroke = Instance.new("UIStroke")
    textStroke.Color = Color3.fromRGB(20, 20, 20)
    textStroke.Thickness = 1.5
    textStroke.Parent = nameLabel

    bot.PrimaryPart = hrp
    setupCharacterCollision(bot)

    characterStats[bot] = statsTemplate
    bot.Parent = workspace

    local slot: BotSlot = {
        model = bot,
        role = role,
        roleId = roleId,
        teamName = teamName,
        basePosition = basePos,
        stats = statsTemplate,
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
            slot.model:Destroy()
        end
        teamSlots[roleId] = nil
    end
end

local function spawnFull6v6Match()
    cleanTeam(teamBlueBots)
    cleanTeam(teamRedBots)

    local usedNames: { [string]: boolean } = {}

    local blueForm = if currentPeriodSideSwapped then FORMATION_RED else FORMATION_BLUE
    local redForm = if currentPeriodSideSwapped then FORMATION_BLUE else FORMATION_RED

    for roleId, data in pairs(blueForm) do
        local slot = buildSoccerBot("Azul", roleId, data.role, data.pos, Color3.fromRGB(35, 145, 245), usedNames)
        teamBlueBots[roleId] = slot
    end

    for roleId, data in pairs(redForm) do
        local slot = buildSoccerBot("Rojo", roleId, data.role, data.pos, Color3.fromRGB(235, 45, 45), usedNames)
        teamRedBots[roleId] = slot
    end

    print("[SERVIDOR] ¡12 Bots listos en el campo con roles, zonas y bloque táctico!")
end

--------------------------------------------------------------------------------
-- 11. SPAWN DEL BALÓN Y GESTIÓN DE GOLES
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

    local humanSpawnX = if currentPeriodSideSwapped then 60 else -60
    for _, p in ipairs(Players:GetPlayers()) do
        local pChar = p.Character
        local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart") :: BasePart?
        if pHrp then
            pHrp.CFrame = CFrame.new(humanSpawnX, 3, math.random(-10, 10))
            pHrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function onGoalScored(goalSide: string)
    if isGoalCelebrating or isMatchPaused then return end
    isGoalCelebrating = true

    -- Determinar a qué equipo le cuenta el gol según el lado que atacan
    local scoringTeam = ""
    if not currentPeriodSideSwapped then
        -- Normal: Azul defiende Oeste (sensorAzul), ataca sensorRojo
        if goalSide == "Azul" then
            scoreRed = scoreRed + 1
            scoringTeam = "Rojo"
        else
            scoreBlue = scoreBlue + 1
            scoringTeam = "Azul"
        end
    else
        -- 2da parte: Lados cambiados
        if goalSide == "Azul" then
            scoreBlue = scoreBlue + 1
            scoringTeam = "Azul"
        else
            scoreRed = scoreRed + 1
            scoringTeam = "Rojo"
        end
    end

    updateScoreEvent:FireAllClients(scoreBlue, scoreRed)
    goalScoredEvent:FireAllClients(scoringTeam)

    releaseBall()

    task.delay(1.5, function()
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
-- 12. EVENTOS DE DISPARO DEL JUGADOR HUMANO
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
    local powerRatio = math.clamp(elapsed / MAX_CHARGE_DURATION, 0.01, 1.0)

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
-- 13. PORTEROS INTELIGENTES: DISTRIBUCIÓN Y CONSTRUCCIÓN DE JUEGO
--------------------------------------------------------------------------------
local function createGoalkeeper(teamName: string, posX: number, primaryColor: Color3, nameLabel: string): Model
    local gk = Instance.new("Model")
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

    local torso = makePart("Torso", Vector3.new(2.4, 2, 1.2), primaryColor)
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

    -- Cartel limpio con nombre
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 140, 0, 26)
    billboard.StudsOffset = Vector3.new(0, 2.7, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = nameLabel
    label.TextColor3 = primaryColor
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard

    local textStroke = Instance.new("UIStroke")
    textStroke.Color = Color3.fromRGB(20, 20, 20)
    textStroke.Thickness = 1.5
    textStroke.Parent = label

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

    local isHandlingBall = false
    local function catchAndDistribute()
        if isMatchPaused or not currentBall or isKickOnCooldown or isGoalCelebrating or isHandlingBall then return end

        local ballSpeed = currentBall.AssemblyLinearVelocity.Magnitude
        if ballSpeed > 130 then
            local failChance = math.clamp((ballSpeed - 130) * 1.5, 5, 25)
            if math.random(1, 100) <= failChance then
                local deflectDir = Vector3.new(if posX < 0 then 1 else -1, 0.4, (math.random() - 0.5) * 1.5).Unit
                currentBall.AssemblyLinearVelocity = deflectDir * (ballSpeed * 0.65)
                return
            end
        end

        isHandlingBall = true
        releaseBall()
        isKickOnCooldown = true

        currentBall.AssemblyLinearVelocity = Vector3.zero
        currentBall.AssemblyAngularVelocity = Vector3.zero
        currentBall.CFrame = hrp.CFrame * CFrame.new(0, -1, -2.5)

        -- Participación en la construcción: Buscar compañero desmarcado
        task.delay(0.45, function()
            if not currentBall then
                isHandlingBall = false
                isKickOnCooldown = false
                return
            end

            local allySlots = if teamName == "Azul" then teamBlueBots else teamRedBots
            local enemySlots = if teamName == "Azul" then teamRedBots else teamBlueBots

            local bestTarget: BasePart? = nil
            local bestSafety = -999

            -- Priorizar pases seguros a Defensas o Centrales
            local options = { allySlots["DEF1"], allySlots["DEF3"], allySlots["CM1"], allySlots["CM2"], allySlots["DEF2"] }
            for _, cand in ipairs(options) do
                if cand and cand.model and cand.model.Parent then
                    local cHrp = cand.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if cHrp then
                        -- Medir distancia al rival más cercano para garantizar que esté libre
                        local minRivalDist = 999
                        for _, eSlot in pairs(enemySlots) do
                            if eSlot.model and eSlot.model.Parent then
                                local eHrp = eSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                                if eHrp then
                                    local dist = (eHrp.Position - cHrp.Position).Magnitude
                                    if dist < minRivalDist then minRivalDist = dist end
                                end
                            end
                        end

                        local safetyScore = minRivalDist
                        if safetyScore > bestSafety then
                            bestSafety = safetyScore
                            bestTarget = cHrp
                        end
                    end
                end
            end

            local outwardX = if posX < 0 then 1 else -1
            local targetPos = if bestTarget then bestTarget.Position + Vector3.new(outwardX * 8, 0, 0) else Vector3.new(0, 3, 0)
            local flatDir = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
            local dist = flatDir.Magnitude
            local unitDir = if dist > 0.1 then flatDir.Unit else Vector3.new(outwardX, 0, 0)

            local speed = math.clamp(dist * 1.7, 70, 135)
            local liftY = if dist > 50 then 22 else 6

            currentBall.CFrame = currentBall.CFrame + (unitDir * 2.5) + Vector3.new(0, 1.2, 0)
            currentBall.AssemblyLinearVelocity = (unitDir * speed) + Vector3.new(0, liftY, 0)
            currentBall.AssemblyAngularVelocity = Vector3.new(-unitDir.Z, 0, unitDir.X) * 35

            task.delay(0.5, function()
                isKickOnCooldown = false
                isHandlingBall = false
            end)
        end)
    end

    impossibleShield.Touched:Connect(function(hit)
        if hit == currentBall then
            catchAndDistribute()
        end
    end)

    gk.Parent = workspace
    return gk
end

goalkeeperBlue = createGoalkeeper("Azul", -halfX + 4, Color3.fromRGB(0, 160, 255), "Bloxkeeper Azul")
goalkeeperRed = createGoalkeeper("Rojo", halfX - 4, Color3.fromRGB(255, 60, 60), "Bloxkeeper Rojo")

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
            local targetZ = math.clamp(predictedZ + reactionJitter, -(GOAL_WIDTH / 2 - 1.5), (GOAL_WIDTH / 2 - 1.5))
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
            local advance = math.clamp(toBall.Magnitude * 0.08, 0, 10)
            local targetPos = goalCenter + (flatDir * advance)
            
            targetPos = Vector3.new(
                if isLeftGoal then math.clamp(targetPos.X, goalX, goalX + 11) else math.clamp(targetPos.X, goalX - 11, goalX),
                3,
                math.clamp(targetPos.Z, -(GOAL_WIDTH / 2 - 2), (GOAL_WIDTH / 2 - 2))
            )

            humanoid.WalkSpeed = 26
            humanoid:MoveTo(targetPos)
        end
    else
        humanoid.WalkSpeed = 20
        humanoid:MoveTo(goalCenter)
    end
end

--------------------------------------------------------------------------------
-- 14. SISTEMA TÁCTICO: BLOQUE BAJO DEFENSIVO Y ATAQUE DINÁMICO
--------------------------------------------------------------------------------
local function findBestPassTarget(passerSlot: BotSlot, allyTeam: { [string]: BotSlot }, enemyTeam: { [string]: BotSlot }): (BotSlot?, number)
    local passerHrp = passerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not passerHrp then return nil, 0 end

    local passerPos = passerHrp.Position
    local bestTarget: BotSlot? = nil
    local bestScore = -9999

    for roleId, candidate in pairs(allyTeam) do
        if candidate ~= passerSlot and candidate.model and candidate.model.Parent then
            local cHumanoid = candidate.model:FindFirstChildOfClass("Humanoid")
            local cHrp = candidate.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            if cHumanoid and cHumanoid.Health > 0 and cHrp then
                local toCandidate = cHrp.Position - passerPos
                local dist = toCandidate.Magnitude

                if dist > 15 and dist < 125 then
                    local passDir = Vector3.new(toCandidate.X, 0, toCandidate.Z).Unit
                    local isClear = true

                    for _, enemySlot in pairs(enemyTeam) do
                        if enemySlot.model and enemySlot.model.Parent then
                            local eHrp = enemySlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                            if eHrp then
                                local toEnemy = eHrp.Position - passerPos
                                local proj = toEnemy:Dot(passDir)
                                if proj > 0 and proj < dist then
                                    local perpDist = (toEnemy - (passDir * proj)).Magnitude
                                    if perpDist < 9 then
                                        isClear = false
                                        break
                                    end
                                end
                            end
                        end
                    end

                    if isClear then
                        local forwardBonus = if passerSlot.teamName == "Azul" then (cHrp.Position.X - passerPos.X) else (passerPos.X - cHrp.Position.X)
                        local roleBonus = 0
                        if candidate.role == "Delantero" then roleBonus = 40
                        elseif candidate.role == "Central" then roleBonus = 25
                        else roleBonus = 10 end

                        local totalScore = forwardBonus + roleBonus - (dist * 0.2)
                        if totalScore > bestScore then
                            bestScore = totalScore
                            bestTarget = candidate
                        end
                    end
                end
            end
        end
    end

    return bestTarget, bestScore
end

local function executePass(passerSlot: BotSlot, targetSlot: BotSlot)
    if not currentBall or isKickOnCooldown or currentOwner ~= passerSlot.model then return end
    local passerHrp = passerSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetHrp = targetSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not passerHrp or not targetHrp then return end

    releaseBall()
    isKickOnCooldown = true

    local targetVel = targetHrp.AssemblyLinearVelocity
    local leadTime = math.clamp((targetHrp.Position - passerHrp.Position).Magnitude / 65, 0.2, 0.6)
    local leadPos = targetHrp.Position + Vector3.new(targetVel.X, 0, targetVel.Z) * leadTime

    local passDir = (leadPos - passerHrp.Position)
    local dist = passDir.Magnitude
    local unitDir = if dist > 0.1 then passDir.Unit else passerHrp.CFrame.LookVector

    local passSpeed = math.clamp(dist * 1.8, 60, 125)
    local lift = if dist > 45 then 12 else 4

    currentBall.CFrame = currentBall.CFrame + (unitDir * 2.2) + Vector3.new(0, 0.5, 0)
    currentBall.AssemblyLinearVelocity = (unitDir * passSpeed) + Vector3.new(0, lift, 0)

    passerSlot.lastPassTime = os.clock()
    task.delay(0.4, function() isKickOnCooldown = false end)
end

local function executeClearance(botSlot: BotSlot, enemyGoalPos: Vector3)
    if not currentBall or isKickOnCooldown or currentOwner ~= botSlot.model then return end
    local hrp = botSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    releaseBall()
    isKickOnCooldown = true

    local clearDir = (enemyGoalPos - hrp.Position).Unit
    local liftY = math.random(32, 45)
    local speed = math.random(110, 150)

    currentBall.CFrame = currentBall.CFrame + (clearDir * 2.5) + Vector3.new(0, 1.2, 0)
    currentBall.AssemblyLinearVelocity = (clearDir * speed) + Vector3.new(0, liftY, 0)
    currentBall.AssemblyAngularVelocity = Vector3.new(-clearDir.Z, 0, clearDir.X) * 40

    task.delay(0.5, function() isKickOnCooldown = false end)
end

-- Posicionamiento Táctico: Transición fluida Bloque Bajo vs Ataque
local function getTacticalPosition(
    slot: BotSlot,
    hasTeamPossession: boolean,
    hasEnemyPossession: boolean,
    ballPos: Vector3,
    enemyGoalPos: Vector3
): Vector3

    local role = slot.role
    local base = slot.basePosition
    local attackDirX = if enemyGoalPos.X > 0 then 1 else -1

    if role == "Delantero" then
        if hasTeamPossession then
            -- ATAQUE: Desmarcarse cerca de la línea defensiva rival
            local attackX = (halfX - 45) * attackDirX
            local flankZ = math.clamp(ballPos.Z * 0.75, -50, 50)
            return Vector3.new(attackX, 3, flankZ)
        elseif hasEnemyPossession then
            -- BLOQUE BAJO: Retroceder a tres cuartos propios para preparar el contraataque
            return Vector3.new(25 * attackDirX, 3, math.clamp(ballPos.Z * 0.35, -35, 35))
        else
            return Vector3.new(45 * attackDirX, 3, 0)
        end

    elseif role == "Central" then
        if hasTeamPossession then
            -- ATAQUE: Uno avanza al borde del área rival y el otro mantiene equilibrio
            if slot.roleId == "CM1" then
                local advancedX = (ballPos.X * 0.55) + (35 * attackDirX)
                return Vector3.new(math.clamp(advancedX, -halfX + 70, halfX - 70), 3, base.Z + (ballPos.Z * 0.2))
            else
                local safeX = (ballPos.X * 0.4) - (15 * attackDirX)
                return Vector3.new(math.clamp(safeX, -halfX + 50, halfX - 50), 3, base.Z * 0.8)
            end
        elseif hasEnemyPossession then
            -- BLOQUE BAJO: Repliegue hacia la frontal del área propia
            local ownGoalX = -enemyGoalPos.X
            local shieldX = ownGoalX + (65 * attackDirX)
            return Vector3.new(shieldX, 3, base.Z * 0.75)
        else
            return base
        end

    elseif role == "Defensa" then
        if hasEnemyPossession then
            -- BLOQUE BAJO: Formación compacta delante del área pequeña y grande
            local ownGoalX = -enemyGoalPos.X
            local defLineX = ownGoalX + (44 * attackDirX)
            local shiftedZ = math.clamp(base.Z + (ballPos.Z * 0.35), -60, 60)
            return Vector3.new(defLineX, 3, shiftedZ)
        elseif hasTeamPossession then
            -- ATAQUE: Adelantar la línea defensiva hasta la mitad de cancha para compactar
            local ownGoalX = -enemyGoalPos.X
            local advancedLineX = ownGoalX + (85 * attackDirX)
            return Vector3.new(advancedLineX, 3, base.Z)
        else
            return base
        end
    end

    return base
end

local function updateBotSlotAI(
    slot: BotSlot,
    allyTeam: { [string]: BotSlot },
    enemyTeam: { [string]: BotSlot },
    designatedPresser: BotSlot?,
    enemyGoalPos: Vector3,
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
    local distToEnemyGoal = (enemyGoalPos - hrp.Position).Magnitude

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

    -- 1. POSESIÓN INDIVIDUAL
    if isOwner then
        local ownGoalX = -enemyGoalPos.X
        local distToOwnGoal = math.abs(hrp.Position.X - ownGoalX)
        if slot.role == "Defensa" and distToOwnGoal < 48 then
            executeClearance(slot, enemyGoalPos)
            return
        end

        local shotMultiplier = getShotPowerMultiplier(botStats.shot)
        local triggerRange = getShotRangeFromStat(botStats.shot)

        if distToEnemyGoal < triggerRange and (now - slot.lastShotTime >= SHOT_COOLDOWN_TIME) and not isKickOnCooldown then
            slot.lastShotTime = now
            releaseBall()
            isKickOnCooldown = true

            local goalPostTarget = enemyGoalPos
            if botStats.shot >= 85 then
                local sideOffset = if math.random() > 0.5 then (GOAL_WIDTH / 2 - 2) else -(GOAL_WIDTH / 2 - 2)
                goalPostTarget = enemyGoalPos + Vector3.new(0, math.random(2, 6), sideOffset)
            else
                local errorSpread = (100 - botStats.shot) * 0.12
                goalPostTarget = enemyGoalPos + Vector3.new(0, 0, (math.random() - 0.5) * errorSpread)
            end

            local shootDir = (goalPostTarget - hrp.Position).Unit
            local isAerial = (math.random(1, 100) <= 50)
            local liftY = if isAerial then math.random(22, 34) else math.random(8, 14)
            local speed = (115 * shotMultiplier)

            currentBall.CFrame = currentBall.CFrame + (shootDir * 2.2)
            currentBall.AssemblyLinearVelocity = (shootDir * speed) + Vector3.new(0, liftY, 0)
            if botStats.shot >= 88 then igniteBallInFlames(2.5) end

            task.delay(0.5, function() isKickOnCooldown = false end)
            return
        end

        local timeSincePass = now - slot.lastPassTime
        if timeSincePass > 1.8 and not isKickOnCooldown then
            local bestTarget, targetScore = findBestPassTarget(slot, allyTeam, enemyTeam)
            if bestTarget and (targetScore > 15 or distToEnemyGoal > 110) then
                executePass(slot, bestTarget)
                return
            end
        end

        local forwardDir = (Vector3.new(enemyGoalPos.X, 0, enemyGoalPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Unit
        local moveTarget = hrp.Position + (forwardDir * 25)

        for _, eSlot in pairs(enemyTeam) do
            if eSlot.model and eSlot.model.Parent then
                local eHrp = eSlot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
                if eHrp then
                    local toRival = eHrp.Position - hrp.Position
                    if toRival.Magnitude < 22 and forwardDir:Dot(toRival.Unit) > 0.3 then
                        local perpLeft = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
                        local perpRight = Vector3.new(forwardDir.Z, 0, -forwardDir.X)
                        local dodgeDir = if perpLeft:Dot(eHrp.AssemblyLinearVelocity) > 0 then perpRight else perpLeft
                        moveTarget = hrp.Position + ((forwardDir * 0.55 + dodgeDir * 0.45).Unit * 25)
                        break
                    end
                end
            end
        end

        humanoid:MoveTo(moveTarget)
        return
    end

    -- 2. BLOQUE DEFENSIVO O PRESIÓN
    if isEnemyOwner then
        local stealRadius = getStealRadiusFromStat(botStats.defense)
        local stealCooldown = getStealCooldownFromStat(botStats.defense)

        if designatedPresser == slot and currentOwner then
            local carrierHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
            if carrierHrp then
                humanoid:MoveTo(carrierHrp.Position)
                if (carrierHrp.Position - hrp.Position).Magnitude < stealRadius and (now - slot.lastStealTime >= stealCooldown) and not isKickOnCooldown then
                    slot.lastStealTime = now
                    attachBallToPlayer(bot)
                end
                return
            end
        else
            local tacticalPos = getTacticalPosition(slot, false, true, ballPos, enemyGoalPos)
            humanoid:MoveTo(tacticalPos)
            return
        end
    end

    -- 3. BALÓN SUELTO
    if currentOwner == nil and currentBall then
        local stealRadius = getStealRadiusFromStat(botStats.defense)
        if designatedPresser == slot then
            local bVel = currentBall.AssemblyLinearVelocity
            local interceptPos = if bVel.Magnitude > 15 then ballPos + Vector3.new(bVel.X, 0, bVel.Z) * 0.35 else ballPos
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

    -- 4. APOYO AL COMPAÑERO EN ATAQUE
    if isAllyOwner then
        local tacticalPos = getTacticalPosition(slot, true, false, ballPos, enemyGoalPos)
        humanoid:MoveTo(tacticalPos)
        return
    end
end

local function runTeamCoordinator(allyTeam: { [string]: BotSlot }, enemyTeam: { [string]: BotSlot }, enemyGoalPos: Vector3, now: number)
    local bestPresserSlot: BotSlot? = nil
    local minDistance = 9999

    local targetItemPos = if currentBall then currentBall.Position else Vector3.zero
    if currentOwner then
        local cHrp = currentOwner:FindFirstChild("HumanoidRootPart") :: BasePart?
        if cHrp then targetItemPos = cHrp.Position end
    end

    for roleId, slot in pairs(allyTeam) do
        if slot.model and slot.model.Parent then
            local hrp = slot.model:FindFirstChild("HumanoidRootPart") :: BasePart?
            local hum = slot.model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - targetItemPos).Magnitude
                local distWeight = dist
                if slot.role == "Defensa" and (math.abs(targetItemPos.X - slot.basePosition.X) > 65) then
                    distWeight = distWeight + 60
                end
                if distWeight < minDistance then
                    minDistance = distWeight
                    bestPresserSlot = slot
                end
            end
        end
    end

    for roleId, slot in pairs(allyTeam) do
        updateBotSlotAI(slot, allyTeam, enemyTeam, bestPresserSlot, enemyGoalPos, now)
    end
end

--------------------------------------------------------------------------------
-- 15. BUCLE DEL RELOJ DE PARTIDO Y FINALIZACIÓN
--------------------------------------------------------------------------------
local lastClockTick = os.clock()

local function updateMatchClock()
    local realDt = os.clock() - lastClockTick
    lastClockTick = os.clock()

    -- 300 segundos reales = 90 minutos de partido (1 segundo real = 18 segundos de juego)
    local gameDt = realDt * 18

    if currentMatchState == MATCH_STATE_FIRST_HALF then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)

        if curMinute >= 45 then
            currentMatchState = MATCH_STATE_FIRST_EXTRA
            firstHalfAddedMins = math.random(1, 10)
            print(string.format("[PARTIDO] Tiempo añadido 1ra parte: +%d minutos", firstHalfAddedMins))
        else
            local timeText = string.format("%02d:%02d", curMinute, curSec)
            matchTimeEvent:FireAllClients(timeText, "PRIMERA PARTE", false)
        end

    elseif currentMatchState == MATCH_STATE_FIRST_EXTRA then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)
        local timeText = string.format("45+%d' (%02d:%02d)", firstHalfAddedMins, curMinute, curSec)
        matchTimeEvent:FireAllClients(timeText, "TIEMPO AÑADIDO", true)

        if curMinute >= (45 + firstHalfAddedMins) then
            currentMatchState = MATCH_STATE_HALFTIME
            isMatchPaused = true
            halftimeRealSecondsLeft = 60
            releaseBall()
            print("[PARTIDO] ¡DESCANSO! Duración: 60 segundos reales.")
        end

    elseif currentMatchState == MATCH_STATE_HALFTIME then
        halftimeRealSecondsLeft = halftimeRealSecondsLeft - realDt
        local statusMsg = string.format("DESCANSO (%ds)", math.max(0, math.ceil(halftimeRealSecondsLeft)))
        matchTimeEvent:FireAllClients("45:00", statusMsg, true)

        if halftimeRealSecondsLeft <= 0 then
            -- Reanudación 2da parte: Cambio de lado
            currentPeriodSideSwapped = true
            currentMatchState = MATCH_STATE_SECOND_HALF
            matchGameSeconds = 45 * 60
            isMatchPaused = false

            -- Invertir orientaciones de portería
            resetPositionsToField()
            spawnBall(CFrame.new(0, 2.5, 0))
            print("[PARTIDO] ¡Comienza la Segunda Parte! Equipos cambian de lado.")
        end

    elseif currentMatchState == MATCH_STATE_SECOND_HALF then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)

        if curMinute >= 90 then
            currentMatchState = MATCH_STATE_SECOND_EXTRA
            secondHalfAddedMins = math.random(1, 10)
            print(string.format("[PARTIDO] Tiempo añadido 2da parte: +%d minutos", secondHalfAddedMins))
        else
            local timeText = string.format("%02d:%02d", curMinute, curSec)
            matchTimeEvent:FireAllClients(timeText, "SEGUNDA PARTE", false)
        end

    elseif currentMatchState == MATCH_STATE_SECOND_EXTRA then
        matchGameSeconds = matchGameSeconds + gameDt
        local curMinute = math.floor(matchGameSeconds / 60)
        local curSec = math.floor(matchGameSeconds % 60)
        local timeText = string.format("90+%d' (%02d:%02d)", secondHalfAddedMins, curMinute, curSec)
        matchTimeEvent:FireAllClients(timeText, "TIEMPO AÑADIDO", true)

        if curMinute >= (90 + secondHalfAddedMins) then
            currentMatchState = MATCH_STATE_FULLTIME
            isMatchPaused = true
            fulltimeRealSecondsLeft = 60
            releaseBall()
            print(string.format("[PARTIDO] ¡FINAL DEL PARTIDO! Resultado: Azul %d - %d Rojo", scoreBlue, scoreRed))
        end

    elseif currentMatchState == MATCH_STATE_FULLTIME then
        fulltimeRealSecondsLeft = fulltimeRealSecondsLeft - realDt
        local statusMsg = string.format("FINAL DEL PARTIDO (%ds)", math.max(0, math.ceil(fulltimeRealSecondsLeft)))
        matchTimeEvent:FireAllClients("90:00", statusMsg, true)

        if fulltimeRealSecondsLeft <= 0 then
            -- Reinicio de nuevo partido
            currentPeriodSideSwapped = false
            currentMatchState = MATCH_STATE_FIRST_HALF
            matchGameSeconds = 0
            firstHalfAddedMins = 0
            secondHalfAddedMins = 0
            scoreBlue = 0
            scoreRed = 0
            isMatchPaused = false

            updateScoreEvent:FireAllClients(0, 0)
            resetPositionsToField()
            spawnBall(CFrame.new(0, 2.5, 0))
            print("[PARTIDO] Nuevo encuentro iniciado automáticamente (00:00).")
        end
    end
end

--------------------------------------------------------------------------------
-- 16. BUCLE PRINCIPAL HEARTBEAT
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    updateMatchClock()

    updateGoalkeeperAI(goalkeeperBlue, -halfX + 4)
    updateGoalkeeperAI(goalkeeperRed, halfX - 4)

    local now = os.clock()

    if not isMatchPaused then
        local blueTargetGoal = if currentPeriodSideSwapped then BLUE_GOAL_CENTER else RED_GOAL_CENTER
        local redTargetGoal  = if currentPeriodSideSwapped then RED_GOAL_CENTER else BLUE_GOAL_CENTER

        runTeamCoordinator(teamBlueBots, teamRedBots, blueTargetGoal, now)
        runTeamCoordinator(teamRedBots, teamBlueBots, redTargetGoal, now)

        -- Robo del jugador humano si entra en el radio
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
-- 17. COMANDOS DE CHAT
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
        updateScoreEvent:FireAllClients(0, 0)
        spawnFull6v6Match()
        spawnBall(CFrame.new(0, 2.5, 0))
    elseif clean == "/limpiar" or clean == "/stop" or clean == "!stop" then
        cleanTeam(teamBlueBots)
        cleanTeam(teamRedBots)
        releaseBall()
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

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        handleChatMessage(player, msg)
    end)
    updateScoreEvent:FireClient(player, scoreBlue, scoreRed)
end)

Players.PlayerRemoving:Connect(function(player)
    if currentOwner and currentOwner.Name == player.Name then
        releaseBall()
    end
end)
