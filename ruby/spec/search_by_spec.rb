require 'rspec'

describe 'search_by' do
  before do
    class Persona
      include Orm
      has_one String, named: :nombre
      has_one String, named: :apellido
      has_one Numeric, named: :edad

      def es_mayor
        @edad > 18
      end

      def saludar(persona)
        puts "hola #{persona}"
      end
    end
  end

  after do
    TADB::DB.clear_all
  end

  context 'cuando se busca por una condicion que no cumple con ningun regitro de la base' do
    it 'devuelve un array vacio' do
      resultado = Persona.search_by_nombre("Alfredo Polizol")
      expect(resultado).to match_array([])
    end
  end

  context 'se busca por una condicion sobre un atributo y cumple con algun registro de la base' do
    before do
      @martin = Persona.new
      @martin.nombre = "Martin Gonzalez"
      @martin.save!
      @gonza = Persona.new
      @gonza.nombre = "Gonzalo gras cantou"
      @gonza.save!
    end
    it 'se devuelven esos valores' do
      resultado = Persona.search_by_nombre("Martin Gonzalez")
      expect(resultado.size).to eq(1)
      expect(resultado[0].id).to eq(@martin.id )
    end
  end

end