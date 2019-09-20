describe 'all_instances' do
  before do
    class Computadora
      include Orm
    end
  end

  after do
    TADB::DB.clear_all
  end

  context 'cuando no hay ningun registro cargado' do
    it 'y pedimos all_instances, nos devuelve un array vacio' do
      computadora = Computadora.new
      expect(computadora.all_instances).to match_array([])
    end
  end

  context "cuando hay registros en la DB" do
    before do
      @computadora_1 = Computadora.new
      @computadora_1.save!
      @computadora_2 = Computadora.new
      @computadora_2.save!
      @computadora_3 = Computadora.new
      @computadora_3.save!
      @all_instances = @computadora_1.all_instances

    end
    it 'y pedimos all_instances, nos devuelve los objetos de dominio ' do
      expect(@all_instances[0].id).to eq(@computadora_1.id)
      expect(@all_instances[1].id).to eq(@computadora_2.id)
      expect(@all_instances[2].id).to eq(@computadora_3.id)
    end
  end


end