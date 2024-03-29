ARG REV

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine3.19 as build

WORKDIR /src

COPY WolverineBalancedDurabilityIssue/*.csproj ./
RUN dotnet restore

COPY WolverineBalancedDurabilityIssue/ ./
RUN dotnet publish -c Release -o /publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine3.19

WORKDIR /publish

COPY docker/entrypoint.sh /
COPY --from=build /publish ./

ENTRYPOINT ["/entrypoint.sh"]
CMD ["balanced-mode"]
