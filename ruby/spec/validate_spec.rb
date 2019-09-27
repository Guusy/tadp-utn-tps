describe 'validate' do
  after do
    TADB::DB.clear_all
  end
  # TODO :  preguntar que onda con los atributos nil  ?  deberia explotar todo ?

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
    it 'falla con "El [ATRIBUTO] no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
      expect { @contador.save! }.to raise_error("El acumulador no es un Numeric! valor actual : sadasdasda")
    end
  end

  context 'cuando se trata de persisitir un atributo que es complejo' do
    before do
      class Portero
        include Orm
        has_one Numeric, named: :edad
      end
      class Edificio
        include Orm
        has_one Portero, named: :portero
      end
    end

    context 'con un primitivo' do
      before do
        @edificio = Edificio.new
        @edificio.portero = "hola"
      end

      it 'falla con "El [ATRIBUTO] no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
        expect { @edificio.save! }.to raise_error("El portero no es un Portero! valor actual : hola")
      end
    end

    context 'el cual tiene en su interior un atributo erroneo' do
      before do
        @portero = Portero.new
        @portero.edad = "teclado"
        @edificio = Edificio.new
        @edificio.portero = @portero
      end

      it 'falla con "El [ATRIBUTO] no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
        expect { @edificio.save! }.to raise_error("El edad no es un Numeric! valor actual : teclado")
      end
    end
  end

  context 'cuando se trata de persistir un atributo con has_many' do
    before do
      class Hijo
        include Orm
        has_one String, named: :nombre
      end
      class Madre
        include Orm
        has_many Hijo, named: :hijos
      end
    end
    context 'con un primitivo' do
      before do
        @madre = Madre.new
        @madre.hijos = "hola"
      end

      it 'falla con "El [ATRIBUTO] no es un Array! valor actual : [VALOR_ACTUAL]"' do
        expect { @madre.save! }.to raise_error("El hijos no es un Array! valor actual : hola")
      end
    end

    context 'que cumple que sea un array' do
      context 'pero los atributos de adentro no cumplen con el tipo especificado' do
        before do
          @madre = Madre.new
          @madre.hijos = []
          @madre.hijos.push(Obrero.new)
        end

        it 'falla con "El [ATRIBUTO] no es un [TIPO]! valor actual : [VALOR_ACTUAL]"' do
          expect { @madre.save! }.to raise_error("El hijos no es un Hijo! valor actual : Obrero")
        end
      end
    end
  end


end