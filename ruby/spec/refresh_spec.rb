require 'rspec'

describe 'refresh' do
  before do
    class Patito
      include Orm
      has_one String, named: :color
    end
  end
  after do
    TADB::DB.clear_all
  end
  context 'cuando se hace refresh sobre un objeto no persistido' do
    before do
      @patito_no_persistible = Patito.new
    end
    it 'falla con un error "Este objeto no esta persistido"' do
      expect { @patito_no_persistible.resfresh! }.to raise_exception("Este objeto no esta persistido")
    end
  end

  context 'cuando se se modifica un objeto persistido' do
    before do
      @patito_persistido = Patito.new
      @patito_persistido.color = 'amarillo'
      @patito_persistido.save!
      @patito_persistido.color = 'rojo'
    end
    it 'se actualizan la propiedades en el objeto' do
      expect(@patito_persistido.color).to eq('rojo')
    end
    context "y se hace refresh sobre el" do
      it 'se vuelve a su estado inicial' do
        @patito_persistido.resfresh!
        expect(@patito_persistido.color).to eq('amarillo')
      end
    end
  end
end