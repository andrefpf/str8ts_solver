-- STR8TS SOLVER
-- Alunos: André Filipe da Silva Fernandes
--         Hans Buss Heideman

-- Funções úteis para trabalhar com listas 

-- Pula índices indesejados de acordo com o número de passos.
steps :: Int -> [t] -> [t]
steps _ [] = []
steps step (a:b) = a : (steps step (drop (step-1) b))
    
-- Retorna um trecho da lista entre os índices passados pulando o número
-- de passos. É pra ser parecido como o slice de python.
slice :: Int -> Int -> Int -> [t] -> [t]
slice _ _ _ [] = []
slice _ _ 0 _  = []
slice start end step list = steps step (drop start (take end list))

-- Informa se o elemento passado está ou não na lista
inList :: (Eq t) => t -> [t] -> Bool
inList _ [] = False
inList x (a:b) | (x == a) = True
               | otherwise = inList x b

-- Informa se na lista tem algum valor repetido
repeated :: (Eq t) => [t] -> Bool
repeated [] = False
repeated (a:b) | inList a b = True
               | otherwise = repeated b

-- Retorna a lista que foi passada substituindo o valor no índice indicado
replace :: Int -> t -> [t] -> [t]
replace _ _ [] = [] 
replace i v (a:b) | (i == 0) = (v : b)
                  | otherwise = a : replace (i - 1) v b 


-- Funções úteis para tratar listas como matrizes

-- Retorna a linha da lista especificada pelo índice 
get_row :: Int -> [t] -> [t]
get_row i list = slice (i*size) (i*size + size) 1 list

-- Retorna a coluna da lista especificada pelo indice
get_col :: Int -> [t] -> [t]
get_col i list = slice i (size*size) size list


-- Funções úteis para o resolvedor

-- É uma casa branca? 
is_white :: Int -> Bool
is_white x = (x >= 0) 

-- É uma casa preta?
is_black :: Int -> Bool
is_black x = (x < 0)

-- O espaço está vazio? 
is_blank :: Int -> Bool
is_blank x = (x == 0)

-- Tem um número no espaço indicado?
is_number :: Int -> Bool
is_number x = (0 < (abs x)) && ((abs x) < 10)

-- Dada uma linha ou coluna extrai os trechos que 
-- contêm células brancas consecutivas
extract_straights :: [Int] -> [[Int]]
extract_straights [] = []
extract_straights list = (
    [takeWhile is_white (dropWhile is_black list)] ++
    extract_straights (dropWhile is_white (dropWhile is_black list ))
    )

-- Dada uma sequência verifica se ela forma uma 
-- sequência de números consecutivos sem espaços
valid_straight :: [Int] -> Bool
valid_straight [] = True
valid_straight list | inList 0 list = True
                    | length list - 1 /= (maximum list) - (minimum list) = False
                    | repeated list = False
                    | otherwise = True 

-- Verifica se a célula indicada quebra alguma das regras do jogo
valid_coord :: Int -> [Int] -> Bool
valid_coord i list | repeated (map abs (filter is_number 
                                 (get_row (div i size) list))) = False
                                    
                   | repeated (map abs (filter is_number 
                                 (get_col (mod i size) list))) = False       
                                 
                   | not (all valid_straight (extract_straights 
                                 (get_row (div i size) list)))  = False
                                 
                   | not (all valid_straight (extract_straights 
                                 (get_col (mod i size) list)))  = False
                                 
                   | otherwise = True

-- Testa todos os valores possíveis para uma célula e 
-- retorna as opções onde nenhuma regra é quebrada 
bruteforce_cell :: Int -> Int -> [Int] -> [[Int]]
bruteforce_cell i v list | (v <= 0) = []
                           | (v >  9)  = []
                           | not (is_blank (list !! i)) = [list]
                           
                           | not (valid_coord i (replace i v list)) 
                                               = bruteforce_cell i (v+1) list
                                               
                           | otherwise = [(replace i v list)] 
                                            ++ bruteforce_cell i (v+1) list

-- Testa todas as combinações possíveis para cada célula do 
-- tabuleiro e retorna as soluções possíveis
backtrack_str8ts :: Int -> [Int] -> [[Int]]
backtrack_str8ts i list | (i < 0) = []
                        | (i >= (length list)) = [list]
                        | otherwise = concat (map (backtrack_str8ts (i+1)) (bruteforce_cell i 1 list))
        

-- Forma mais conveniente de chamar a função 
-- backtrack_str8ts pela primeira vez
solve_str8ts :: [Int] -> [[Int]]
solve_str8ts b = backtrack_str8ts 0 b


-- Funções para printar 

-- Retorna uma string que representa o valor da célula
show_cell :: Int -> String
show_cell c | (c == -10) = "[X]"
            | (c == 0) = " _ "
            | (c < 0) = "[" ++ (show (abs c)) ++ "]"
            | otherwise = " " ++ show c ++ " "

-- Retorna uma string com todos os caracteres de um tabuleiro 
-- e com quebra de linha devidamente posicionada 
show_board :: Int -> [Int] -> String
show_board _ [] = ""
show_board i (a:b) | i < 0 = ""
                   | ((mod i size) == 0) = "\n" ++ (show_cell a) ++ (show_board (i-1) b)
                   | otherwise = (show_cell a) ++ (show_board (i-1) b)

-- Retorna uma string com todos os tabuleiros que resolvem o problema 
show_solution :: [[Int]] -> String
show_solution [] = ""
show_solution (a:b) = (show_board (size*size) a) ++ "\n" ++ (show_solution b)

x = -10 -- Casas pretas vazias no tabuleiro

-- O tabuleiro de entrada.
-- x é uma casa preta vazia.
-- 0 é uma casa branca vazia.
-- Um número negativo é um valor em casa preta
-- Um número positivo é um valor em casa branca
size = 6 -- Dimensões do tabuleiro 
board = [
    x,  0,  0, -1,  x,  x,
    x,  0,  0,  0,  5,  0,
    x,  0,  1,  0,  0,  0,
    4,  0,  0,  0,  0,  x,     
    0,  6,  5,  0,  0,  x,
    x,  x,  x,  0,  1, -4
    ]

-- size = 9 
-- board = [
--     -9,  6,  8,  1,  0,  0,  0,  4,  0,
--      0,  0,  x,  x,  4,  0,  0, -7,  x,
--     -5,  x,  x,  0,  3,  0,  x,  x,  0,
--      0,  x,  0,  0,  0,  4, -6,  0,  0, 
--      x,  0,  0,  0,  x,  0,  0,  0,  x,
--      3,  0,  x,  0,  5,  8,  0,  x,  0, 
--      0,  x,  x,  0,  0,  0,  x, -5,  0, 
--      x,  x,  5,  0,  0,  x, -4,  1,  0, 
--      0,  7,  0,  0,  0,  0,  0,  0, -1
--     ]

        
-- main = putStr (show_board (size*size) board)
main = putStr (show_solution (solve_str8ts board))





























