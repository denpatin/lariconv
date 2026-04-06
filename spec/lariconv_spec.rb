# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'

RSpec.describe Lariconv do
  describe '.convert' do
    context 'with valid Integer amount' do
      it 'converts USD to GEL' do
        stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        result = described_class.convert(amount: 100, currency: 'USD', date: '2025-01-15')

        expect(result).to eq BigDecimal('284.48')
      end
    end

    context 'with valid Float amount' do
      it 'converts EUR to GEL' do
        stub_nbg_api(nbg_api_response(code: 'EUR', quantity: 1, rate: 2.9200))

        result = described_class.convert(amount: 50.5, currency: 'EUR', date: '2025-01-15')

        expect(result).to eq BigDecimal('147.46')
      end
    end

    context 'with valid BigDecimal amount' do
      it 'converts GBP to GEL' do
        stub_nbg_api(nbg_api_response(code: 'GBP', quantity: 1, rate: 3.4900))

        result = described_class.convert(amount: BigDecimal('100.68'), currency: 'GBP', date: '2025-01-15')

        expect(result).to eq BigDecimal('351.37')
      end
    end

    context 'with currency that has quantity > 1' do
      it 'correctly divides by quantity for JPY' do
        stub_nbg_api(nbg_api_response(code: 'JPY', quantity: 100, rate: 1.8013))

        result = described_class.convert(amount: 1000, currency: 'JPY', date: '2025-01-15')

        # (1000 / 100) * 1.8013 = 18.013 → 18.01
        expect(result).to eq BigDecimal('18.01')
      end

      it 'handles fractional amounts with quantity > 1' do
        stub_nbg_api(nbg_api_response(code: 'JPY', quantity: 100, rate: 1.8013))

        result = described_class.convert(amount: 250, currency: 'JPY', date: '2025-01-15')

        # (250 / 100) * 1.8013 = 4.50325 → 4.50
        expect(result).to eq BigDecimal('4.50')
      end
    end

    context 'with zero amount' do
      it 'returns zero' do
        stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        result = described_class.convert(amount: 0, currency: 'USD', date: '2025-01-15')

        expect(result).to eq BigDecimal('0')
      end
    end

    context 'with negative amount' do
      it 'returns negative result' do
        stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        result = described_class.convert(amount: -50, currency: 'USD', date: '2025-01-15')

        expect(result).to eq BigDecimal('-142.24')
      end
    end

    context 'with very large amount' do
      it 'handles large numbers correctly' do
        stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        result = described_class.convert(amount: 1_000_000, currency: 'USD', date: '2025-01-15')

        expect(result).to eq BigDecimal('2844800.0')
      end
    end

    context 'with very small amount' do
      it 'handles very small numbers with rounding' do
        stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        result = described_class.convert(amount: 0.01, currency: 'USD', date: '2025-01-15')

        expect(result).to eq BigDecimal('0.03')
      end
    end

    it 'returns a BigDecimal' do
      stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

      result = described_class.convert(amount: 100, currency: 'USD', date: '2025-01-15')

      expect(result).to be_a BigDecimal
    end

    it 'rounds result to 2 decimal places' do
      stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

      result = described_class.convert(amount: 33, currency: 'USD', date: '2025-01-15')

      # 33 * 2.8448 = 93.8784 → 93.88
      expect(result).to eq BigDecimal('93.88')
    end
  end

  describe 'currency validation' do
    before do
      stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))
    end

    context 'with a valid currency' do
      CURRENCIES.each do |cur|
        it "accepts #{cur}" do
          expect { described_class.new(amount: 1, currency: cur).currency }.not_to raise_error
        end
      end
    end

    context 'with lowercase currency' do
      it 'upcases and accepts it' do
        converter = described_class.new(amount: 100, currency: 'usd', date: '2025-01-15')
        expect(converter.currency).to eq 'USD'
      end
    end

    context 'with mixed case currency' do
      it 'upcases and accepts it' do
        converter = described_class.new(amount: 100, currency: 'Eur', date: '2025-01-15')
        expect(converter.currency).to eq 'EUR'
      end
    end

    context 'with an unavailable currency' do
      it 'raises UnavailableCurrencyException for unknown code' do
        expect {
          described_class.convert(amount: 100, currency: 'WTF', date: '2025-01-15')
        }.to raise_error(Lariconv::UnavailableCurrencyException)
      end

      it 'raises UnavailableCurrencyException for NBG-only currencies' do
        NBG_CURRENCIES.each do |cur|
          expect {
            described_class.new(amount: 1, currency: cur).currency
          }.to raise_error(Lariconv::UnavailableCurrencyException)
        end
      end

      it 'raises UnavailableCurrencyException for BOG-only currencies' do
        BOG_CURRENCIES.each do |cur|
          expect {
            described_class.new(amount: 1, currency: cur).currency
          }.to raise_error(Lariconv::UnavailableCurrencyException)
        end
      end

      it 'raises UnavailableCurrencyException for empty string' do
        expect {
          described_class.convert(amount: 100, currency: '', date: '2025-01-15')
        }.to raise_error(Lariconv::UnavailableCurrencyException)
      end

      it 'raises UnavailableCurrencyException for GEL (Lari itself)' do
        expect {
          described_class.convert(amount: 100, currency: 'GEL', date: '2025-01-15')
        }.to raise_error(Lariconv::UnavailableCurrencyException)
      end
    end
  end

  describe 'amount validation' do
    before do
      stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))
    end

    context 'with invalid amount' do
      it 'raises InvalidAmountException for String' do
        expect {
          described_class.convert(amount: 'abc', currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end

      it 'raises InvalidAmountException for nil' do
        expect {
          described_class.convert(amount: nil, currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end

      it 'raises InvalidAmountException for Array' do
        expect {
          described_class.convert(amount: [100], currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end

      it 'raises InvalidAmountException for Hash' do
        expect {
          described_class.convert(amount: { value: 100 }, currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end

      it 'raises InvalidAmountException for Symbol' do
        expect {
          described_class.convert(amount: :hundred, currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end

      it 'raises InvalidAmountException for boolean true' do
        expect {
          described_class.convert(amount: true, currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end

      it 'raises InvalidAmountException for Rational' do
        expect {
          described_class.convert(amount: Rational(1, 3), currency: 'USD', date: '2025-01-15')
        }.to raise_error(Lariconv::InvalidAmountException)
      end
    end
  end

  describe 'date handling' do
    context 'with no date provided' do
      it 'defaults to today and converts successfully' do
        stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        result = described_class.convert(amount: 100, currency: 'USD')

        expect(result).to eq BigDecimal('284.48')
      end

      it 'uses Date.today as the date' do
        converter = described_class.new(amount: 100, currency: 'USD')
        expect(converter.date).to eq Date.today
      end
    end

    context 'with a valid date string' do
      it 'uses the provided date' do
        converter = described_class.new(amount: 100, currency: 'USD', date: '2025-01-15')
        expect(converter.date).to eq '2025-01-15'
      end
    end

    context 'with an invalid date string' do
      it 'passes the string to the API as-is' do
        uri_double = stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

        described_class.convert(amount: 100, currency: 'USD', date: 'not-a-date')

        expect(URI).to have_received(:parse).with(/date=not-a-date/)
      end
    end
  end

  describe '#amount' do
    it 'converts Integer to BigDecimal' do
      converter = described_class.new(amount: 42, currency: 'USD')
      expect(converter.amount).to eq BigDecimal('42')
      expect(converter.amount).to be_a BigDecimal
    end

    it 'converts Float to BigDecimal' do
      converter = described_class.new(amount: 3.14, currency: 'USD')
      expect(converter.amount).to be_a BigDecimal
    end

    it 'keeps BigDecimal as BigDecimal' do
      converter = described_class.new(amount: BigDecimal('99.99'), currency: 'USD')
      expect(converter.amount).to eq BigDecimal('99.99')
    end
  end

  describe '#currency' do
    it 'returns the uppercased currency code' do
      converter = described_class.new(amount: 1, currency: 'eur')
      expect(converter.currency).to eq 'EUR'
    end
  end

  describe 'API interaction' do
    it 'calls the correct NBG API URL' do
      uri_double = stub_nbg_api(nbg_api_response(code: 'EUR', quantity: 1, rate: 2.92))

      described_class.convert(amount: 100, currency: 'EUR', date: '2025-01-15')

      expected_url = 'https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies/en/json?currencies=EUR&date=2025-01-15'
      expect(URI).to have_received(:parse).with(expected_url)
    end

    it 'raises an error when the API is unreachable' do
      uri_double = instance_double(URI::HTTPS)
      allow(URI).to receive(:parse).and_call_original
      allow(URI).to receive(:parse).with(/nbg\.gov\.ge/).and_return(uri_double)
      allow(uri_double).to receive(:read).and_raise(Errno::ECONNREFUSED)

      expect {
        described_class.convert(amount: 100, currency: 'USD', date: '2025-01-15')
      }.to raise_error(Errno::ECONNREFUSED)
    end

    it 'raises an error on HTTP 404' do
      uri_double = instance_double(URI::HTTPS)
      allow(URI).to receive(:parse).and_call_original
      allow(URI).to receive(:parse).with(/nbg\.gov\.ge/).and_return(uri_double)
      allow(uri_double).to receive(:read).and_raise(OpenURI::HTTPError.new('404 Not Found', StringIO.new))

      expect {
        described_class.convert(amount: 100, currency: 'USD', date: '2025-01-15')
      }.to raise_error(OpenURI::HTTPError)
    end

    it 'raises an error on invalid JSON response' do
      uri_double = instance_double(URI::HTTPS)
      allow(URI).to receive(:parse).and_call_original
      allow(URI).to receive(:parse).with(/nbg\.gov\.ge/).and_return(uri_double)
      allow(uri_double).to receive(:read).and_return('not valid json')

      expect {
        described_class.convert(amount: 100, currency: 'USD', date: '2025-01-15')
      }.to raise_error(JSON::ParserError)
    end
  end

  describe 'constants' do
    it 'defines CURRENCIES as a frozen array of strings' do
      expect(CURRENCIES).to be_frozen
      expect(CURRENCIES).to all(be_a(String))
    end

    it 'includes common currencies in CURRENCIES' do
      %w[USD EUR GBP CHF JPY].each do |cur|
        expect(CURRENCIES).to include(cur)
      end
    end

    it 'does not overlap CURRENCIES with NBG_CURRENCIES' do
      overlap = CURRENCIES & NBG_CURRENCIES
      expect(overlap).to be_empty
    end

    it 'does not overlap CURRENCIES with BOG_CURRENCIES' do
      overlap = CURRENCIES & BOG_CURRENCIES
      expect(overlap).to be_empty
    end

    it 'has a valid API URL' do
      expect(URL).to start_with('https://nbg.gov.ge/')
    end
  end

  describe 'class-level .convert shorthand' do
    it 'delegates to instance #convert' do
      stub_nbg_api(nbg_api_response(code: 'USD', quantity: 1, rate: 2.8448))

      class_result = described_class.convert(amount: 100, currency: 'USD', date: '2025-01-15')
      expect(class_result).to eq BigDecimal('284.48')
    end
  end

  describe 'exception classes' do
    it 'InvalidAmountException inherits from StandardError' do
      expect(Lariconv::InvalidAmountException).to be < StandardError
    end

    it 'UnavailableCurrencyException inherits from StandardError' do
      expect(Lariconv::UnavailableCurrencyException).to be < StandardError
    end
  end
end
