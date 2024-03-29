#!/usr/bin/env sh

set -e

if [ "$1" = "balanced-mode" ]
    then exec dotnet WolverineBalancedDurabilityIssue.dll RunFromContainer
elif [ "$1" = "solo-mode" ]
    then exec dotnet WolverineBalancedDurabilityIssue.dll RunFromContainer SoloMode
fi

exec $@
