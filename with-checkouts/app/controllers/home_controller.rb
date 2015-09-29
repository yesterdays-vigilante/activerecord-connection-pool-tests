class HomeController < ApplicationController
  def index
    5.times do
      ActiveRecord::Base.connection_pool.with_connection do
        @cheese_name = Cheese.all.sample.name
      end
    end

    5.times do
      ActiveRecord::Base.connection_pool.with_connection do
        @camelid_name = Camelid.all.sample.name
      end
    end
  end

  def db_wait
    ActiveRecord::Base.connection_pool.with_connection do
      @cheese_name = Cheese.slow_all(params[:time]).sample.name
    end

    ActiveRecord::Base.connection_pool.with_connection do
      @camelid_name = Camelid.slow_all(params[:time]).sample.name
    end

    render 'index'
  end

  def app_wait
    5.times do
      ActiveRecord::Base.connection_pool.with_connection do
        @cheese_name = Cheese.all.sample.name
      end
    end

    sleep(params[:time].to_f)

    5.times do
      ActiveRecord::Base.connection_pool.with_connection do
        @camelid_name = Camelid.all.sample.name
      end
    end

    sleep(params[:time].to_f)

    render 'index'
  end
end
