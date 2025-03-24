class CreatePostTags < ActiveRecord::Migration[7.2]
  def change
    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.integer :relevance_score, default: 5

      t.timestamps

      t.index [:post_id, :tag_id], unique: true
    end
  end
end
