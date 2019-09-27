describe 'has_many' do
  after do
    TADB::DB.clear_all
  end

  context 'cuando se le declara un has_many a una clase' do
    before do
      class Lenguaje
        include Orm
      end
      class IDE
        include Orm
        has_many Lenguaje, named: :lenguajes
      end
      @rubymine = IDE.new
    end
    it 'se le agrega el atributo como []' do # TODO:  arreglar este test, ver como hacer para tener un valor por default
      expect(@rubymine.lenguajes).to match_array([])
    end
  end
end