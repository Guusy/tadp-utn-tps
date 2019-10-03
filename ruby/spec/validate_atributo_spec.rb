describe 'validate_atributo' do
  after do
    TADB::DB.clear_all
  end
  # TODO : preguntar que pasa si se ejecuta sobre un primitivo ?
  # TODO : preguntar que pasa si lo que se pasa no es un  valor valido ? aplica para validate y no_blank
  # ser amigable
  context 'cuando se pasa un proc' do
    context 'y se declara sobre un has_one' do
      before do
        class Pizarra
          include Orm
          has_one Numeric, named: :antiguedad, validate: proc { |x| x > 18 }
        end
      end
      context 'y se le setea un valor que NO cumple la condicion' do
        before do
          @pizarra_joven = Pizarra.new
          @pizarra_joven.antiguedad = 2
        end

        it 'falla al querer guardarla' do
          expect{@pizarra_joven.save!}.to raise_error "El atributo antiguedad no cumple la validacion"
        end
      end
    end
  end
end