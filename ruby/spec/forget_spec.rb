describe 'forget' do
  before do
    TADB::DB.clear_all
    class Patito
      include Orm
    end
  end

  context 'cuando se hace forget sobre un objeto no persistido' do
    before do
      @patito_no_persistible = Patito.new
    end
    it 'falla con un error "Este objeto no esta persistido"' do
      expect { @patito_no_persistible.forget! }.to raise_exception("Este objeto no esta persistido")
    end
  end

end