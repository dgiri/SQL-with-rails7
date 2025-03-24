class RemoveNotNullConstraintFromCommentParentId < ActiveRecord::Migration[7.2]
  def change
    change_column_null :comments, :parent_id, true
  end
end
