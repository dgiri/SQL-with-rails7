class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, presence: true
  validates :content, presence: true

  scope :published, -> { where(status: "published") }
  scope :draft, -> { where(status: "draft") }
  scope :popular, -> { where("view_count > ?", 1000) }

  enum status: { draft: 0, published: 1, archived: 2 }

  attribute :status, :integer, default: 0  # Sets default to 'draft'

  def tags
    query = "SELECT tags.* FROM tags
      INNER JOIN post_tags ON tags.id = post_tags.tag_id
      WHERE post_tags.post_id = ?"
    tags = Tag.find_by_sql([ query, self.id ])
    Rails.logger.info("***tags: #{tags.inspect}")
    tags.map(&:name)
  end

  def status_enum
    self.class.statuses.values
  end

  def status_text
    Post.statuses.key(status)&.capitalize
  end
end
