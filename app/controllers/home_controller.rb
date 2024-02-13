class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @url = params[:url]
    if @url.present?
      begin
        @scraper = scrape
      rescue StandardError => e
        flash.now[:alert] = "Failed to retrieve data from the URL: #{e.message}"
      end
    else
      flash.now[:alert] = "Please enter a URL"
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
