# Sistema de Reservas de Estações de Trabalho em Haskell

![Haskell Logo](https://upload.wikimedia.org/wikipedia/commons/1/1c/Haskell-Logo.svg)

## Sumário
- [Visão Geral](#visão-geral)
- [Tipos e Estruturas](#tipos-e-estruturas)
- [Fluxo Principal](#fluxo-principal-main)
- [Menus](#menus)
- [Regras de Reserva](#regras-de-reserva)
- [Funções de Negócio](#funções-de-negócio)
  - [Reservas](#reservas)
    - [Núcleo de Negócio](#reservas---núcleo-de-negócio)
    - [Interface (UI)](#reservas---interface-ui)
  - [Usuários](#usuários)
    - [Núcleo de Negócio](#usuários---núcleo-de-negócio)
    - [Interface (UI)](#usuários---interface-ui)
  - [Espaços](#espaços)
    - [Núcleo de Negócio](#espaços---núcleo-de-negócio)
    - [Interface (UI)](#espaços---interface-ui)
- [Observações Técnicas](#observações-técnicas)

---

## Visão Geral

Sistema de reservas de estações de trabalho implementado em Haskell. Permite interação via terminal para:
- Cadastro e alteração de estações
- Registro e cancelamento de reservas
- Consulta de disponibilidade
- Gerenciamento de usuários

## Tipos e Estruturas

- **Espaco**: estação de trabalho (`Id`, andar, número, capacidade)
- **Usuario**: (`Id`, nome)
- **Reserva**: (`Id`, `Usuario`, `Espaco`, `DataHora`)
- **Banco**: estado do sistema — `([Espaco], [Usuario], [Reserva])`

## Fluxo Principal (`main`)

- Gera estações padrão (`gerarEstacoes`)
- Define lista inicial de usuários
- Chama `menuPrincipal` para iniciar interação

## Menus

- **Menu Principal**: escolha entre Administrador, Usuário ou Sair
- **Menu Administrador**: gestão de estações, usuários e reservas
- **Menu Usuário**: fazer/cancelar reservas, consultar estações, ver reservas próprias

## Regras de Reserva

- Um espaço só pode ser reservado se estiver disponível na data/hora
- Usuários não existentes são cadastrados automaticamente
- Cancelamento exige correspondência de ID e dono da reserva

## Funções de Negócio

### Reservas

#### Núcleo de Negócio

- `fazerReserva`: cria reserva se espaço estiver disponível
- `cancelarReserva`: remove reserva existente
- `espacosDisponiveis`: lista espaços livres em determinada data/hora
- `getReservaId`: obtém ID de reserva
- `novoId` (uso em reservas): gera próximo ID incremental
- `capacidade` (referência): retorna capacidade de um espaço (detalhe em Espaços)

#### Interface (UI)

- `fazerReservaUI`: coleta dados do usuário, mostra opções e invoca `fazerReserva`
- `cancelarReservaUI`: solicita ID e cancela reserva
- `verDisponiveisPorQtdUI`: filtra e exibe estações por capacidade
- `verMinhasReservasUI`: lista reservas do usuário

### Usuários

#### Núcleo de Negócio

- `buscarUsuarioPorNome`: pesquisa por nome, ignorando maiúsculas/minúsculas (usada em `entradaUsuario`)
- `alterarUsuario`: altera nome do usuário (usada em `menuAdministrador`)
- `getIdUsuario`: retorna ID do usuário
- `novoId` (uso em usuários): gera ID para novos usuários em `entradaUsuario`

#### Interface (UI)

- `entradaUsuario`: solicita nome, autentica ou cadastra usuário, encaminha para menuUsuario
- Menus do Usuário e Administrador chamam funções de núcleo conforme opção selecionada

### Espaços

#### Núcleo de Negócio

- `gerarEstacoes`: cria lista inicial de estações
- `cadastrarEstacao`: adiciona nova estação
- `alterarEstacao`: altera andar e número de estação existente
- `capacidade`: retorna capacidade de um espaço
- `getEspacoId`: retorna ID de uma estação

#### Interface (UI)

- Funções de UI de Espaços estão integradas aos menus, exibindo informações filtradas e recebendo entrada do usuário

## Observações Técnicas

- Funções de núcleo retornam dados puros ou `Either String Banco` em caso de erro
- Funções de UI lidam apenas com I/O, chamando funções de núcleo quando necessário
- `DataHora` é tratada como string no formato "DD-MM-AAAA HH:MM"