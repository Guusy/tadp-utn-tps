require 'rspec'

describe 'from y to' do
  after do
    TADB::DB.clear_all
  end
  # TODO : preguntar, que pasa si le declaramos un from y to a una array/String/Boolean ?  hay que fallar ?
  # Existen los numbers ? no deberian ser numeric ?
  context 'cuando se le declara from' do
    before do
      class Cancha
        include Orm
        has_one Integer, named: :jugadores, from: 10
      end
    end
    context 'y se trata de guardar un objeto con menos valor que el from' do
      before do
        @cancha = Cancha.new
        @cancha.jugadores = 4
      end
      it 'falla "El atributo [ATRIBUTO] es menor a [FROM], valor actual : [VALOR]"' do
        expect { @cancha.save! }.to raise_error("El atributo jugadores es menor a 10, valor actual : 4")
      end
    end
  end

  context 'cuando se le declara to' do
    before do
      class Paintball
        include Orm
        has_one Integer, named: :jugadores, to: 10
      end
    end
    context 'y se trata de guardar un objeto con menos valor que el from' do
      before do
        @paintball = Paintball.new
        @paintball.jugadores = 25
      end
      it 'falla "El atributo [ATRIBUTO] es mayor a [FROM], valor actual : [VALOR]"' do
        expect { @paintball.save! }.to raise_error("El atributo jugadores es mayor a 10, valor actual : 25")
      end
    end
  end
end