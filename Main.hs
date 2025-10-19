module Main where

import Data.Char (toLower)
import Data.List
import System.IO

type Id = Int
type DataHora = String

data Espaco = EstacaoTrabalho Id Int Int Int deriving (Eq)
data Usuario = Usuario Id String deriving (Eq, Show)
data Reserva = Reserva Id Usuario Espaco DataHora deriving (Eq)

instance Show Espaco where
  show (EstacaoTrabalho _ andar num capacidade) = 
    "E." ++ show andar ++ "." ++ show num ++ " (" ++ show capacidade ++ " pessoa" ++ plural capacidade ++ ")"
    where plural 1 = ""; plural _ = "s"

instance Show Reserva where
  show (Reserva i (Usuario _ nome) espaco dh) =
    "Reserva #" ++ show i ++ " - " ++ nome ++ " - " ++ show espaco ++ " - " ++ dh

type Banco = ([Espaco], [Usuario], [Reserva])

novoId :: [Id] -> Id
novoId [] = 1
novoId xs = maximum xs + 1

getEspacoId :: Espaco -> Id
getEspacoId (EstacaoTrabalho i _ _ _) = i

getReservaId :: Reserva -> Id
getReservaId (Reserva i _ _ _) = i

getIdUsuario :: Usuario -> Id
getIdUsuario (Usuario i _) = i

capacidade :: Espaco -> Int
capacidade (EstacaoTrabalho _ _ _ c) = c

gerarEstacoes :: [Espaco]
gerarEstacoes = [EstacaoTrabalho ((a - 1) * 10 + e) a e cap | a <- [1,2], (e, cap) <- zip [1..10] (cycle [1,2,5])]

espacosDisponiveis :: DataHora -> Banco -> [Espaco]
espacosDisponiveis dh (espacos, _, reservas) =
  filter (\e -> notElem e [esp | Reserva _ _ esp d <- reservas, d == dh]) espacos

fazerReserva :: Id -> Id -> DataHora -> Banco -> Either String Banco
fazerReserva idU idEsp dh banco@(espacos, usuarios, reservas) =
  case (find (\u -> getIdUsuario u == idU) usuarios, find (\e -> getEspacoId e == idEsp) espacos) of
    (Just user, Just espaco) ->
      if espaco `elem` espacosDisponiveis dh banco
        then Right (espacos, usuarios, Reserva (novoId (map getReservaId reservas)) user espaco dh : reservas)
        else Left "Espaço já está reservado neste horário."
    _ -> Left "Usuário ou espaço não encontrado."

cancelarReserva :: Id -> Banco -> Banco
cancelarReserva idR (espacos, usuarios, reservas) =
  (espacos, usuarios, filter (\(Reserva i _ _ _) -> i /= idR) reservas)

cadastrarEstacao :: Int -> Int -> Int -> Banco -> Banco
cadastrarEstacao andar num cap (espacos, usuarios, reservas) =
  let novoIdEsp = novoId (map getEspacoId espacos)
      novaEstacao = EstacaoTrabalho novoIdEsp andar num cap
  in (novaEstacao:espacos, usuarios, reservas)

alterarEstacao :: Id -> Int -> Int -> Banco -> Either String Banco
alterarEstacao idE novoAndar novoNum (espacos, usuarios, reservas) =
  if any (\e -> getEspacoId e == idE) espacos
    then
      let espacosAtualizados = map update espacos
          update e@(EstacaoTrabalho i _ _ c) = if i==idE then EstacaoTrabalho i novoAndar novoNum c else e
      in Right (espacosAtualizados, usuarios, reservas)
    else Left "Estação não encontrada."

alterarUsuario :: Id -> String -> Banco -> Either String Banco
alterarUsuario idU novoNome (espacos, usuarios, reservas) =
  if any (\(Usuario i _) -> i == idU) usuarios
    then
      let usuariosAtualizados = map update usuarios
          update u@(Usuario i _) = if i==idU then Usuario i novoNome else u
      in Right (espacos, usuariosAtualizados, reservas)
    else Left "Usuário não encontrado."

buscarUsuarioPorNome :: String -> [Usuario] -> Maybe Usuario
buscarUsuarioPorNome nome usuarios = find (\(Usuario _ n) -> map toLower n == map toLower nome) usuarios

main :: IO ()
main = do
  let estacoes = gerarEstacoes
  let usuarios = [Usuario 1 "Alice", Usuario 2 "Bob", Usuario 3 "Carol"]
  menuPrincipal (estacoes, usuarios, [])

menuPrincipal :: Banco -> IO ()
menuPrincipal banco = do
  putStrLn "\n--- Bem-vindo ao Sistema de Reservas ---"
  putStrLn "1) Administrador"
  putStrLn "2) Usuário"
  putStrLn "3) Sair"
  putStr "Escolha: "
  hFlush stdout
  op <- getLine
  case op of
    "1" -> autenticarAdm banco
    "2" -> entradaUsuario banco
    "3" -> putStrLn "Encerrando..."
    _   -> putStrLn "Opção inválida." >> menuPrincipal banco

autenticarAdm :: Banco -> IO ()
autenticarAdm banco = do
  putStr "Digite a senha do administrador: "
  hFlush stdout
  senha <- getLine
  if senha == "1234"
    then menuAdministrador banco
    else putStrLn "Senha incorreta." >> menuPrincipal banco

entradaUsuario :: Banco -> IO ()
entradaUsuario banco@(espacos, usuarios, reservas) = do
  putStr "Digite seu nome: "
  hFlush stdout
  nomeUsuario <- getLine
  case buscarUsuarioPorNome nomeUsuario usuarios of
    Just (Usuario idU nomeCadastrado) -> do
      putStrLn $ "Olá, " ++ nomeCadastrado ++ "!"
      menuUsuario banco idU
    Nothing -> do
      let novoIdU = novoId (map getIdUsuario usuarios)
          novoUsuario = Usuario novoIdU nomeUsuario
          novoBanco = (espacos, usuarios++[novoUsuario], reservas)
      putStrLn "Usuários cadastrados atualmente:"
      mapM_ (\(Usuario i n) -> putStrLn (show i ++ " - " ++ n)) (usuarios++[novoUsuario])
      putStrLn $ "Seja bem vindo, " ++ nomeUsuario ++ "!"
      menuUsuario novoBanco novoIdU

menuAdministrador :: Banco -> IO ()
menuAdministrador banco@(espacos, usuarios, reservas) = do
  putStrLn "\n--- Menu do Administrador ---"
  putStrLn "1) Ver todas as estações"
  putStrLn "2) Ver estações por quantidade de pessoas"
  putStrLn "3) Ver estações disponíveis por data/hora"
  putStrLn "4) Cadastrar nova estação"
  putStrLn "5) Alterar estação"
  putStrLn "6) Ver usuários cadastrados"
  putStrLn "7) Alterar usuário"
  putStrLn "8) Ver todas as reservas"
  putStrLn "9) Voltar"
  putStr "Escolha: "
  hFlush stdout
  op <- getLine
  case op of
    "1" -> mapM_ (putStrLn . showEsp) espacos >> menuAdministrador banco
    "2" -> do
      putStr "Quantidade de pessoas (1,2 ou 3-5, 0 para todas): "
      q <- readLn
      let disp = if q==0 then espacos else filter (\e -> capacidade e == q || (q>=3 && q<=5 && capacidade e>=3 && capacidade e<=5)) espacos
      mapM_ (putStrLn . showEsp) disp
      menuAdministrador banco
    "3" -> do
      putStr "Data/hora (DD-MM-AAAA HH:MM): "
      dh <- getLine
      let disp = espacosDisponiveis dh banco
      mapM_ (putStrLn . showEsp) disp
      menuAdministrador banco
    "4" -> do
      putStr "Andar da nova estação: "; andar <- readLn
      putStr "Número da nova estação: "; num <- readLn
      putStr "Capacidade (1,2 ou 3-5): "; cap <- readLn
      let novoBanco = cadastrarEstacao andar num cap banco
      putStrLn "Nova estação cadastrada."
      menuAdministrador novoBanco
    "5" -> do
      putStr "ID da estação a alterar: "; idE <- readLn
      putStr "Novo andar: "; novoAndar <- readLn
      putStr "Novo número: "; novoNum <- readLn
      case alterarEstacao idE novoAndar novoNum banco of
        Right b -> putStrLn "Alteração feita." >> menuAdministrador b
        Left err -> putStrLn err >> menuAdministrador banco
    "6" -> mapM_ (\(Usuario i n) -> putStrLn (show i ++ " - " ++ n)) usuarios >> menuAdministrador banco
    "7" -> do
      putStr "ID do usuário: "; idU <- readLn
      putStr "Novo nome: "; novoNome <- getLine
      case alterarUsuario idU novoNome banco of
        Right b -> putStrLn "Alteração feita." >> menuAdministrador b
        Left err -> putStrLn err >> menuAdministrador banco
    "8" -> mapM_ print reservas >> menuAdministrador banco
    "9" -> menuPrincipal banco
    _   -> putStrLn "Opção inválida." >> menuAdministrador banco

menuUsuario :: Banco -> Id -> IO ()
menuUsuario banco idU = do
  putStrLn "\n--- Menu do Usuário ---"
  putStrLn "1) Fazer reserva"
  putStrLn "2) Cancelar reserva"
  putStrLn "3) Ver estações por quantidade de pessoas"
  putStrLn "4) Ver minhas reservas"
  putStrLn "5) Voltar"
  putStr "Escolha: "
  hFlush stdout
  op <- getLine
  case op of
    "1" -> fazerReservaUI banco idU
    "2" -> cancelarReservaUI banco idU
    "3" -> verDisponiveisPorQtdUI banco idU
    "4" -> verMinhasReservasUI banco idU
    "5" -> menuPrincipal banco
    _   -> putStrLn "Opção inválida." >> menuUsuario banco idU

fazerReservaUI :: Banco -> Id -> IO ()
fazerReservaUI banco idU = do
  putStr "Quantidade de pessoas (1,2 ou 3-5): "
  qnt <- readLn
  putStr "Data/hora da reserva (DD-MM-AAAA HH:MM): "
  dh <- getLine
  let estDisp = filter (\e -> capacidade e == qnt || (qnt>=3 && qnt<=5 && capacidade e>=3 && capacidade e<=5))
                       (espacosDisponiveis dh banco)
  if null estDisp
    then putStrLn "Nenhuma estação disponível para essa quantidade e horário." >> menuUsuario banco idU
    else do
      putStrLn "\nEstações disponíveis:"
      mapM_ (putStrLn . showEsp) estDisp
      putStr "Escolha o ID da estação: "
      idE <- readLn
      case fazerReserva idU idE dh banco of
        Right b -> putStrLn "Reserva realizada!" >> menuUsuario b idU
        Left err -> putStrLn err >> menuUsuario banco idU

cancelarReservaUI :: Banco -> Id -> IO ()
cancelarReservaUI banco@(_, _, reservas) idU = do
  putStr "ID da reserva: "
  idR <- readLn
  let existe = find (\(Reserva i (Usuario uid _) _ _) -> i==idR && uid==idU) reservas
  case existe of
    Just _ -> let novoBanco = cancelarReserva idR banco in putStrLn "Reserva cancelada." >> menuUsuario novoBanco idU
    Nothing -> putStrLn "Reserva não encontrada." >> menuUsuario banco idU

verDisponiveisPorQtdUI :: Banco -> Id -> IO ()
verDisponiveisPorQtdUI banco idU = do
  putStr "Quantidade de pessoas (1,2 ou 3-5, 0 para todas): "
  q <- readLn
  let estDisp = if q==0 then fst3 banco else filter (\e -> capacidade e == q || (q>=3 && q<=5 && capacidade e>=3 && capacidade e<=5)) (fst3 banco)
  mapM_ (putStrLn . showEsp) estDisp
  menuUsuario banco idU

verMinhasReservasUI :: Banco -> Id -> IO ()
verMinhasReservasUI banco@(_, _, reservas) idU = do
  let minhas = filter (\(Reserva _ (Usuario uid _) _ _) -> uid==idU) reservas
  if null minhas then putStrLn "Nenhuma reserva." else mapM_ print minhas
  menuUsuario banco idU

showEsp :: Espaco -> String
showEsp e = show (getEspacoId e) ++ " - " ++ show e

fst3 :: (a,b,c) -> a
fst3 (x,_,_) = x
