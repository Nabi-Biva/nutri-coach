class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.date :birthday
      t.string :sex
      t.float :weight
      t.float :height
      t.float :imc
      t.text :goal
      t.text :allergy
      t.text :lifestyle
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
