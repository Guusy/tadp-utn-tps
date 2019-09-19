require 'rspec'

describe 'refresh' do
  before do
    TADB::DB.clear_all
    class Patito
      include Orm
      has_one String, named: :color
    end
  end


  context 'cuando se hace refresh sobre un objeto no persistido' do
    before do
      @patito_no_persistible = Patito.new
    end
    it 'falla con un error "Este objeto no esta persistido"' do
      expect { @patito_no_persistible.resfresh! }.to raise_exception("Este objeto no esta persistido")
    end
  end

  context 'cuando se hace refresh sobre un objeto persistido' do
    before do
      @patito_persistido = Patito.new
      @patito_persistido.color = 'amarillo'
      @patito_persistido.save!
      @patito_persistido.color = 'rojo'
      @patito_persistido.resfresh!
    end
    it 'se actualizan la propiedades en el objeto' do
      @patito_persistido.color.should eq('rojo')
    end

  end
end