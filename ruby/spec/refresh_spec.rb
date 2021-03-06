require 'rspec'

describe 'refresh' do
  before do
    class Patito
      include Persistible
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

  context 'cuando se se modifica un atributo persistido de un objeto que ya fue persistido' do
    context 'con dependencia simple' do
      before do
        class Casa
          include Persistible
          has_one String, named: :color
        end
        class Patito
          has_one Casa, named: :casa
        end
        @patito_persistido = Patito.new
        @casa = Casa.new
        @casa.color = "verde oscuro"
        @casa.save!
        @patito_persistido.casa = @casa
        @patito_persistido.save!
        @patito_persistido.casa.color = 'salmon'
      end
      it 'se actualizan la propiedades en el atributo' do
        expect(@patito_persistido.casa.color).to eq('salmon')
      end
      context "y se hace refresh sobre el" do
        it 'se vuelve el atributo persitido a su estado inicial' do
          @patito_persistido.resfresh!
          expect(@patito_persistido.casa.color).to eq('verde oscuro')
        end
      end
    end

    context 'con dependencia compuesta' do
      before do
        @acero = Material.new
        @acero.peso = "200"
        @pala = Herramienta.new
        @pala.material = @acero
        @pepe = Obrero.new
        @pepe.nombre = "pepe"
        @pepe.herramienta = @pala
        @pepe.save!

        @pepe.herramienta.material.peso = "2500"
      end
      it 'se actualizan la propiedades en el atributo' do
        expect(@pepe.herramienta.material.peso).to eq('2500')
      end

      context "y se hace refresh sobre el" do
        it 'se vuelve el atributo persitido a su estado inicial' do
          @pepe.resfresh!
          expect(@pepe.herramienta.material.peso).to eq('200')
        end
      end
    end

  end
end