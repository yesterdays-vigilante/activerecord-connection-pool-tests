class HomeController < ApplicationController
  def index
    5.times do
      @cheese = Cheese.all.sample
    end

    5.times do
      @camelid = Camelid.all.sample
    end
  end

  def db_wait
    @cheese = Cheese.slow_all(params[:time]).sample
    @camelid = Camelid.slow_all(params[:time]).sample

    render 'index'
  end

  def app_wait
    5.times do
      @cheese = Cheese.all.sample
    end

    sleep params[:time].to_f

    5.times do
      @camelid = Camelid.all.sample
    end

    sleep params[:time].to_f

    render 'index'
  end
end
