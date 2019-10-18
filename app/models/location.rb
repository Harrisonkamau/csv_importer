# frozen_string_literal: true

class Location < ApplicationRecord
  # for activererecord bulk import
  require 'activerecord-import/base'
  require 'activerecord-import/active_record/adapters/postgresql_adapter'
end
