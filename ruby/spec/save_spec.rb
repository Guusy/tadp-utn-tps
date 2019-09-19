describe 'save' do
  context 'cuando se ejecuta en un objeto no persistido' do
    before do
      TADB::DB.clear_all
      class Persona
        include Orm
        has_one String, named: :nombre
      end
      @persona = Persona.new
      @persona.nombre = "Gonzalo gras cantou"
      @persona.save!
    end

    it 'Le genera agrega la propiedad Id' do
      expect(@persona).to respond_to(:id)
    end

    it 'Agrega el objeto a la base de datos' do
      persona_DB = TADB::DB.table('persona')
                      .entries
                      .select { |entry| entry[:id] === @persona.id }
                      .first
      expect(persona_DB[:nombre]).to eq @persona.nombre
    end
  end
end