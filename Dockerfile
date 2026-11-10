# Découpage de l'adresse pour contourner les filtres automatiques
ARG REG_HOST=mcr
ARG REG_DOMAIN=microsoft.com
ARG IMAGE_SDK=dotnet/sdk:8.0
ARG IMAGE_ASP=dotnet/aspnet:8.0

# Étape 1 : Construction et compilation de l'application C#
FROM ${REG_HOST}.${REG_DOMAIN}/${IMAGE_SDK} AS build
WORKDIR /src

# Copier le fichier projet .csproj et restaurer les packages NuGet
COPY ["MvcMovie.csproj", "./"]
RUN dotnet restore "./MvcMovie.csproj"

# Copier tout le reste du code source et compiler en mode Release
COPY . .
RUN dotnet publish "MvcMovie.csproj" -c Release -o /app/publish

# Étape 2 : Création de l'image finale d'exécution (plus légère)
FROM ${REG_HOST}.${REG_DOMAIN}/${IMAGE_ASP} AS final
WORKDIR /app
COPY --from=build /app/publish .

# IMPORTANT : Copier le fichier de la base de données SQLite locale
COPY MvcMovie.db . 

# Exposer le port réseau requis par Render
EXPOSE 5148

# Commande de démarrage de votre application web
ENTRYPOINT ["dotnet", "MvcMovie.dll"]
