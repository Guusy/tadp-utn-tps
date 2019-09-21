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
    context "que aun no estan persistidas" do
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
  end
end