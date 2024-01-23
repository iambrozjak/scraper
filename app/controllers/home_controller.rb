class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @url = params[:url]
    @scraper = scrape if @url.present?
  end

  private

  def scrape
    scraper = Scraper.new(@url)
    scraper.scrape
  end
end
