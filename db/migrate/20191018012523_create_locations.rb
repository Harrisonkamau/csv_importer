class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :city
      t.string :address
      t.string :postal_code
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
