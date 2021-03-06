# frozen_string_literal: true

# Warning: I am not using mocks and so there is a known test anti
#          I am aware that this is an Anti Pattern in unit testing
#          but I am sticking with this pattern for now as it saves
#          me a lot of time in writing tests.
# Future:  May want to remove this Anti Pattern
#
# These are the options that the current webpack-cli use
#
# webpack-cli options:
#
# - Will your application have multiple bundles? No
# - [done] Which will be your application entry point? src/index
# or
# - Will your application have multiple bundles? Yes
# - What do you want to name your bundles? (separated by comma) page1,pageTwo,pageThree
# - [done] What is the location of "page1"? src/page1
# - [done] What is the location of "pageTwo"? src/pageTwo
# - [done] What is the location of "pageThree"? src/PageThree/page3
#
# - In which folder do you want to store your generated bundles? dist
# - Will you use one of the below JS solutions? [No, ES6, Typescript]
# - Will you use one of the below CSS solutions? [No, CSS, SASS, PostCss]
# - Will you bundle your CSS files with MiniCssExtractPlugin? Yes
# - What will you name the CSS bundle? main
# - [done] Do you want to use webpack-dev-server? Yes
# - Do you want to simplify the creation of HTML files for your bundle? Yes
# - Do you want to add PWA support? Yes
#
# fit {
#   puts JSON.pretty_generate( builder.webpack_rc.as_json)
#   puts subject
# }
RSpec.describe KBuilder::Webpack5::WebpackBuilder do
  let(:builder_module) { KBuilder }
  let(:instance) { described_class.new }
  let(:builder) { instance }

  let(:samples_folder) { File.join(Dir.getwd, 'spec', 'samples') }
  let(:target_folder) { samples_folder }
  let(:app_template_folder) { File.join(samples_folder, 'app-template') }
  # let(:global_template_folder) { File.join(samples_folder, 'global-template') }
  let(:global_template_folder) { File.join(Dir.getwd, '.templates') }

  shared_context 'basic configuration' do
    let(:cfg) do
      lambda { |config|
        config.target_folders.add(:app, target_folder)

        # Default opinionated package groups
        config.package_json.default_package_groups

        config.template_folders.add(:global , global_template_folder)
        config.template_folders.add(:app , app_template_folder)
      }
    end
  end

  # Out of the box, webpack won't require you to use a configuration file.
  # However, it will assume the entry point of your project is src/index.js
  # and will output the result in dist/main.js minified and optimized for production.

  before :each do
    builder_module.configure(&cfg)
  end

  after :each do
    builder_module.reset
  end

  # Will your application have multiple bundles? (y/N) y
  # What do you want to name your bundles? (separated by comma) (pageOne, pageTwo)
  #   - page1,pageTwo,pageThree
  #   - What is the location of "page1"? src/page1
  #   - What is the location of "pageTwo"? src/pageTwo
  #   - What is the location of "pageThree"? src/PageThree/page3
  # In which folder do you want to store your generated bundles? (dist)
  # Will you use one of the below JS solutions? (Use arrow keys)
  # - No
  # - ES6
  # - Typescript
  # Will you use one of the below CSS solutions? (Use arrow keys)
  # - No
  # - CSS
  # - SASS
  # - LESS
  # - PostCSS
  # Will you bundle your CSS files with MiniCssExtractPlugin? (y/N)
  # What will you name the CSS bundle? (main)
  # Do you want to use webpack-dev-server? (Y/n)
  # Do you want to simplify the creation of HTML files for your bundle? (y/N)
  # Do you want to add PWA support? (Y/n)
  #
  describe '#initialize' do
    include_context 'basic configuration'

    subject { builder }

    context 'with default configuration' do
      it { is_expected.not_to be_nil }
    end

    describe '.target_folder' do
      subject { builder.target_folder }
      it { is_expected.to eq(target_folder) }
    end

    describe '#get_template_folder(:app)' do
      subject { builder.get_template_folder(:app) }
      it { is_expected.to eq(app_template_folder) }
    end

    describe '#get_template_folder(:global)' do
      subject { builder.get_template_folder(:global) }
      it { is_expected.to eq(global_template_folder) }
    end

    describe '.webpack_rc_file' do
      subject { builder.webpack_rc_file }
      it { is_expected.not_to be_empty }
    end

    describe '.webpack_rc' do
      include_context :use_temp_folder

      subject { builder.webpack_rc }

      let(:target_folder) { @temp_folder }

      it { expect(-> { subject }).to raise_error KBuilder::Webpack5::Error, '.webpack-rc.json does not exist' }
    end
  end

  describe '#webpack_init' do
    include_context 'basic configuration'

    before :each do
      builder.webpack_init
    end

    describe '#webpack_rc_file' do
      subject { builder.webpack_rc_file }

      it { is_expected.to eq(File.join(target_folder, '.webpack-rc.json')) }
      # it { puts JSON.pretty_generate(builder.webpack_rc.as_json) }
    end

    describe '.webpack_rc' do
      subject { builder.webpack_rc.root_scope.require_webpack }

      it { is_expected.to eq(false) }
    end
  end

  describe '#process_any_content' do
    include_context 'basic configuration'
    # debug code to be addeded where needed
    # it { puts File.read(instance.webpack_rc_file) }
    include_context :use_temp_folder

    let(:builder) { instance.webpack_init }
    let(:subject) { builder.process_any_content(template_file: 'webpack.config.js.txt', **builder.webpack_rc.as_json).strip }
    let(:target_folder) { @temp_folder }

    it { is_expected.to be_empty }

    describe '.mode' do
      it { is_expected.not_to include('mode:') }

      context 'opinionated config' do
        before { builder.mode }

        it { is_expected.to include('mode:').and include('development') }
      end
      context 'options config' do
        before { builder.mode(mode: 'production') }

        it { is_expected.to include('mode:').and include('production') }
      end
      context 'block config' do
        before do
          builder.mode do |o|
            o.mode = 'production'
          end
        end

        it { is_expected.to include('mode:').and include('production') }
      end
    end

    describe '.entry' do
      context 'opinionated config' do
        before { builder.entry }

        it { is_expected.to include('entry:').and include('./src') }
      end
      context 'options config' do
        before { builder.entry(entry: './src/index.js') }

        it { is_expected.to include('entry:').and include('./src/index.js') }
      end
      context 'block config' do
        before do
          builder.entry do |o|
            o.entry = './src/main.js'
          end
        end

        it { is_expected.to include('entry:').and include('./src/main.js') }
      end
    end

    describe '.entries' do
      context 'opinionated config' do
        before { builder.entries }

        it do
          is_expected
            .to  include('entry:')
            .and include('home')
            .and include('./src/home.js')
            .and include('about')
            .and include('./src/about.js')
        end
      end
      context 'options config' do
        # Not Applicable
      end
      context 'block config' do
        before do
          builder.entries do |o|
            o.entries = {
              home: './src/main.js',
              about: './src/about.js'
            }
          end
        end

        it do
          is_expected
            .to  include('entry:')
            .and include('home')
            .and include('./src/main.js')
            .and include('about')
            .and include('./src/about.js')
        end
      end
    end

    describe '.webpack_dev_server' do
      context 'opinionated config' do
        before { builder.webpack_dev_server }

        it { is_expected.to include('devServer').and include('open: true') }
      end
      context 'options config' do
        before { builder.webpack_dev_server(static: %w[assets css]) }

        it { is_expected.not_to include('open: true') }
        it { is_expected.to include('devServer').and include('static').and include('assets') }
      end
      context 'block config' do
        before do
          builder.webpack_dev_server do |dev_server|
            dev_server.xyz = 'hello'
          end
        end

        it { is_expected.not_to include('open: true') }
        it { is_expected.to include('devServer').and include('xyz').and include('hello') }
      end
    end

    describe '.plugin_mini_css_extract' do
      it { is_expected.not_to include('mini-css-extract-plugin') }
      # const MiniCssExtractPlugin = require('mini-css-extract-plugin');

      context 'opinionated config' do
        before { builder.plugin_mini_css_extract }

        it do
          is_expected
            .to  include("require('mini-css-extract-plugin')")
            .and include('new MiniCssExtractPlugin')
            .and include('main.[contenthash].css')
        end
      end
      context 'options config' do
        before { builder.plugin_mini_css_extract(filename: 'crazydave.css') }

        it do
          is_expected
            .to  include("require('mini-css-extract-plugin')")
            .and include('new MiniCssExtractPlugin')
            .and include('crazydave.css')
        end
      end
      context 'block config' do
        before do
          builder.plugin_mini_css_extract do |o|
            o.filename = 'xmen.[contenthash].css'
          end
        end

        it do
          is_expected
            .to  include("require('mini-css-extract-plugin')")
            .and include('new MiniCssExtractPlugin')
            .and include('xmen.[contenthash].css')
        end
      end
    end
  end
end
