require 'rspec'

describe 'search_by' do
  before do
    class Persona
      include Persistible
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
  context 'cuando se ejecuta el metodo respond_to de un search_by_ARGUMENTO' do
    it 'responde correctamente' do
      expect(Persona.respond_to?(:search_by_nombre)).to eq(true)
    end
  end

  context 'cuando se ejecuta el metodo respond_to de un metodo que no entiendo o que no sea search_by_ARGUMENTO' do
    it 'responde correctamente' do
      expect(Persona.respond_to?(:metodoooooo)).to eq(false)
    end
  end

  context 'cuando se busca por una condicion que no cumple con ningun regitro de la base' do
    it 'devuelve un array vacio' do
      resultado = Persona.search_by_nombre("Alfredo Polizol")
      expect(resultado).to match_array([])
    end
  end

  context 'se busca por una condicion sobre un metodo con argumentos ' do
    it 'y falla con "No se puede utilizar una propiedad que reciba argumentos"' do
      expect { Persona.search_by_saludar }.to raise_exception("No se puede utilizar una propiedad que reciba argumentos")
    end
  end

  context 'se busca por una condicion sobre un metodo sin argumentos, pasandole el resultado esperado' do
    before do
      @martin = Persona.new
      @martin.edad = 24
      @martin.save!
      @gonza = Persona.new
      @gonza.edad = 12
      @gonza.save!
    end

    it 'devuelve los resultados que matchean con esa busqueda' do
      resultado = Persona.search_by_es_mayor(true)
      expect(resultado.size).to eq(1)
      expect(resultado[0].id).to eq(@martin.id)
      resultado_false = Persona.search_by_es_mayor(false)
      expect(resultado_false.size).to eq(1)
      expect(resultado_false[0].id).to eq(@gonza.id)
    end
  end

  context 'se busca por una condicion sobre un atributo y cumple con algun registro de la base' do
    context 'y todos sus atributos son primitivos' do
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
        expect(resultado[0].id).to eq(@martin.id)
      end
    end
    context 'y algun atributo hace referencia a otra entidad' do

      context 'y se tiene una dependencia simple' do
        before do
          class Mascota
            include Persistible
            has_one String, named: :tipo
          end
          class Persona
            has_one Mascota, named: :mascota
          end

          @perro = Mascota.new
          @perro.tipo = "perro"
          @perro.save!
          @gonza = Persona.new
          @gonza.nombre = "Gonzalo gras cantou"
          @gonza.mascota = @perro
          @gonza.save!
        end

        it 'tiene que mapear correctamente esa entidad' do
          resultado = Persona.search_by_nombre("Gonzalo gras cantou")
          mascota = resultado[0].mascota
          expect(mascota.id).to eq(@perro.id)
          expect(mascota.tipo).to eq(@perro.tipo)
        end
      end
      context "con una dependencia compuesta A -> B -> C" do
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

        it 'se mapean correctamente las entidades' do
          obrero_db = Obrero.search_by_nombre("pepe")[0]
          expect(obrero_db.herramienta.material.id).to eq(@acero.id)
          expect(obrero_db.herramienta.material.peso).to eq("200")
        end
      end

    end

  end

  context 'cuando se busca sobre un modulo el cual es incluido por otras clases' do
    before do
      module Instrumento
        include Persistible
        has_one String, named: :material
      end
      class Guitarra
        include Persistible
        include Instrumento
        has_one Numeric, named: :cantidad_cuerdas
      end
      @guitarra = Guitarra.new
      @guitarra.material = "madera"
      @guitarra.cantidad_cuerdas = 6
      @guitarra.save!
    end

    context 'y todas las partes entienden el mensaje' do
      it 'debe devolver los objetos que cumplan la condicion' do
        resultado = Instrumento.search_by_material("madera")
        expect(resultado.size).to eq(1)
        expect(resultado[0].id).to eq(@guitarra.id)
      end
    end
  end

  context 'cuando se busca en una clase la cual es heredada por otras' do
    before do
      class Teclado
        include Persistible
        has_one Numeric, named: :cantidad_teclas
      end
      class TecladoMecanico < Teclado
        include Persistible
        has_one Numeric, named: :teclas_extras
      end
    end
    context 'y NO todas las partes entienden el mensaje' do
      it 'se debe lanzar un error "No todos entienden [NOMBRE_MENSAJE] !"' do
        expect { Teclado.search_by_teclas_extras(12) }.to raise_error("No todos entienden teclas_extras !")
      end
    end

    context 'y todas las partes entienden el mensaje' do
      before do
        @teclado_noga = Teclado.new
        @teclado_noga.cantidad_teclas = 60
        @teclado_noga.save!
        @razer = TecladoMecanico.new
        @razer.teclas_extras = 20
        @razer.cantidad_teclas = 60
        @razer.save!
      end
      it 'se devuelve todas las entidades que matchean con la busqueda' do
        teclado_find_by = Teclado.search_by_cantidad_teclas(60)
        teclado_noga = teclado_find_by[0]
        teclado_razer = teclado_find_by[1]

        expect(teclado_noga.id).to eq @teclado_noga.id
        expect(teclado_noga.cantidad_teclas).to eq @teclado_noga.cantidad_teclas
        expect(teclado_razer.id).to eq @razer.id
        expect(teclado_razer.cantidad_teclas).to eq @razer.cantidad_teclas
      end
    end
  end
end