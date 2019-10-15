# guarda el valor en por default en la base de datos
# si le pasa un default que no es un array a has_many ERROR
describe 'default values' do
  after do
    TADB::DB.clear_all
  end

  context 'cuando se declara el default sobre un atributo en un has_one' do
    context 'y se instancia el objeto' do
      before do
        class Hotel
          include Orm
          has_one String, named: :nombre, default: "sin nombre"
        end
        @sin_nombre = Hotel.new
      end
      it 'se le pone el valor default en el atributo' do
        expect(@sin_nombre.nombre).to eq("sin nombre")
      end
      context 'y al guardar en la base de datos' do
        before do
          @sin_nombre.save!
        end

        it 'se persiste ese valor' do
          hotel_db = find_by_id('hotel', @sin_nombre.id)
          expect(hotel_db[:nombre]).to eq(@sin_nombre.nombre)
        end
      end
    end
  end


end