class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :approved, default: false
      t.references :parent, null: false, foreign_key: { to_table: :comments }
      t.integer :upvotes, default: 0
      t.integer :downvotes, default: 0

      t.timestamps

      t.index :approved

      t.index [:post_id, :created_at]
      t.index [:parent_id, :created_at]
    end
  end
end
