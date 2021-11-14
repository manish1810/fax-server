class CreateFaxes < ActiveRecord::Migration[6.1]
  def change
    create_table :faxes do |t|
      t.integer :status, default: 0
      t.references :user, null: false, foreign_key: true
      t.string :service_id

      t.timestamps
    end
  end
end
