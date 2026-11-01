--!strict
-- Script del Servidor: Cubo de daño con cooldown

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- 1. Crear el cubo rojo en el Workspace
local damagePart = Instance.new("Part")
damagePart.Name = "DamageCube"
damagePart.Size = Vector3.new(4, 4, 4)
damagePart.Position = Vector3.new(0, 5, 0)
damagePart.Anchored = true
damagePart.Material = Enum.Material.Neon
damagePart.Color = Color3.fromRGB(255, 30, 30)
damagePart.Parent = Workspace

print("[DamageCube] Cubo rojo instanciado en el Workspace.")

-- Tabla para gestionar el cooldown por jugador
-- [UserId] = tick del próximo toque permitido
local cooldowns: { [number]: number } = {}
local COOLDOWN_TIME = 3

-- 2. Detectar el toque
damagePart.Touched:Connect(function(hitPart)
    local character = hitPart.Parent
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    local currentTime = os.clock()
    local nextAllowedTime = cooldowns[player.UserId] or 0

    if currentTime >= nextAllowedTime then
        -- Aplicar cooldown
        cooldowns[player.UserId] = currentTime + COOLDOWN_TIME

        -- Quitar la mitad de la vida máxima actual
        local damage = humanoid.MaxHealth / 2
        humanoid:TakeDamage(damage)

        print(string.format("[DamageCube] %s tocó el cubo. Se le restaron %.1f puntos de vida. Vida restante: %.1f", 
            player.Name, damage, humanoid.Health))

        -- Pequeño efecto visual de parpadeo para indicar el impacto
        task.spawn(function()
            local originalColor = damagePart.Color
            damagePart.Color = Color3.fromRGB(255, 255, 255)
            task.wait(0.15)
            damagePart.Color = originalColor
        end)
    end
end)

-- Limpiar la tabla de cooldowns cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
    cooldowns[player.UserId] = nil
end)
