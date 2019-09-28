describe 'no_blank' do
  after do
    TADB::DB.clear_all
  end

  context 'cuando se especifica el valor como true' do
    context 'y tiene un atributo Boolean vacio y se trata de persistir' do
      before do
        class Auto
          include Orm
          has_one Boolean, named: :esta_chocado, no_blank: true
        end
        @auto = Auto.new
      end
      it 'falla "El atributo [ATRIBUTO] esta vacio!"' do
        expect { @auto.save! }.to raise_error("El atributo esta_chocado esta vacio!")
      end
    end

    context 'y tiene un atributo String vacio y se trata de persistir' do
      before do
        class Piramide
          include Orm
          has_one String, named: :nombre, no_blank: true
        end
        @piramide = Piramide.new
        @piramide.nombre = ""
      end
      it 'falla "El atributo [ATRIBUTO] esta vacio!"' do
        expect { @piramide.save! }.to raise_error("El atributo nombre esta vacio!")
      end
    end

    context 'y tiene un atributo que hace referencia a otra entidad y se trata de persistir' do
      before do
        class Plantilla
          include Orm
        end
        class Zapatilla
          include Orm
          has_one Plantilla, named: :plantilla, no_blank: true
        end
        @zapatilla = Zapatilla.new
      end

      it 'falla "El atributo [ATRIBUTO] esta vacio!"' do
        expect { @zapatilla.save! }.to raise_error("El atributo plantilla esta vacio!")
      end
    end
  end

  # TODO: preguntar que onda con los arrays vacios ?
end