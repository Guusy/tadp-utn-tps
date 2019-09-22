describe 'all_instances' do
  before do
    class Computadora
      include Orm
    end
  end

  after do
    TADB::DB.clear_all
  end

  context 'cuando no hay ningun registro cargado' do
    it 'y pedimos all_instances, nos devuelve un array vacio' do
      expect(Computadora.all_instances).to match_array([])
    end
  end

  context "cuando hay registros en la DB" do

    context "y todos sus atributos son primitivos" do
      before do
        @computadora_1 = Computadora.new
        @computadora_1.save!
        @computadora_2 = Computadora.new
        @computadora_2.save!
        @all_instances = Computadora.all_instances

      end
      it 'y pedimos all_instances, nos devuelve los objetos de dominio ' do
        expect(@all_instances[0].id).to eq(@computadora_1.id)
        expect(@all_instances[1].id).to eq(@computadora_2.id)
      end
    end

    context "y algunos de sus atributos representa una entidad" do
      before do
        class Teclado
          include Orm
          has_one String, named: :tipo
        end

        class Computadora
          has_one Teclado, named: :teclado
        end

        @teclado = Teclado.new
        @teclado.tipo = "mecanico"
        @teclado.save!
        @computadora = Computadora.new
        @computadora.teclado = @teclado
        @computadora.save!

        @all_instances = Computadora.all_instances
      end

      it 'y pedimos all_instances, nos devuelve los objetos de dominio ' do
        computadora_db = @all_instances[0]
        expect(computadora_db.id).to eq(@computadora.id)
        expect(computadora_db.teclado.id).to eq(@teclado.id)
        expect(computadora_db.teclado.tipo).to eq(@teclado.tipo)
      end
    end

  end


end