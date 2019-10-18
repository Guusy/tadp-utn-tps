describe 'forget' do
  before do
    class Patito
      include Orm
      has_one String, named: :nombre
    end
  end
  after do
    TADB::DB.clear_all
  end
  context 'cuando se hace forget sobre un objeto no persistido' do
    before do
      @patito_no_persistible = Patito.new
    end
    it 'falla con un error "Este objeto no esta persistido"' do
      expect { @patito_no_persistible.forget! }.to raise_exception("Este objeto no esta persistido")
    end
  end

  context 'cuando se hace forget sobre un objeto  persistido' do
    before do
      @patito_persistible = Patito.new
      @patito_persistible.save!
      @temporal_id = @patito_persistible.id;
      @patito_persistible.forget!
    end

    it 'se le asigna nil a su id' do
      expect(@patito_persistible.id).to eq(nil)
    end

    it 'se borra de la base de datos' do
      patito_db = find_by_id('patito', @temporal_id)
      expect(patito_db).to eq(nil)
    end

  end

end