class HomeController < ApplicationController
  before_action :authenticate_user!
  prepend_before_action :check_url_presence, only: [:index]

  def index
    @url = params[:url]
    @scraper = scrape
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

  def check_url_presence
    unless params[:url].present?
      render :index, status: :unprocessable_entity, alert: "URL can't be blank"
    end
  end
end
