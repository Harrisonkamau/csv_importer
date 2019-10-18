# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2019_10_18_012523) do
  enable_extension 'plpgsql'

  create_table 'locations', force: :cascade do |t|
    t.string 'name'
    t.string 'city'
    t.string 'address'
    t.string 'postal_code'
    t.float 'latitude'
    t.float 'longitude'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end
end
