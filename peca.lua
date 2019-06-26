peca = { nome = '', tipo = '' }

function peca:new(nome)
    novaPeca = {}
    novaPeca = setmetatable(novaPeca, {__index = peca})
    novaPeca.nome = nome
    novaPeca.tipo = 'normal'
    return novaPeca
end

function peca:promover(peca)    
    peca.tipo = 'dama'
end

return peca