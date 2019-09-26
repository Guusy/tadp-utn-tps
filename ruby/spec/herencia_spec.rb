describe 'Herencia' do
  after do
    TADB::DB.clear_all
  end
  context 'cuando se quiere persistir una clase que incluye un modulo' do
    before do
      module PatitoNoPersistible
        include Orm
        has_one String, named: :color
      end
      class PatitoChico
        include Orm
        include PatitoNoPersistible
        has_one String, named: :tamanio
      end

      @patito_rojo = PatitoChico.new
      @patito_rojo.color = "rojo"
      @patito_rojo.tamanio = "chico"
      @patito_rojo.save!
    end

    it 'se guardan todos los atributos en el objeto' do
      expect(@patito_rojo.color).to eq("rojo")
      expect(@patito_rojo.tamanio).to eq("chico")
    end
    it 'se guardan todos los atributos en el mismo registro de la base de datos' do
      patito_rojo_db = find_by_id("patitochico", @patito_rojo.id)
      expect(patito_rojo_db[:color]).to eq("rojo")
      expect(patito_rojo_db[:tamanio]).to eq("chico")
    end
  end
end