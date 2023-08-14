# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'
require 'date'
require 'json'
require 'open-uri'

# Link to the National Bank of Georgia's API in English
URL = 'https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies/en/json'

# List of currencies _BOTH_ available to run business in BoG and with the known exchange rate from NBG API
CURRENCIES = %w[AED AMD AUD AZN BYN CAD CHF CNY DKK EUR GBP ILS INR JPY KZT NOK QAR SEK TRY UAH USD UZS].freeze
# List of currencies with the known exchange rate from NBG API but _NOT_ available to run business in BoG
NBG_CURRENCIES = %w[BGN BRL CZK EGP HKD HUF IRR ISK KGS KRW KWD MDL NZD PLN RON RSD RUB SGD TJS TMT ZAR].freeze
# List of currencies available to run business in BoG but with _NOT_ available exchange rate from NBG API
BOG_CURRENCIES = %w[BHD IDR JOD LBP MAD MXN MYR PHP PKR RUR SAR THB VND].freeze
# TODO: Add info from TBC, Liberty, Basisbank, as well as from Wise Business and Revolut Business

class Lariconv
  class InvalidAmountException < StandardError; end

  class UnavailableCurrencyException < StandardError; end

  def self.convert(...)
    new(...).convert
  end

  def initialize(amount:, currency:, date: nil)
    @amount = amount
    @currency = currency.upcase
    @date = date
  end

  # @param amount [Integer, Float, BigDecimal] Amount of money to convert
  # @param currency [String] Currency to convert to Lari from
  # @param date [String] Date to get the exchange rate for (default: today)
  # @return [BigDecimal] Converted amount of money
  def convert
    quantity, rate = fetch_currency_data
    result = (amount / quantity) * rate
    result.round(2)
  end

  def amount
    raise InvalidAmountException unless [Integer, Float, BigDecimal].include? @amount.class

    @amount.to_d
  end

  def currency
    raise UnavailableCurrencyException unless CURRENCIES.include? @currency

    @currency
  end

  def date
    @date ||= parse_date
  end

  private

  def parse_date
    Date.parse @date
  rescue StandardError
    Date.today
  end

  def fetch_currency_data
    response = JSON.parse URI.parse(currency_url).read
    data = response.first['currencies'].first
    [data['quantity'].to_d, data['rate'].to_d]
  end

  def currency_url
    "#{URL}?currencies=#{currency}&date=#{date}"
  end
end
