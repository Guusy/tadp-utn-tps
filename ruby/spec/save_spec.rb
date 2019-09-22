describe 'save' do
  after do
    TADB::DB.clear_all
  end
  context 'cuando se ejecuta en un objeto no persistido con atributos primitivos' do
    before do
      class Persona
        include Orm
        has_one String, named: :nombre
        has_one String, named: :apellido
        attr_accessor :valor_no_persistido
      end
      @persona = Persona.new
      @persona.nombre = "Gonzalo gras cantou"
      @persona.save!
      @persona_db = find_by_id("persona", @persona.id)
    end
    it 'Le genera agrega la propiedad Id' do
      expect(@persona).to respond_to(:id)
    end

    it 'Agrega el objeto a la DB con los datos marcados como persistibles' do
      expect(@persona_db[:nombre]).to eq @persona.nombre
    end

    it 'no agrega los atributos a la DB que no fueron marcados como persistibles' do
      expect(@persona_db[:valor_no_persistido]).to eq nil
    end

    it 'se ignoran los attributos que no tienen valor' do
      expect(@persona_db[:apellido]).to eq nil
    end
  end
  context 'cuando se ejecuta en un objeto no persistido que tiene atributos no primitivos (otras clases) ' do
    before do
      class Notebook
        include Orm
        has_one String, named: :numero_serial
      end
      class Programador
        include Orm
        has_one Notebook, named: :notebook
      end
    end
    context "que aun no estan persistidos y tienen una dependencia simple" do
      before do
        @notebook = Notebook.new
        @notebook.numero_serial = "213ACDE23"
        @programador = Programador.new
        @programador.notebook = @notebook
        @programador.save!
      end

      it 'los atributos no primitivos se referencian con un id en la base de datos' do
        programador_db = find_by_id('programador', @programador.id)
        expect(programador_db[:notebook]).to eq(@notebook.id)
      end

      it 'los atributos no primitivos se registran en sus respectivas base de datos' do
        notebook_db = find_by_id('notebook', @notebook.id)
        expect(notebook_db[:numero_serial]).to eq(@notebook.numero_serial)
      end
    end

    context "que aun no estan persistidos y tienen una dependencia compuesta A->B->C" do
      before do
        @acero = Material.new
        @acero.peso = "200"
        @pala = Herramienta.new
        @pala.material = @acero
        @pepe = Obrero.new
        @pepe.nombre = "pepe"
        @pepe.herramienta = @pala
        @pepe.save!
      end

      it 'los atributos no primitivos se referencian con un id en la base de datos' do
        obrero_db = find_by_id('obrero', @pepe.id)
        expect(obrero_db[:herramienta]).to eq(@pala.id)
        herramienta_db = find_by_id('herramienta', @pala.id)
        expect(herramienta_db[:material]).to eq(@acero.id)
      end

      it 'los atributos no primitivos se registran en sus respectivas base de datos' do
        material_db = find_by_id('material', @acero.id)
        expect(material_db[:peso]).to eq(@acero.peso)
      end
    end

    context "que ya estan persistidos" do
      context "con una referencia simple" do
        before do
          @notebook = Notebook.new
          @notebook.numero_serial = "213ACDE23"
          @notebook.save!
          @programador = Programador.new
          @programador.notebook = @notebook
          @programador.save!
        end

        it 'los atributos no primitivos se referencian con un id en la base de datos' do
          programador_db = find_by_id('programador', @programador.id)
          expect(programador_db[:notebook]).to eq(@notebook.id)
        end

        it 'no se persiste 2 veces el atributo referenciado' do
          notebooks_db =  TADB::DB.table('notebook').entries
          expect(notebooks_db.size).to eq(1)
        end
      end

      context "con una dependencia compuesta A->B->C" do
        before do
          @acero = Material.new
          @acero.peso = "200"
          @acero.save!
          @pala = Herramienta.new
          @pala.material = @acero
          @pala.save!
          @pepe = Obrero.new
          @pepe.nombre = "pepe"
          @pepe.herramienta = @pala
          @pepe.save!
        end

        it 'no se persiste 2 veces los atributos referenciados' do
          herramienta_db =  TADB::DB.table('herramienta').entries
          expect(herramienta_db.size).to eq(1)
          material_db =  TADB::DB.table('material').entries
          expect(material_db.size).to eq(1)
          obrero_db =  TADB::DB.table('obrero').entries
          expect(obrero_db.size).to eq(1)
        end

      end
    end
  end
end