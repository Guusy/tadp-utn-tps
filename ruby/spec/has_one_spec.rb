require 'rspec'
require_relative '../src/Orm'

describe 'has_one' do
  context 'cuando se declara una clase con has_one' do
    before do
      class Persona
        extend Orm
        has_one String, named: :nombre
      end
    end
    it 'se le agrega el atributo a la' do
      persona = Persona.new
      expect(persona).to have_attributes(:nombre => nil)
    end

    # TODO: ver como chequear esto
    # it 'se le asigna el tipo especificado a el atributo ' do
    # persona = Persona.new
    # expect(persona.nombre).to be_a_kind_of(String)
    # end
  end
end