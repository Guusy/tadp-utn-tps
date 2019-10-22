describe 'has_one' do
  context 'cuando se declara una clase con has_one' do
    before do
      class Persona
        include Persistible
        has_one String, named: :nombre
      end
      @una_persona = Persona.new
    end
    after do
      TADB::DB.clear_all
    end
    it 'se le agrega el atributo a la' do
      expect(@una_persona).to have_attributes(:nombre => nil)
    end

    it 'se le agrega el mensaje id' do
      expect(@una_persona.id).to eq(nil)
    end
  end
end