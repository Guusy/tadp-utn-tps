describe 'save' do
  context 'cuando se ejecuta en un objeto no persistido' do
    before do
      class Persona
        include Orm

      end
      @persona = Persona.new
      @persona.save!
    end

    it 'Le genera agrega la propiedad Id' do
      expect(@persona).to have_attributes(:id => "0")
    end
  end
end