class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy

  validates :content, presence: true

  scope :approved, -> { where(approved: true) }
  scope :root_comments, -> { where(parent_id: nil) }
end
