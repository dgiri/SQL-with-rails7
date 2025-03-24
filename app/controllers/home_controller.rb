class HomeController < ApplicationController
  before_action :authenticate_user!, only: [ :view_posts ]

  def index
    if params[:status]
      @posts = Post.where(status: Post.statuses[params[:status]]).order(status: :desc, view_count: :desc, created_at: :desc).paginate(page: params[:page], per_page: 9)
    else
      @posts = Post.order(status: :desc, view_count: :desc, created_at: :desc).paginate(page: params[:page], per_page: 9)
    end
  end

  def view_posts
    if params[:tags]
      tags = Tag.where(name: params[:tags].split(","))
      if tags.any?
        query = "SELECT posts.*
          FROM posts
          INNER JOIN post_tags ON post_tags.post_id = posts.id
          INNER JOIN tags ON tags.id = post_tags.tag_id
          WHERE tags.name IN (#{params[:tags].split(",").map { |item| "'#{item}'" }.join(",")})
          ORDER BY posts.status DESC, posts.view_count DESC, posts.created_at DESC"

        # @posts = Post.find_by_sql(query).paginate(page: params[:page], per_page: 9)
        @posts = Post.paginate_by_sql([ query, params[:tags].split(",") ],
                    page: params[:page],
                    per_page: 9)

        # @posts = Post.joins(:tags).where(tags: { name: params[:tags].split(",") })
      else
        flash[:error] = "No tags found"
        redirect_to root_path
      end
    elsif params[:status]
      @posts = Post.where(status: Post.statuses[params[:status]]).order(status: :desc, view_count: :desc, created_at: :desc).paginate(page: params[:page], per_page: 9)
    else
      @posts = Post.all.order(status: :desc, view_count: :desc, created_at: :desc).paginate(page: params[:page], per_page: 9)
    end
  end
end
