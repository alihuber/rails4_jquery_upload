ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require "pry-rails"

require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "rspec/autorun"
require "database_cleaner"

require "coffee_script"
require "capybara/rails"
require "capybara/rspec"
require "capybara/poltergeist"

# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, js_errors: false, inspector: true)
# end
Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 10

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered                = true
  config.filter_run                                        :focus
  config.filter_run_excluding                              :js

  config.use_transactional_fixtures                      = false
  config.infer_base_class_for_anonymous_controllers      = false
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"


  config.before :suite do
    DatabaseCleaner.clean_with :deletion
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each, js: true do
    DatabaseCleaner.strategy = :deletion
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end

def wait_for_ajax
  Timeout.timeout(Capybara.default_wait_time) do
    loop until page.evaluate_script("jQuery.active").zero?
  end
end

