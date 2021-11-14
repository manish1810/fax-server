class AddPhoneNumberToFax < ActiveRecord::Migration[6.1]
  def change
    add_column :faxes, :phone_number, :string
  end
end
