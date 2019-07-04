cores = {
    marrom = {191/255, 136/255, 99/255},
    branco = {240/255, 217/255, 181/255},
    cinza = {237/255, 235/255, 233/255}
}
------------------<fundo>-------------------------
local background = display.newRect(display.contentCenterX, display.contentCenterY, 800, 800)
background.fill = cores.cinza
------------------</fundo>------------------------

------------------<New game>---------------
------<evento de novo jogo>-----
function newGame( event )
    if ( event.phase == "began" ) then
        event.target.alpha = 0.5
        event.target.valor.alpha = 0.5
        display.getCurrentStage():setFocus( event.target )
    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
        event.target.alpha = 1
        event.target.valor.alpha = 1
        display.getCurrentStage():setFocus( nil )
    end
    tabuleiro:new(8)
    tabuleiro:posicionarPecas()
    mostrar(tabuleiro.matriz)
    pecaVez = nil
end
------<botão de novo jogo>------
newX, newY = 60, 2
newButton = display.newRoundedRect(newX, newY, 60, 40, 2)
newButton.fill = cores.branco
newButton.valor = display.newText("New", newX, newY, native.systemFont, 18)
newButton.valor:setFillColor(191/255, 136/255, 99/255)
newButton:addEventListener("touch", newGame)
------------------</New game>----------------------
------------------<placar>--------------
placarX, placarY = 160, 70
placar = display.newRoundedRect(placarX, placarY, 230, 70, 2)
placar.fill = cores.branco

pecas = {
    {nome = 'negras', tipo = 'normal', created = false},
    {nome = 'negras', tipo = 'dama', created = false},
    {nome = 'brancas', tipo = 'normal', created = false},
    {nome = 'brancas', tipo = 'dama', created = false}
}

function gerarPlacar()
    x, y, z = 85, 60, 90
    for i = 1, 4 do
        if(pecas[i].created == false) then
            pecas[i].image = display.newImage(path(pecas[i]), x, y)
            pecas[i].image:scale(0.5, 0.5)
            pecas[i].quantidade = display.newText(getQuantidade(pecas[i]), x, z, native.systemFont, 20)
            pecas[i].quantidade:setFillColor(191/255, 136/255, 99/255)
            pecas[i].created = true
        else
            pecas[i].quantidade:removeSelf()
            pecas[i].quantidade = nil
            pecas[i].quantidade = display.newText(getQuantidade(pecas[i]), x, z, native.systemFont, 20)
            pecas[i].quantidade:setFillColor(191/255, 136/255, 99/255)
        end
        x = x + 50
    end
end

function getQuantidade(peca)
    matriz = tabuleiro.matriz
    quantidade = 0
    for i = 1, #matriz do
        for j = 1, #matriz do
            if(matriz[i][j] ~= nil) then
                if (matriz[i][j].nome == peca.nome and matriz[i][j].tipo == peca.tipo) then
                    quantidade = quantidade + 1
                end
            end
        end
    end
    return quantidade..''
end
------------------<contagem de peças>--------------
-----------------</placar>-------------
pecaSelecionada, posicaoSelecionada, peca, pecaVez = nil

function moveEvent(event)
    i, j = event.target.i, event.target.j
    if (pecaVez == nil) then
        alternarJogadores()
    end
    if (tabuleiro.matriz[i][j] ~= nil and (pecaSelecionada == nil or tabuleiro.matriz[i][j].nome == peca.nome) and tabuleiro.matriz[i][j].nome == pecaVez) then
        pecaSelecionada = {i = i, j = j}
        peca = tabuleiro.matriz[i][j]
    elseif (pecaSelecionada ~= nil) then
        posicaoSelecionada = {i = i, j = j}
        jogadaEfetuada, capturaRealizada = tabuleiro:fazerJogada(peca, pecaSelecionada.i, pecaSelecionada.j, posicaoSelecionada.i, posicaoSelecionada.j)
        if (jogadaEfetuada) then
            if (not(capturaRealizada)) then
                alternarJogadores()
            end
            resetValues()
            mostrar()
        end
    end
end

function resetValues()
    peca = nil
    pecaSelecionada = nil
    posicaoSelecionada = nil
end

function alternarJogadores()
    pecaVez = pecaVez == 'brancas' and 'negras' or 'brancas'
end
-----------------</movimento das pecas>-------------
------------<gera a imagem do tabuleiro>---------
tableGroup = display.newGroup()
tableGroup.x, tableGroup.y = 31, 40

function newRect(group, x, y, width, height, i, j, color)
    local rect = nil
    if (group == nil) then
        rect = display.newRect(x, y, width, height)
    else
        rect = display.newRect(group, x, y, width, height)
    end
        rect.i, rect.j = i, j
        rect.fill = color
        rect.image = nil
    return rect
end

function tableView()
    posX, posY, pecaSize = -46, 100, 39
    for i = 1, 8 do
        for j = 1, 8 do
            rect = newRect(tableGroup, posX + pecaSize * j, posY, pecaSize, pecaSize, i, j,  getCor(i, j))
            rect:addEventListener("touch", moveEvent)
        end
        posY = posY + pecaSize
    end
end

function getCor(i, j)   --alterna as cores do tabuleiro, brancas e marrons.
	if (i % 2 == 0) then
		if (j % 2 == 0 and i % 2 == 0) then
			cor = cores.branco
        else
			cor = cores.marrom
		end
	else
		if (j % 2 == 0) then
			cor = cores.marrom
		else
			cor = cores.branco
		end
	end
	return cor
end
------------</gera a imagem do tabuleiro>---------
------------<mostra as peças no tabuleiro>--------
function mostrar()
    tableView()
    gerarPlacar()
    matriz = tabuleiro.matriz
    posX, posY, k = 32, 40, 1
    for i = 1, #matriz do
        for j = 1, #matriz do
            if (matriz[i][j] ~= nil) then
                local image = display.newImage(tableGroup, path(matriz[i][j]), tableGroup[k].x, tableGroup[k].y)
                image:scale(0.6, 0.6)
            end
            k = k + 1
        end
    end
end

function path(peca)
    return 'icon/peca_'..peca.nome..'_'..peca.tipo..'.png'
end
------------</mostra as peças no tabuleiro>--------
gerarPlacar()
