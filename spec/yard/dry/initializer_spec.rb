# frozen_string_literal: true

require 'pry'

RSpec.describe YARD::Dry::Initializer do
  before(:all) { parse_file :sample }

  it 'has a version number' do
    expect(YARD::Dry::Initializer::VERSION).not_to be nil
  end

  context 'simple param' do
    it 'creates attribute' do
      method = YARD::Registry.at('Sample#alpha')
      expect(method).to be_read_attribute
      expect(method.docstring).to eq 'Reader method for the +alpha+ initializer parameter.'
    end

    it 'creates positional argument for initializer' do
      constructor = YARD::Registry.at('Sample#initialize')
      expect(constructor).not_to eq nil
      expect(constructor.parameters.first).to eq(['alpha', nil])

      tag = constructor.tags('param').first
      expect(tag.tag_name).to eq('param')
      expect(tag.name).to eq('alpha')
    end
  end

  context 'param with renamed accessor' do
    it 'creates renamed attribute' do
      method = YARD::Registry.at('Sample#user')
      expect(method).to be_read_attribute
      expect(method.docstring).to eq 'Reader method for the +account+ initializer parameter.'
    end

    it 'creates positional argument for initializer' do
      constructor = YARD::Registry.at('Sample#initialize')
      expect(constructor).not_to eq nil
      expect(constructor.parameters[2]).to eq(%w[account nil])

      tag = constructor.tags('param')[2]
      expect(tag.tag_name).to eq('param')
      expect(tag.name).to eq('account')
    end
  end

  context 'param with default value' do
    it 'creates positional argument for initializer with default value' do
      constructor = YARD::Registry.at('Sample#initialize')
      expect(constructor).not_to eq nil
      expect(constructor.parameters[1]).to eq(['base', '"Belong to us"'])
    end
  end

  context 'inherited class' do
    context 'overloaded param' do
      it 'creates attribute' do
        method = YARD::Registry.at('InheritedSample#alpha')
        expect(method).to be_read_attribute
        expect(method.docstring).to eq 'Reader method for the +alpha+ initializer parameter.'
      end

      it 'reuses same positional argument for initializer' do
        constructor = YARD::Registry.at('InheritedSample').meths.find(&:constructor?)
        expect(constructor).not_to eq nil
        expect(constructor.parameters.first).to eq(%w[alpha nil])

        tag = constructor.tags('param').first
        expect(tag.tag_name).to eq('param')
        expect(tag.name).to eq('alpha')
      end
    end

    context 'new param' do
      it 'creates attribute' do
        method = YARD::Registry.at('InheritedSample#omega')
        expect(method).to be_read_attribute
        expect(method.docstring).to eq 'Reader method for the +omega+ initializer parameter.'
      end

      it 'creates new positional argument for initializer' do
        constructor = YARD::Registry.at('InheritedSample').meths.find(&:constructor?)
        expect(constructor).not_to eq nil
        expect(constructor.parameters[-2]).to eq(%w[omega nil])

        tag = constructor.tags('param').last
        expect(tag.tag_name).to eq('param')
        expect(tag.name).to eq('omega')
      end
    end

    context 'overloaded option' do
      it 'creates attribute' do
        method = YARD::Registry.at('InheritedSample#meaningless')
        expect(method).to be_read_attribute
        expect(method.docstring).to eq 'Reader method for the +meaningless+ initializer parameter.'
      end

      it 'reuses same keyword argument for initializer' do
        constructor = YARD::Registry.at('InheritedSample#initialize')
        expect(constructor).not_to eq nil
        expect(constructor.parameters.last).to eq(['**options', nil])
        expect(constructor).to have_option_tag('meaningless', defaults: ['true'], text: 'You know that is that stuff yeah')
      end

      it 'changes comment if it is overriden' do
        original_constructor  = YARD::Registry.at('Sample#initialize')
        inherited_constructor = YARD::Registry.at('InheritedSample#initialize')
        expect(original_constructor).to have_option_tag('commentful', text: 'Original comment')
        expect(inherited_constructor).to have_option_tag('commentful', text: 'Changed comment')
      end

      it 'keeps original argument in parent initializer untouched' do
        constructor = YARD::Registry.at('Sample#initialize')
        expect(constructor).to have_option_tag('meaningless', defaults: nil, text: 'You know that is that stuff yeah')
      end
    end

    context 'new option' do
      it 'creates attribute' do
        method = YARD::Registry.at('InheritedSample#useless')
        expect(method).to be_read_attribute
        expect(method.docstring).to eq 'Reader method for the +useless+ initializer parameter.'
      end

      it 'creates new optional argument for initializer' do
        constructor = YARD::Registry.at('InheritedSample').meths.find(&:constructor?)
        expect(constructor).not_to eq nil
        expect(constructor.parameters.last).to eq(['**options', nil])

        tag = constructor.tags('option').last.pair
        expect(tag.name).to eq('useless')
        expect(tag.defaults).to eq(['nil'])
      end
    end
  end
end
