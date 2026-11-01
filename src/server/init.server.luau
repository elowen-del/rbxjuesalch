print("[Servidor] ¡Conexión con Rojo establecida con éxito para la Prueba 1!")

game.Players.PlayerAdded:Connect(function(player)
    print(string.format("[Servidor] ¡Bienvenido/a a la Prueba 1, %s!", player.Name))
end)

