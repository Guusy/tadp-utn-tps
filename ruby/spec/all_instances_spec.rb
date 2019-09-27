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
      context "con una dependencia simple" do
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

        it 'y pedimos all_instances, nos devuelve los objetos de dominio' do
          computadora_db = @all_instances[0]
          expect(computadora_db.id).to eq(@computadora.id)
          expect(computadora_db.teclado.id).to eq(@teclado.id)
          expect(computadora_db.teclado.tipo).to eq(@teclado.tipo)
        end
      end

      context "con una dependencia compuesta A -> B -> C" do
        before do
          @acero = Material.new
          @acero.peso = "200"
          @pala = Herramienta.new
          @pala.material = @acero
          @pepe = Obrero.new
          @pepe.herramienta = @pala
          @pepe.save!
        end

        it 'y pedimos all_instances, nos devuelve los objetos de dominio' do
          obrero_db = Obrero.all_instances[0]
          expect(obrero_db.herramienta.material.id).to eq(@acero.id)
          expect(obrero_db.herramienta.material.peso).to eq("200")
        end
      end

    end

  end

  context 'cuando le preguntas un all_instances a un modulo' do
    before do
      module Atacante
        include Orm
        has_one Numeric, named: :poder_ofensivo
      end
    end
    context 'y esta incluido en una sola clase' do
      before do
        class Guerrero
          include Orm
          include Atacante
          has_one String, named: :rango
        end
        @comandante = Guerrero.new
        @comandante.poder_ofensivo = 250
        @comandante.rango = "comandante"
        @comandante.save!
      end

      it 'responde con todas las instancias' do
        guerrero_all_instances = Atacante.all_instances()[0]
        expect(guerrero_all_instances.rango).to eq(@comandante.rango)
        expect(guerrero_all_instances.poder_ofensivo).to eq(@comandante.poder_ofensivo)
      end
    end

    context 'y esta incluido en varias clases' do
      before do
        class Muralla
          include Orm
          include Atacante
          has_one String, named: :alto
        end
        class Cohete
          include Orm
          include Atacante
          has_one String, named: :tipo_nafta
        end
        @muralla_china = Muralla.new
        @muralla_china.alto = "1000m"
        @muralla_china.save!
        @cohete = Cohete.new
        @cohete.tipo_nafta = "gnc"
        @cohete.save!
      end

      it 'responde con todas las instancias' do
        muralla_cohete_all_instances = Atacante.all_instances
        muralla = muralla_cohete_all_instances[0]
        cohete = muralla_cohete_all_instances[1]
        expect(muralla.alto).to eq(@muralla_china.alto)
        expect(cohete.tipo_nafta).to eq(@cohete.tipo_nafta)
      end
    end

  end


end