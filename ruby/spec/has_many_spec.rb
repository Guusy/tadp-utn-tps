describe 'has_many' do
  after do
    TADB::DB.clear_all
  end

  context 'cuando se le declara un has_many a una clase' do
    before do
      class Lenguaje
        include Persistible
      end
      class IDE
        include Persistible
        has_many Lenguaje, named: :lenguajes
      end
      @rubymine = IDE.new
    end
      it 'se le agrega el atributo como []' do
        expect(@rubymine.lenguajes).to match_array([])
      end
  end
end