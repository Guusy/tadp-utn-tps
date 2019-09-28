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
    it 'deberia fallar con "En [CLASE] el atributo no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
      expect { @pepita.save! }.to raise_error("En Pepita el atributo nombre no es un String! valor actual : 21312948")
    end
  end
  context 'cuando se tiene un atributo booleano' do
    before do
      class Camara
        include Orm
        has_one Boolean, named: :es_profesional
      end
    end
    context 'y se trata de persistir con un numero' do
      before do
        @camara_profesional = Camara.new
        @camara_profesional.es_profesional = 21312948
      end
      it 'deberia fallar con "En [CLASE] el atributo  no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
        expect { @camara_profesional.save! }.to raise_error("En Camara el atributo es_profesional no es un Boolean! valor actual : 21312948")
      end
    end

    context 'y se trata de persistir con un booleano' do
      before do
        @camara_profesional = Camara.new
        @camara_profesional.es_profesional = true
      end
      it 'NO falla la validacion' do
        expect { @camara_profesional.save! }.not_to raise_error
      end
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
    it 'falla con "En [CLASE] el atributo no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
      expect { @contador.save! }.to raise_error("En Contador el atributo acumulador no es un Numeric! valor actual : sadasdasda")
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

      it 'falla con "En [CLASE] el atributo no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
        expect { @edificio.save! }.to raise_error("En Edificio el atributo portero no es un Portero! valor actual : hola")
      end
    end

    context 'el cual tiene en su interior un atributo erroneo' do
      before do
        @portero = Portero.new
        @portero.edad = "teclado"
        @edificio = Edificio.new
        @edificio.portero = @portero
      end

      it 'falla con "En [CLASE] el atributo no es un [TIPO_ESPERADO]! valor actual : [VALOR_ACTUAL]"' do
        expect { @edificio.save! }.to raise_error("En Portero el atributo edad no es un Numeric! valor actual : teclado")
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

      it 'falla con "En [CLASE] el atributo [ATRIBUTO] no es un Array! valor actual : [VALOR_ACTUAL]"' do
        expect { @madre.save! }.to raise_error("En Madre el atributo hijos no es un Array! valor actual : hola")
      end
    end

    context 'que cumple que sea un array' do
      context 'pero los atributos de adentro no cumplen con el tipo especificado' do
        before do
          @madre = Madre.new
          @madre.hijos = []
          @madre.hijos.push(Obrero.new)
        end

        it 'falla con "En [CLASE] el atributo no es un [TIPO]! valor actual : [VALOR_ACTUAL]"' do
          expect { @madre.save! }.to raise_error("En Madre el atributo hijos no es un Hijo! valor actual : Obrero")
        end
      end

      context 'pero los atributos de adentro tienen atributos invalidos' do
        before do
          @madre = Madre.new
          @madre.hijos = []
          @hijo = Hijo.new
          @hijo.nombre = 213123
          @madre.hijos.push(@hijo)
        end

        it 'falla con "En [CLASE] el atributo no es un [TIPO]! valor actual : [VALOR_ACTUAL]"' do
          expect { @madre.save! }.to raise_error("En Hijo el atributo nombre no es un String! valor actual : 213123")
        end
      end
    end
  end


end