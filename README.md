# Wolverine Balanced Durability Issue

This is repository for reproduction of [Wolverine](https://github.com/JasperFx/wolverine) issue: [Balanced durability mode doesn't work with RabbitMQ](https://github.com/JasperFx/wolverine/issues/788)

## Prerequisites

- Make >= 4.3
- Docker >= 25.0 with Compose >= 2.24

## Usage guide

Recommended way of exploring and experimenting with this repo is through usage of prepared `make` targets. \
Targets can be used by running `make {target-name}` in terminal eg. `make balanced-mode-step-1`

**Best approach would be to firstly go through "Explore" section then "Experiment"**

### Explore

Most important targets whose purpose is to clearly present the problem are:
- **balanced-mode-step-1**
  - cleans environment
  - builds images
  - spins up rabbit and postgres containers
  - waits for both rabbit and postgres to be fully available
  - spins up app container with `durability mode` set to `balanced`
  - prints logs from app especially showing thrown exceptions
  - **proves that there is reproducible error when `balanced` mode is used**
- **balanced-mode-step-2**
  - just restarts app container also with `durability mode` set to `balanced`
  - prints logs from app especially showing that there is no error and app runs properly
  - **proves that second run of app without any changes just works which can be helpful hint**
- **solo-mode-step-1**
  - does exactly the same steps as **balanced-mode-step-1** but with `durability mode` set to `solo`
  - **proves that with `solo` mode app works fine every time**

### Experiment

To experiment with the app like do some debugging or code changes go with below steps:
1. `make down`
2. `make clean`
3. `make up-wo-app` ("wo" means without)

After that you will be able to just run app directly without being containerized. \
This would give you the possibility to debug or change the code to address the issue.

**Note that issue is only noticeable on first app run so after each run you should repeat those three steps above**
