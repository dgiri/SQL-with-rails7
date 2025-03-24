ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "helpers/seed_helper"
module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # Add more helper methods to be used by all tests here...
    def setup
      # Clear database before each test
      PostTag.destroy_all
      Post.destroy_all
      Tag.destroy_all
      User.destroy_all
    end

    def self.prepare_test_data
      @@test_data ||= SeedHelper.generate_test_data
    end

    def prepare_test_data
      SeedHelper.generate_test_data
    end
  end
end
