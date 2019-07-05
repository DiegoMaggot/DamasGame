pecaClass = require 'peca'

tabuleiro = {
    matriz = {}
}

function tabuleiro:new(tamanho)
    for i = 1, tamanho do
        self.matriz[i] = {}   
        for j = 1, tamanho do
            self.matriz[i][j] = nil
        end
    end
end

function tabuleiro:posicionarPecas() --posiciona as peças
    for i = 1, #self.matriz do
        for j = 1, #self.matriz do
            if (i <= 3) then                                                --posiciona as peças brancas
                if (i % 2 ~= 0 and j % 2 ~= 0) then
                    self.matriz[i][j] = pecaClass:new('brancas')
                elseif (i % 2 == 0 and j % 2 == 0) then
                    self.matriz[i][j] = pecaClass:new('brancas')
                end
            elseif (i >= (#self.matriz - 2) and i <= (#self.matriz)) then   --posiciona as peças negras
                if (j % 2 == 0 and i % 2 == 0) then
                    self.matriz[i][j] = pecaClass:new('negras')
                elseif (i % 2 ~= 0 and j % 2 ~= 0) then
                    self.matriz[i][j] = pecaClass:new('negras')
                end
            else
                self.matriz[i][j] = nil
            end
        end
    end
end

function tabuleiro:posicaoLivre(linha, coluna)
    return self.matriz[linha][coluna] == nil and true or false
end

function tabuleiro:selecionarPeca(peca, linha, coluna)
    if (self.matriz[linha][coluna] == nil) then
        return false
    end
    return self.matriz[linha][coluna].nome == peca.nome and true or false
end

function tabuleiro:fazerJogada(peca, linha, coluna, novaLinha, novaColuna)
    jogadaEfetuada, capturaRealizada = false, false
        if(peca.tipo == 'dama') then
            jogadaEfetuada, capturaRealizada = tabuleiro:acaoDamas(peca, linha, coluna, novaLinha, novaColuna) 
        elseif (tabuleiro:capturarPeca(peca, linha, coluna, novaLinha, novaColuna)) then
            jogadaEfetuada, capturaRealizada = true, true
        elseif (tabuleiro:moverPeca(peca, linha, coluna, novaLinha, novaColuna)) then
            jogadaEfetuada = true
        end
        if (jogadaEfetuada and tabuleiro:promocaoValida(peca, novaLinha)) then
            pecaClass:promover(peca)
        end
    return jogadaEfetuada, capturaRealizada
end

function tabuleiro:moverPeca(peca, linha, coluna, novaLinha, novaColuna)
    if (tabuleiro:selecionarPeca(peca, linha, coluna) 
    and tabuleiro:posicaoLivre(novaLinha, novaColuna) 
    and tabuleiro:movimentoValido(peca, linha, coluna, novaLinha, novaColuna)) then
        self.matriz[linha][coluna] = nil
        self.matriz[novaLinha][novaColuna] = peca
        return true
    end
    return false
end

function tabuleiro:executarCapturas(pecasInimigas)
    if (#pecasInimigas > 0) then
        for c, pos in ipairs(pecasInimigas) do
            if(pos[1] >= 1 and pos[1] <= 8 and pos[2] >= 1 and pos[2] <= 8) then
                self.matriz[pos[1]][pos[2]] = nil
            end
        end
    end
end

function tabuleiro:acaoDamas(peca, linha, coluna, novaLinha, novaColuna) --movimento e captura das damas
    pecasInimigas = {} --posicoes das pecas inimigas no caminho da dama
    cont = 1
    repeat
        if(tabuleiro:posicaoLivre(novaLinha, novaColuna)) then
            if (linha < novaLinha and coluna > novaColuna) then --diagonal inferior esquerda
                if (linha + cont == novaLinha and coluna - cont == novaColuna and (linha + cont <= 8) and (coluna - cont >= 1)) then
                    tabuleiro:executarCapturas(pecasInimigas)  --se ao chegar na posição de destino tiver tudo certo executa as capturas
                    capturaRealizada = #pecasInimigas > 0 and true or false
                    self.matriz[linha][coluna] = nil
                    self.matriz[novaLinha][novaColuna] = peca
                    return true, capturaRealizada
                elseif (self.matriz[linha + cont][coluna - cont] ~= nil) then
                    if(self.matriz[linha + cont][coluna - cont].nome ~= peca.nome and tabuleiro:posicaoLivre(linha + cont + 1, coluna - cont + 1)) then
                        table.insert(pecasInimigas, {linha + cont, coluna - cont}) --salva a posição da peca inimiga se for uma captura válida
                    else
                        return false
                    end
                end
            elseif (linha < novaLinha and coluna < novaColuna) then --diagonal inferior direita
                if (linha + cont == novaLinha and coluna + cont == novaColuna and (linha + cont <= 8) and (coluna + cont <= 8)) then
                    tabuleiro:executarCapturas(pecasInimigas) --se ao chegar na posição de destino tiver tudo certo executa as capturas
                    capturaRealizada = #pecasInimigas > 0 and true or false
                    self.matriz[linha][coluna] = nil
                    self.matriz[novaLinha][novaColuna] = peca
                    return true, capturaRealizada
                elseif (self.matriz[linha + cont][coluna + cont] ~= nil) then
                    if(self.matriz[linha + cont][coluna + cont].nome ~= peca.nome and tabuleiro:posicaoLivre(linha + cont + 1, coluna + cont + 1)) then
                        table.insert(pecasInimigas, {linha + cont, coluna + cont}) --salva a posição da peca inimiga se for uma captura válida
                    else
                        return false
                    end
                end
            elseif (linha > novaLinha and coluna > novaColuna) then --diagonal superior esquerda
                if (linha - cont == novaLinha and coluna - cont == novaColuna and (linha - cont >= 1) and (coluna - cont >= 1)) then
                    tabuleiro:executarCapturas(pecasInimigas) --se ao chegar na posição de destino tiver tudo certo executa as capturas
                    capturaRealizada = #pecasInimigas > 0 and true or false
                    self.matriz[linha][coluna] = nil
                    self.matriz[novaLinha][novaColuna] = peca
                    return true, capturaRealizada
                elseif (self.matriz[linha - cont][coluna - cont] ~= nil) then
                    if(self.matriz[linha - cont][coluna - cont].nome ~= peca.nome and tabuleiro:posicaoLivre(linha - cont + 1, coluna - cont + 1)) then
                        table.insert(pecasInimigas, {linha - cont, coluna - cont}) --salva a posição da peca inimiga se for uma captura válida
                    else
                        return false
                    end
                end
            elseif (linha > novaLinha and coluna < novaColuna) then --diagonal superior direita
                if (linha - cont == novaLinha and coluna + cont == novaColuna and (linha - cont >= 1) and (coluna + cont <= 8)) then
                    tabuleiro:executarCapturas(pecasInimigas) --se ao chegar na posição de destino tiver tudo certo executa as capturas
                    capturaRealizada = #pecasInimigas > 0 and true or false
                    self.matriz[linha][coluna] = nil
                    self.matriz[novaLinha][novaColuna] = peca
                    return true, capturaRealizada
                elseif (self.matriz[linha - cont][coluna + cont] ~= nil) then
                    if(self.matriz[linha - cont][coluna + cont].nome ~= peca.nome and tabuleiro:posicaoLivre(linha - cont + 1, coluna + cont + 1)) then
                        table.insert(pecasInimigas, {linha - cont, coluna + cont}) --salva a posição da peca inimiga se for uma captura válida
                    else
                        return false
                    end
                end
            end
        else
            return false
        end
        cont = cont + 1
    until cont == 8
end

function tabuleiro:movimentoValido(peca, linha, coluna, novaLinha, novaColuna) --verifica se o movimento é válido para damas e peças normais.
    if (self.matriz[linha][coluna] ~= nil) then
        pecasInimigas = {}
        cont = 1
            if (peca.nome == 'negras' and peca.tipo == 'normal' and novaLinha > linha) then     --impede que as negras joguem voltando
                return false
            elseif (peca.nome == 'brancas' and peca.tipo == 'normal' and novaLinha < linha) then --impede que as brancas joguem voltando
                return false
            end
            if (linha + cont == novaLinha and coluna - cont == novaColuna and (linha + cont <= 8) and (coluna - cont >= 1)) then
                return true
            elseif (linha + cont == novaLinha and coluna + cont == novaColuna and (linha + cont <= 8) and (coluna + cont <= 8)) then
                return true
            elseif (linha - cont == novaLinha and coluna - cont == novaColuna and (linha - cont >= 1) and (coluna - cont >= 1)) then
                return true
            elseif (linha - cont == novaLinha and coluna + cont == novaColuna and (linha - cont >= 1) and (coluna + cont <= 8)) then
                return true
            end
    end
    return false
end

function tabuleiro:capturaValida(peca, linha, coluna, novaLinha, novaColuna) --verifica se entre a posição da peça e a posição de destino tem uma peça inimiga
    if (linha + 2 == novaLinha and coluna - 2 == novaColuna and tabuleiro:pecaInimiga(peca, linha + 1, coluna - 1)) then
        return (linha + 1), (coluna - 1)
    elseif (linha + 2 == novaLinha and coluna + 2 == novaColuna and tabuleiro:pecaInimiga(peca, linha + 1, coluna + 1)) then
        return (linha + 1), (coluna + 1)
    elseif (linha - 2 == novaLinha and coluna - 2 == novaColuna and tabuleiro:pecaInimiga(peca, linha - 1, coluna - 1)) then
        return (linha - 1), (coluna - 1)
    elseif (linha - 2 == novaLinha and coluna + 2 == novaColuna and tabuleiro:pecaInimiga(peca, linha - 1, coluna + 1)) then
        return (linha - 1), (coluna + 1)
    end
    return nil
end

function tabuleiro:capturarPeca(peca, linha, coluna, novaLinha, novaColuna)
    linhaPecaInimiga, colunaPecaInimiga  = tabuleiro:capturaValida(peca, linha, coluna, novaLinha, novaColuna)
    if((linhaPecaInimiga ~= nil and colunaPecaInimiga ~= nil)) then
        if (tabuleiro:selecionarPeca(peca, linha, coluna) and tabuleiro:posicaoLivre(novaLinha, novaColuna)) then
            self.matriz[novaLinha][novaColuna] = peca
            self.matriz[linha][coluna] = nil
            self.matriz[linhaPecaInimiga][colunaPecaInimiga] = nil
            return true
        end
    end
    return false
end

function tabuleiro:pecaInimiga(peca, linha, coluna)
    if (self.matriz[linha][coluna] ~= nil) then
        return self.matriz[linha][coluna].nome ~= peca.nome and true or false
    end
    return false
end

function tabuleiro:promocaoValida(peca, linha)
    if (peca.tipo == 'normal') then
        if (peca.nome == 'brancas') then
            return linha == 8 and true or false
        elseif (peca.nome == 'negras') then
            return linha == 1 and true or false
        end
    end
    return false
end

return tabuleiro
