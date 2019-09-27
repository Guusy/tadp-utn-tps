describe 'validate' do
  after do
    TADB::DB.clear_all
  end

  context 'cuando se trata de persistir atributo que es String con un numero' do
    before do
      class Pepita
        include Orm
        has_one String, named: :nombre
      end
      @pepita = Pepita.new
      @pepita.nombre = 21312948
    end
    it 'deberia fallar con "El [ATRIBUTO] no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
      expect { @pepita.save! }.to raise_error("El nombre no es un String! valor actual : 21312948")
    end
  end
  context 'cuando se trata de persistir atributo que es Numeric con un string' do
    before do
      class Contador
        include Orm
        has_one Numeric, named: :acumulador
      end
      @contador = Contador.new
      @contador.acumulador = "sadasdasda"
    end
    it 'deberia fallar con "El [ATRIBUTO] no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
      expect { @contador.save! }.to raise_error("El acumulador no es un Numeric! valor actual : sadasdasda")
    end
  end
end