require 'httparty'
require "nokogiri"

class Scraper
def initialize(url)
  @url = url
end

def scrape
 headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
    'accept-encoding': 'gzip, deflate, br',
    'accept-language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8,en-US;q=0.7,en;q=0.6,ja;q=0.5',
    'cache-control': 'max-age=0',
    'cookie': 'cna=6B2NFMQceWkCATy/9iZmJ/r2; ali_ab=60.191.246.38.1543910908671.4; lid=%E4%B9%89%E4%B9%8C2010; __last_userid__=375685501; hng=CN%7Czh-CN%7CCNY%7C156; UM_distinctid=16b40021a50161-08fe1f8fb068e8-37657e03-1fa400-16b40021a51abb; ali_apache_id=11.15.106.128.1564454978766.321081.5; h_keys="%u7537%u68c9%u670d#%u73a9%u5177#%u4e49%u4e4c%u5e02%u4e00%u6db5%u5236%u7ebf#%u91d1%u5b9d%u8d1d#%u4e00%u6db5%u5236%u7ebf#2017%u5723%u8bde%u9996%u9970#%u5723%u8bde%u9996%u9970#%u9996%u9970#%u7ea2%u85af#%u4e49%u4e4c%u817e%u535a%u793c%u54c1"; ad_prefer="2019/08/08 09:38:58"; ali_beacon_id=60.191.246.38.1566810215744.002451.6; ali_apache_track=c_mid=b2b-375685501ncisr|c_lid=%E4%B9%89%E4%B9%8C2010|c_ms=1|c_mt=2; taklid=9d140935ba3b4a8f9c20e255b4a99dd0; _csrf_token=1569548292989; cookie2=11e8d4b69091a1157b038c714385c9a6; t=4c47e32627e4d9d5c08008789ed65a34; _tb_token_=ab7d81831375; uc4=id4=0%40UgDLKslxx%2F5KKbIzCKEbS9CpADM%3D&nk4=0%40s5u8VZNrKh1Ipk4a6%2FKiHZj80A%3D%3D; __cn_logon__=false; alicnweb=homeIdttS%3D99025414611281355176293308315884802540%7Ctouch_tb_at%3D1569548305483%7ChomeIdttSAction%3Dtrue%7Clastlogonid%3D%25E4%25B9%2589%25E4%25B9%258C2010%7Cshow_inter_tips%3Dfalse; l=cBMFFQcuvPgtaQebKOfalurza77T5IRb4sPzaNbMiICP_j1y5CQAWZCBm382CnGVp626R3zP_tquBeYBc1bnLjDSik2H9; isg=BNTUjkpcdQqEKuDNKwS17J7fpRRMK8akMa0MD261lt_jWXSjlj_fp6CTWRHkoTBv',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
  }


 response = HTTParty.get(@url, headers: headers)
 doc = Nokogiri::HTML.parse(response.body)
 {
  image: scrape_image(doc),
  title: translate(scrape_title(doc)),
  description: translate(scrape_description(doc)),
  min_price: scrape_min_price(doc),
  max_price: scrape_max_price(doc),
  amount: translate(scrape_amount(doc))
}
end

private

 def scrape_title(doc)
  doc.css('.title-text').text
 end

 def scrape_description(doc)
  doc.at_css('meta[name="description"]')['content']
 end

 def scrape_image(doc)
  doc.at_css('img.J_ImageFirstRender')['src']
end

def scrape_min_price(doc)
  res = doc.at_css('.detail-price-item[data-common-price-item="Y"] .price-num[data-min-price]').content
  convert_currency(res.to_i).round(2)
end

def scrape_max_price(doc)
  res = doc.at_css('.detail-price-item[data-common-price-item="Y"] .price-num[data-max-price]').content
  convert_currency(res.to_i).round(2)
end

def scrape_amount(doc)
  doc.at_css('.price-begin-amount .beigin-text').text.strip
end

def translate(text)
  EasyTranslate.api_key = ENV['GOOGLE_TRANSLATE_API_KEY']

  EasyTranslate.translate(text, to: :uk)
end

def find_currency_rate(rates, currency_code_a, currency_code_b)
  rates.find { |rate| rate['currencyCodeA'] == currency_code_a && rate['currencyCodeB'] == currency_code_b }
end

def convert_currency(amount_in_cny)
  url = 'https://api.monobank.ua/bank/currency'
  response = HTTParty.get(url)
  if response.code == 200
    rate = find_currency_rate(response.parsed_response, 156, 980)
      amount_in_uah = amount_in_cny * rate['rateCross']
  else
    amount_in_uah = amount_in_cny
  end
end
end
