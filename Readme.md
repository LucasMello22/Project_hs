# Sistema de Reservas de Estações de Trabalho em Haskell

<p align="center">
  <img src="https://portais.univasf.edu.br/ppgadt/pesquisadores/matriculados/arquivos/turma-2024-arquivos/ufrpe-logo.png" alt="Logo da UFRPE" width="130" height="130" style="margin-right: 20px;">
  <img src="https://yt3.googleusercontent.com/ytc/AIdro_laNsLYNFcXxU6RowxEG9ooxCiO6dJqFqS9yY_C1vnyTUY=s900-c-k-c0x00ffffff-no-rj" alt="Logo do Departamento de Computação da UFRPE" width="130" height="130">
</p>

## Sumário
- [Visão Geral](#visão-geral)
- [Arquitetura e Estrutura de Dados](#arquitetura-e-estrutura-de-dados)
- [Fluxo Principal (Main)](#fluxo-principal-main)
- [Menus e Navegação](#menus-e-navegação)
- [Regras de Reserva](#regras-de-reserva)
- [Módulos e Funções de Negócio](#módulos-e-funções-de-negócio)
  - [Reservas](#reservas)
    - [Núcleo de Negócio](#reservas---núcleo-de-negócio)
    - [Interface (UI)](#reservas---interface-ui)
  - [Usuários](#usuários)
    - [Núcleo de Negócio](#usuários---núcleo-de-negócio)
    - [Interface (UI)](#usuários---interface-ui)
  - [Espaços](#espaços)
    - [Núcleo de Negócio](#espaços---núcleo-de-negócio)
    - [Interface (UI)](#espaços---interface-ui)
- [Boas Práticas e Modularização](#boas-práticas-e-modularização)
- [Observações Técnicas](#observações-técnicas)

---

## Visão Geral

O **Sistema de Reservas de Estações de Trabalho** é um projeto desenvolvido em **Haskell**, com interação via **terminal**, permitindo:
- Cadastro e alteração de estações de trabalho;
- Registro e cancelamento de reservas;
- Consulta de disponibilidade por data e capacidade;
- Gerenciamento de usuários.

O sistema foi construído com foco em modularização, separando claramente as **funções puras** (núcleo de negócio) das **operações de I/O** (interface com o usuário).

---

## Arquitetura e Estrutura de Dados

### Tipos Principais
- **Espaco**: representa uma estação de trabalho (`Id`, andar, número, capacidade);
- **Usuario**: representa o usuário do sistema (`Id`, nome);
- **Reserva**: representa uma reserva de estação (`Id`, `Usuario`, `Espaco`, `DataHora`);
- **Banco**: representa o estado global do sistema — `([Espaco], [Usuario], [Reserva])`.

### Estrutura Modular
- `Main.hs`: controla o fluxo inicial e os menus principais.
- `Espacos.hs`, `Usuarios.hs`, `Reservas.hs`: contêm as funções de negócio e de interface de cada domínio.
- `Persistencia.hs`: responsável por salvar e carregar dados em arquivos de texto.
- `Utils.hs`: funções auxiliares para formatação, validação e geração de IDs.

---

## Fluxo Principal (Main)

1. **Inicialização**
   - Cria estações padrão via `gerarEstacoes`.
   - Define lista inicial de usuários.
   - Carrega reservas armazenadas, se existirem.

2. **Execução**
   - Exibe `menuPrincipal` para o usuário escolher o tipo de acesso.
   - Redireciona para o menu correspondente (Administrador ou Usuário).

3. **Encerramento**
   - Salva o estado atualizado no arquivo de persistência antes de encerrar.

---

## Menus e Navegação

### Menu Principal
- Acesso como **Administrador**, **Usuário** ou **Encerrar**.

### Menu do Administrador
- Cadastrar, alterar e listar estações;
- Cadastrar ou alterar usuários;
- Gerenciar reservas.

### Menu do Usuário
- Fazer e cancelar reservas;
- Consultar estações disponíveis;
- Ver reservas pessoais.

---

## Regras de Reserva

- Um **espaço** só pode ser reservado se estiver **livre** na data/hora informada;
- O **usuário** é cadastrado automaticamente se não existir;
- **Cancelamentos** exigem a correspondência entre o ID da reserva e o usuário responsável;
- A **capacidade** pode ser usada como filtro para busca de estações.

---

## Módulos e Funções de Negócio

### Reservas

#### Núcleo de Negócio
- `fazerReserva`: cria uma reserva se o espaço estiver disponível.
- `cancelarReserva`: remove uma reserva existente.
- `espacosDisponiveis`: retorna todos os espaços livres em uma data/hora.
- `getReservaId`: obtém o ID de uma reserva.
- `novoId`: gera o próximo ID incremental para novas reservas.

#### Interface (UI)
- `fazerReservaUI`: coleta dados do usuário e chama `fazerReserva`.
- `cancelarReservaUI`: solicita ID da reserva e executa o cancelamento.
- `verDisponiveisPorQtdUI`: exibe espaços filtrados por capacidade.
- `verMinhasReservasUI`: mostra as reservas do usuário logado.

---

### Usuários

#### Núcleo de Negócio
- `buscarUsuarioPorNome`: busca usuário ignorando maiúsculas/minúsculas.
- `alterarUsuario`: atualiza dados de um usuário existente.
- `getIdUsuario`: retorna o identificador de um usuário.
- `novoId`: gera IDs para novos usuários.

#### Interface (UI)
- `entradaUsuario`: autentica ou cadastra novo usuário e redireciona ao menu.
- Menus chamam funções de negócio conforme a escolha do usuário.

---

### Espaços

#### Núcleo de Negócio
- `gerarEstacoes`: gera lista inicial de estações.
- `cadastrarEstacao`: adiciona uma nova estação.
- `alterarEstacao`: atualiza número ou andar de uma estação.
- `capacidade`: retorna capacidade de um espaço.
- `getEspacoId`: obtém o ID de uma estação.

#### Interface (UI)
- As funções de UI de espaços são integradas aos menus administrativos, permitindo cadastro, alteração e visualização.

---

## Boas Práticas e Modularização

- Uso de **funções de alta ordem** (`map`, `filter`) e **lambda expressions**;
- Emprego de **compreensão de listas** para manipulação de coleções;
- Estruturação em múltiplos módulos para maior legibilidade e manutenção.

---

## Observações Técnicas

- `DataHora` é tratada como `String` no formato `"DD-MM-AAAA HH:MM"`;
- IDs são gerados de forma incremental;
- O sistema é totalmente funcional sem dependências externas;
- Ideal para execução em ambientes de terminal com GHCi.

---

### Desenvolvido por:
**Rayane Alves**  
**Beatriz**
Estudantes de Ciência da Computação — UFRPE  
2025.2
