class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :content
      t.references :chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
