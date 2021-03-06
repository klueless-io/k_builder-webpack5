# frozen_string_literal: true

RSpec.describe KBuilder::Webpack5::WebpackJsonFactory do
  let(:webpack1) do
    described_class.webpack
  end
  let(:webpack2) do
    described_class.webpack
    # do
    # end
  end

  let(:root_scope1) do
    described_class.root_scope
  end
  let(:root_scope2) do
    described_class.root_scope do |root|
      root.require_webpack = true
    end
  end

  let(:entry1) do
    described_class.entry(:main)
  end
  let(:entry2) do
    described_class.entry do |root|
      root.require_webpack = true
    end
  end
  let(:dev_server1) do
    described_class.dev_server
  end
  let(:dev_server2) do
    # Default when dev server is requested
    described_class.dev_server do |server|
      server.open = true
      server.host = 'localhost'
    end
  end

  def p(title, _hash)
    puts 70 * '-'
    puts title
    puts 70 * '-'
  end

  # it { puts JSON.pretty_generate(webpack1.as_json) }
  # it { puts JSON.pretty_generate(dev_server.as_json) }
  # it { puts JSON.pretty_generate(root_scope1.as_json) }
  # it { puts JSON.pretty_generate(webpack1.as_json) }

  describe '#root_scope' do
    context 'default root scope' do
      subject { root_scope1 }

      it { is_expected.to be_a(KBuilder::Webpack5::JsonData) }

      it {
        expect(subject).to have_attributes(
          require_path: false,
          require_webpack: false,
          require_mini_css_extract_plugin: false,
          require_html_webpack_plugin: false,
          require_workbox_webpack_plugin: false,
          require_autoprefixer: false,
          require_precss: false
        )
      }
    end

    context 'altered root scope' do
      subject { root_scope2 }

      it {
        expect(subject).to have_attributes(
          require_path: false,
          require_webpack: true,
          require_mini_css_extract_plugin: false,
          require_html_webpack_plugin: false,
          require_workbox_webpack_plugin: false,
          require_autoprefixer: false,
          require_precss: false
        )
      }
    end
  end
end
