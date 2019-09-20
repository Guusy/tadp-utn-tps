describe 'save' do
  context 'cuando se ejecuta en un objeto no persistido' do
    before do
      TADB::DB.clear_all
      class Persona
        include Orm
        has_one String, named: :nombre
        attr_accessor :valor_no_persistido
      end
      @persona = Persona.new
      @persona.nombre = "Gonzalo gras cantou"
      @persona.save!
      @persona_db = get_find_by_id(@persona.id)
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

    def get_find_by_id(id)
      return TADB::DB.table('persona')
                 .entries
                 .select { |entry| entry[:id] === id }
                 .first
    end

  end
end