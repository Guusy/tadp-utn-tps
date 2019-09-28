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

  context 'cuando se persiste una clase que hereda otra' do
    before do
      class Consola
        include Orm
        has_one String, named: :origen
      end

      class Ps4 < Consola
        include Orm
        has_one String, named: :compania
      end

      @ps4 = Ps4.new
      @ps4.compania = "sony"
      @ps4.origen = "china"
      @ps4.save!
    end

    it 'se guardan todos los atributos en el objeto' do
      expect(@ps4.compania).to eq("sony")
      expect(@ps4.origen).to eq("china")
    end
    it 'se guardan todos los atributos en el mismo registro de la base de datos' do
      ps4_db = find_by_id("ps4", @ps4.id)
      expect(ps4_db[:compania]).to eq("sony")
      expect(ps4_db[:origen]).to eq("china")
    end
    context 'y una property de la subclase pisa una de super clase' do
      before do
        class Xbox < Consola
          include Orm
          has_one Numeric, named: :origen
        end
        @xbox = Xbox.new
        @xbox.origen = 1235
        @xbox.save!
      end
      it 'se guardan todos los atributos en el mismo registro de la base de datos' do
        xbox_db = find_by_id("xbox", @xbox.id)
        expect(xbox_db[:origen]).to eq(1235)
      end
    end
  end
end