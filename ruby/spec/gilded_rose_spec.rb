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

        n.times do |i|
          gilded_rose.update_quality
          expect(item.sell_in).to eq (n - (i + 1))
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

    context 'item quality' do
      it 'quality value is never negative' do
        item = Item.new('foo', sell_in=0, quality=0)
        items = [item]
        gilded_rose = described_class.new(items)
        gilded_rose.update_quality

        expect(item.quality).to eq 0
      end

      context 'when sell in date not passed yet' do
        it 'lowers quality value by 1 at the end of the day' do
          item = Item.new('foo', sell_in=1, quality=1)
          items = [item]
          gilded_rose = described_class.new(items)
          gilded_rose.update_quality

          expect(item.quality).to eq 0
        end

        it 'lowers quality value by N after N days' do
          n = 10
          item = Item.new('foo', sell_in=n, quality=n)
          items = [item]
          gilded_rose = described_class.new(items)

          n.times do |i|
            gilded_rose.update_quality
            expect(item.quality).to eq (n - (i + 1))
          end

          expect(item.quality).to eq 0
        end
      end

      context 'when sell in date has passed' do
        it 'lowers quality value by 2 at the end of the day' do
          item = Item.new('foo', sell_in=0, quality=4)
          items = [item]
          gilded_rose = described_class.new(items)
          gilded_rose.update_quality

          expect(item.quality).to eq 2
        end

        it 'lowers quality value twice as fast after N days' do
          n = 5
          quality = 15
          item = Item.new('foo', sell_in=0, quality=quality)
          items = [item]
          gilded_rose = described_class.new(items)

          n.times do |i|
            gilded_rose.update_quality
            expect(item.quality).to eq (quality - (2 * (i+1)))
          end

          expect(item.quality).to eq (quality - (2 * n))
        end
      end
    end

    context 'when item is Aged Brie' do
      context 'item quality' do
        context 'when sell in date not passed yet' do
          it 'increases by 1 the older it gets' do
            n = 5
            item = Item.new('Aged Brie', sell_in=n, quality=0)
            items = [item]
            gilded_rose = described_class.new(items)

            n.times do |i|
              gilded_rose.update_quality
              expect(item.quality).to eq (i + 1)
            end

            expect(item.quality).to eq n
          end
        end

        context 'when sell in date has passed' do
          it 'increases twice as fast the older it gets' do
            n = 5
            item = Item.new('Aged Brie', sell_in=0, quality=0)
            items = [item]
            gilded_rose = described_class.new(items)

            n.times do |i|
              gilded_rose.update_quality
              expect(item.quality).to eq (2 * (i + 1))
            end

            expect(item.quality).to eq (2 * n)
          end
        end

        it 'is never more than 50' do
          n = 2
          item = Item.new('Aged Brie', sell_in=n, quality=49)
          items = [item]
          gilded_rose = described_class.new(items)

          n.times do
            gilded_rose.update_quality
          end

          expect(item.quality).to eq 50
        end
      end
    end

    context 'when item is Sulfuras, Hand of Ragnaros' do
      context 'item sell in' do
        it 'does not change the sell in' do
          item = Item.new('Sulfuras, Hand of Ragnaros', sell_in=0, quality=0)
          items = [item]
          gilded_rose = described_class.new(items)
          gilded_rose.update_quality

          expect(item.sell_in).to eql 0
        end
      end

      context 'item quality' do
        it 'does not change the quality' do
          item = Item.new('Sulfuras, Hand of Ragnaros', sell_in=0, quality=0)
          items = [item]
          gilded_rose = described_class.new(items)
          gilded_rose.update_quality

          expect(item.quality).to eql 0
        end
      end
    end

    context 'when item is Backstage passes to a TAFKAL80ETC concert' do
      context 'item quality' do
        context 'when sell in date not passed yet' do
          context 'when sell in above 10 days' do
            it 'increases by 1 the older it gets' do
              n = 5
              quality = 1
              item = Item.new('Backstage passes to a TAFKAL80ETC concert', sell_in=15, quality=quality)
              items = [item]
              gilded_rose = described_class.new(items)

              n.times do |i|
                gilded_rose.update_quality
                expect(item.quality).to eq (quality + i + 1)
              end

              expect(item.quality).to eq (quality + n)
            end
          end

          context 'when sell in 10 days or less and above 5 days' do
            it 'increases by 2 the older it gets' do
              n = 5
              quality = 1
              item = Item.new('Backstage passes to a TAFKAL80ETC concert', sell_in=10, quality=quality)
              items = [item]
              gilded_rose = described_class.new(items)

              n.times do |i|
                gilded_rose.update_quality
                expect(item.quality).to eq (quality + 2 * (i + 1))
              end

              expect(item.quality).to eq (quality + (2 * n))
            end
          end

          context 'when sell in 5 days or less' do
            it 'increases by 3 the older it gets' do
              n = 5
              quality = 1
              item = Item.new('Backstage passes to a TAFKAL80ETC concert', sell_in=5, quality=quality)
              items = [item]
              gilded_rose = described_class.new(items)

              n.times do |i|
                gilded_rose.update_quality
                expect(item.quality).to eq (quality + 3 * (i + 1))
              end

              expect(item.quality).to eq (quality + (3 * n))
            end
          end
        end

        context 'when sell in date has passed' do
          it 'drops to 0 after the concert' do
            item = Item.new('Backstage passes to a TAFKAL80ETC concert', sell_in=0, quality=5)
            items = [item]
            gilded_rose = described_class.new(items)
            gilded_rose.update_quality

            expect(item.quality).to eq 0
          end
        end
      end
    end

  end

end
