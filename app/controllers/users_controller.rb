class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    case params[:filter]
    when "active_users"
      # Find active users with high login counts
      query = "SELECT name,email,last_sign_in_at, sign_in_count, COUNT(*) OVER() as total_count FROM users WHERE active = true AND sign_in_count > 200"
      @users = User.order(sign_in_count: :desc).paginate_by_sql(query, page: params[:page], per_page: 9)
    else
      @users = User.order(sign_in_count: :desc).paginate(page: params[:page], per_page: 9)
    end
  end
end

# select name, count(*) as user_count from users where sign_in_count > 50 group by name;

# SELECT country, COUNT(*) AS customer_count
# FROM customers
# GROUP BY country;
