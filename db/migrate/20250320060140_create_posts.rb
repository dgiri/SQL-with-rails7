class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.boolean :published, default: false
      t.datetime :published_at
      t.integer :view_count, default: 0
      t.integer :status, default: 0, null: false
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index :published_at
      t.index :status
      t.index :view_count
      t.index [ :user_id, :published ]
    end

    # Add a GIN index for full-text search
    execute <<-SQL
      CREATE INDEX posts_content_search_idx ON posts USING gin(to_tsvector('english', title || ' ' || content));
    SQL

    # Add a GIN index for the JSONB column
    execute <<-SQL
      CREATE INDEX posts_metadata_idx ON posts USING gin(metadata);
    SQL
  end
end
