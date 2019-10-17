# frozen_string_literal: true

require_relative '../locations_processor'

namespace :locations do
  task download: :environment do
    begin
      LocationsProcessor.run
    rescue StandardError => e
      Rails.logger.error "Error occurred while downloading locations: #{e}"
    end
  end
end
