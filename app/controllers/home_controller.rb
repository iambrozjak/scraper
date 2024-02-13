class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @url = params[:url]
    if @url.present?
      @scraper = scrape
    else
      render :index, status: :unprocessable_entity, alert: "Введіть URL"
    end
  end

  private

  def scrape
    scraper = Scraper.new(@url)
    scraper.scrape
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to continue"
    end
  end

end
