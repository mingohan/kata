require 'spec_helper'
require File.join(File.dirname(__FILE__) + '/..', 'gilded_rose')

describe GildedRose do

  describe '#update_quality' do

    context 'item name' do
      it 'does not change the name' do
        item = Item.new('foo', sell_in=0, quality=0)
        items = [item]
        gilded_rose = described_class.new(items)
        gilded_rose.update_quality

        expect(item.name).to eq 'foo'
      end
    end

    context 'item sell in' do
      it 'lowers sell in value by 1 at the end of the day' do
        item = Item.new('foo', sell_in=1, quality=0)
        items = [item]
        gilded_rose = described_class.new(items)
        gilded_rose.update_quality

        expect(item.sell_in).to eq 0
      end

      it 'lowers sell in value by N after N days' do
        n = 10
        item = Item.new('foo', sell_in=n, quality=0)
        items = [item]
        gilded_rose = described_class.new(items)

        n.times do
          gilded_rose.update_quality
        end

        expect(item.sell_in).to eq 0
      end

      it 'sell in value can be negative' do
        item = Item.new('foo', sell_in=0, quality=0)
        items = [item]
        gilded_rose = described_class.new(items)
        gilded_rose.update_quality

        expect(item.sell_in).to eq -1
      end
    end

  end

end