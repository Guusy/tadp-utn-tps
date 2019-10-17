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
      context 'y se setea el atributo como nil' do
        before do
          @sin_nombre.nombre = nil
        end
        context 'y lo persistimos' do
          before do
            @sin_nombre.save!
          end
          it 'se guarda en la DB con el valor default' do
            hotel_db = find_by_id('hotel', @sin_nombre.id)
            expect(hotel_db[:nombre]).to eq("sin nombre")
          end
        end
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
  context 'cuando se declara el default sobre un atributo en un has_many' do
    context "y se le pasa un valor invalido" do
      it 'falla' do
        expect{
          class UnaClaseInvalida
            include Orm
            has_many Material, named: :empleados, default: "soy re invalido"
          end
        }.to raise_error("El valor del default no es valido")
      end
    end
    context 'y se le pasa un valor valido' do
      context 'y se instancia el objeto' do
        before do
          class Empleado
            include Orm
            has_one String, named: :puesto
          end
          class Oficina
            include Orm
            has_many Empleado, named: :empleados, default: [Empleado.new]
          end
          @con_cadete = Oficina.new
        end
        it 'se le pone el valor default en el atributo' do
          empleado = @con_cadete.empleados[0]
          expect(empleado.is_a?(Empleado)).to be(true)
        end
        context 'y al guardar en la base de datos' do
          before do
            @con_cadete.save!
          end
          it 'se persiste ese valor' do
            relacion_oficina_empleado_db = get_relaciones('oficina_empleado', :id_oficina, @con_cadete.id)
            expect(relacion_oficina_empleado_db[0][:id_empleado]).not_to be(nil)
          end
        end
        context 'y se setea el atributo como nil' do
          before do
            @sin_cadete = Oficina.new
            @sin_cadete.empleados = nil
          end
          context 'y lo persistimos' do
            before do
              @sin_cadete.save!
            end
            it 'se guarda en la DB con el valor default' do
              relacion_oficina_empleado_db = get_relaciones('oficina_empleado', :id_oficina, @sin_cadete.id)
              expect(relacion_oficina_empleado_db[0][:id_empleado]).not_to be(nil)
            end
          end
        end
      end
    end
  end


end