module SeedHelper
  def self.generate_test_data
    # Clear any existing data
    PostTag.destroy_all
    Post.destroy_all
    Tag.destroy_all
    User.destroy_all

    users = []

    1.times do
      users << User.create!(
        name: "Debashish",
        email: "giri.debu@testexample.com",
        password: 'password123',
        password_confirmation: 'password123',
        reset_password_sent_at: nil,
        remember_created_at: Faker::Date.between(from: 6.months.ago, to: Date.today),
        sign_in_count: rand(100..500),
        current_sign_in_at: Faker::Date.between(from: 1.week.ago, to: Date.today),
        last_sign_in_at: Faker::Date.between(from: 2.weeks.ago, to: 1.week.ago),
        current_sign_in_ip: Faker::Internet.ip_v4_address,
        last_sign_in_ip: Faker::Internet.ip_v4_address,
        created_at: Faker::Date.between(from: 2.years.ago, to: 1.year.ago),
        updated_at: Faker::Date.between(from: 6.months.ago, to: Date.today),
        active: true,
        preferences: {
          theme: 'dark',
          notifications: true,
          language: [ 'en', 'es' ].sample
        }
      )
    end

    tags = []
    [ 'Technology', 'Science', 'Health', 'Politics', 'Entertainment',
    'Sports', 'Business', 'Education', 'Art', 'Travel',
    'Food', 'Fashion', 'Environment', 'Personal', 'News' ].each do |tag_name|
      tags << Tag.create!(
        name: tag_name,
        popularity: rand(1..100)
      )
    end

    posts = []

    users.each do |user|
      # Number of posts varies by user type
      post_count = user.sign_in_count > 100 ? rand(15..30) : rand(0..10)

      post_count.times do
        post = Post.create!(
          user: user,
          title: Faker::Lorem.sentence,
          content: Faker::Lorem.paragraphs(number: rand(2..5)).join("\n\n"),
          published: [ true, false ].sample,
          published_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
          view_count: rand(0..5000),
          status: 0,  # or use :draft
          metadata: {
            reading_time: rand(2..15),
            category: [ 'Technology', 'Lifestyle', 'Travel', 'Food' ].sample,
            tags: Faker::Lorem.words(number: rand(2..5))
          }
        )
        posts << post
      end
    end

    posts.each do |post|
      # Each post gets 1-4 random tags
      post_tags = tags.sample(rand(1..4))
      post_tags.each do |tag|
        PostTag.create!(
          post: post,
          tag: tag,
          relevance_score: rand(1..10)
        )
      end
    end

    comments = []

    posts.select { |post| post.published }.each do |post|
      # Number of comments varies by post popularity
      comment_count = post.view_count > 1000 ? rand(10..30) : rand(0..10)

      # Skip if no comments needed
      next if comment_count == 0

      # Create root comments (with parent_id as null)
      root_count = (comment_count * 0.7).to_i # 70% are root comments
      root_count = 1 if root_count < 1

      root_comments = []
      root_count.times do
        user = users.sample
        comment = Comment.create!(
          user: user,
          post: post,
          content: Faker::Lorem.paragraph(sentence_count: rand(1..5)),
          created_at: Faker::Date.between(from: post.published_at || 6.months.ago, to: Date.today),
          updated_at: Faker::Date.between(from: 3.months.ago, to: Date.today),
          approved: [ true, true, true, false ].sample, # 75% approved
          upvotes: rand(0..50),
          downvotes: rand(0..10),
          parent_id: nil # Root comment (no parent)
        )

        comments << comment
        root_comments << comment
      end

      # Create reply comments
      reply_count = comment_count - root_count

      reply_count.times do
        # Only create replies if we have root comments to reply to
        next if root_comments.empty?

        # Choose a parent comment - either a root comment or sometimes another reply
        parent_comment = rand > 0.2 ? root_comments.sample : comments.select { |c| c.post_id == post.id }.sample
        user = users.sample

        comment = Comment.create!(
          user: user,
          post: post,
          content: "Reply: #{Faker::Lorem.paragraph(sentence_count: rand(1..3))}",
          created_at: Faker::Date.between(from: [ parent_comment.created_at, post.published_at || 6.months.ago ].max, to: Date.today),
          updated_at: Faker::Date.between(from: 3.months.ago, to: Date.today),
          approved: [ true, true, true, false ].sample, # 75% approved
          upvotes: rand(0..20),
          downvotes: rand(0..5),
          parent_id: parent_comment.id
        )

        comments << comment
      end
    end

    # Return generated data for reference if needed
    {
      users: users,
      tags: tags,
      posts: posts,
      comments: comments
    }
  end
end