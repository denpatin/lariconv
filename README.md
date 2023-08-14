`lariconv`
==========

[![Gem Version](https://badge.fury.io/rb/lariconv.svg)](https://badge.fury.io/rb/lariconv)

Gem to convert different currencies to Georgian Lari based on
the National Bank of Georgia's exchange rate for a given date.

## Usage

```ruby
Lariconv.convert(amount: 1000, currency: 'GBP', date: '2022-08-15')
# => 0.32829e4 (BigDecimal)

Lariconv.convert(amount: BigDecimal('100.68'), currency: 'EUR')
# => 0.28869e3 (BigDecimal)

Lariconv.convert(amount: 1.5, currency: 'USD', date: '2023-08-15').to_f
# => 3.93 (Float)

Lariconv.convert(amount: 100, currency: 'EUR').to_s('F')
# => "288.16" (String)

Lariconv.convert(amount: 'abc', currency: 'EUR')
# => Lariconv::InvalidAmountException

Lariconv.convert(amount: 1000, currency: 'WTF')
# => Lariconv::UnavailableCurrencyException
```

## Copyright

Copyright (c) 2023 Den Patin. See LICENSE for details.
