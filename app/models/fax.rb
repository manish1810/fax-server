class Fax < ApplicationRecord
  SENDING_NUMBER = '+13123406594'
  belongs_to :user
  
  enum status: [:pending, :queued, :processed, :sending, :delivered, :failed]
  
  has_one_attached :file
  
  validates :phone_number, presence: true
  
  before_save :delete_file, if: :status_changed?
  
  private
  
  def delete_file
    return unless delivered?

    file.purge_later
  end
end
