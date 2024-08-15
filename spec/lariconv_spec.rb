# frozen_string_literal: true

require 'spec_helper'
require 'timecop'
require_relative '../lib/lariconv'

RSpec.describe Lariconv do
  describe '.convert' do
    context 'when converting amount with currency and date' do
      it 'returns a BigDecimal' do
        result = Lariconv.convert(amount: 1000, currency: 'GBP', date: '2022-08-15')
        expect(result).to be_a(BigDecimal)
        expect(result).to eq(BigDecimal('0.32829e4'))
      end
    end

    context 'when converting amount as BigDecimal with currency' do
      it 'returns a BigDecimal' do
        Timecop.freeze(Time.parse('2024-08-16')) do
          result = Lariconv.convert(amount: BigDecimal('100.68'), currency: 'EUR')
          expect(result).to be_a(BigDecimal)
          expect(result).to eq(BigDecimal('0.2985e3'))
        end
      end
    end

    context 'when converting amount with currency to a float' do
      it 'returns a Float' do
        result = Lariconv.convert(amount: 1.5, currency: 'USD', date: '2023-08-15').to_f
        expect(result).to be_a(Float)
        expect(result).to eq(3.93)
      end
    end

    context 'when converting amount with currency to a string' do
      it 'returns a String' do
        Timecop.freeze(Time.parse('2024-08-16')) do
          result = Lariconv.convert(amount: 100, currency: 'EUR').to_s('F')
          expect(result).to be_a(String)
          expect(result).to eq('296.48')
        end
      end
    end

    context 'when an invalid amount is provided' do
      it 'raises Lariconv::InvalidAmountException' do
        expect { Lariconv.convert(amount: 'abc', currency: 'EUR') }.to raise_error(Lariconv::InvalidAmountException)
      end
    end

    context 'when an unavailable currency is provided' do
      it 'raises Lariconv::UnavailableCurrencyException' do
        expect { Lariconv.convert(amount: 1000, currency: 'WTF') }.to raise_error(Lariconv::UnavailableCurrencyException)
      end
    end
  end
end
