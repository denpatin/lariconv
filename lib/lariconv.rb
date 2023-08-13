# frozen_string_literal: true

require 'json'
require 'open-uri'

URL = 'https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies/en/json'

class Lariconv
  def self.convert(amount, currency, date)
    url = "#{URL}?currencies=#{currency}&date=#{date}"
    response = JSON.parse(URI.parse(url).read)
    data = response.first['currencies'].first
    quantity = data['quantity']
    rate = data['rate']
    result = amount.to_f / quantity * rate
    result.round(2)
  end
end
