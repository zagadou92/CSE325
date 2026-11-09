# Étape 1 : Construction et compilation de l'application C#
FROM ://microsoft.com AS build
WORKDIR /src

# Copier le fichier projet .csproj et restaurer les packages NuGet
COPY ["MvcMovie.csproj", "./"]
RUN dotnet restore "./MvcMovie.csproj"

# Copier tout le reste du code source et compiler en mode Release
COPY . .
RUN dotnet publish "MvcMovie.csproj" -c Release -o /app/publish

# Étape 2 : Création de l'image finale d'exécution (plus légère)
FROM ://microsoft.com AS final
WORKDIR /app
COPY --from=build /app/publish .

# IMPORTANT : Copier le fichier de la base de données SQLite locale
COPY MvcMovie.db . 

# Exposer le port réseau requis par Render
EXPOSE 5148

# Commande de démarrage de votre application web
ENTRYPOINT ["dotnet", "MvcMovie.dll"]
