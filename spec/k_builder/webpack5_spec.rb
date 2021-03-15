# frozen_string_literal: true

RSpec.describe KBuilder::Webpack5 do
  it 'has a version number' do
    expect(KBuilder::Webpack5::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise KBuilder::Webpack5::Error, 'some message' }
      .to raise_error('some message')
  end
end
