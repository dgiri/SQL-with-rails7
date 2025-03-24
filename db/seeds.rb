# Clear existing data
puts "Clearing existing data..."
PostTag.delete_all
Comment.delete_all
Post.delete_all
Tag.delete_all
User.delete_all

# Create Users with different characteristics
puts "Creating users..."
users = []

# Regular users
20.times do |i|
  users << User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: 'password123',
    password_confirmation: 'password123',
    reset_password_sent_at: nil,
    remember_created_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
    sign_in_count: rand(0..100),
    current_sign_in_at: Faker::Date.between(from: 1.month.ago, to: Date.today),
    last_sign_in_at: Faker::Date.between(from: 2.months.ago, to: 1.month.ago),
    current_sign_in_ip: Faker::Internet.ip_v4_address,
    last_sign_in_ip: Faker::Internet.ip_v4_address,
    created_at: Faker::Date.between(from: 2.years.ago, to: Date.today),
    updated_at: Faker::Date.between(from: 1.year.ago, to: Date.today),
    active: [ true, true, true, false ].sample, # 75% active
    preferences: {
      theme: [ 'light', 'dark', 'system' ].sample,
      notifications: [ true, false ].sample,
      language: [ 'en', 'es', 'fr', 'de' ].sample
    }
  )
end

# Power users with high activity
5.times do
  users << User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
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

# Inactive users
3.times do
  users << User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: 'password123',
    password_confirmation: 'password123',
    reset_password_sent_at: nil,
    remember_created_at: Faker::Date.between(from: 18.months.ago, to: 12.months.ago),
    sign_in_count: rand(1..10),
    current_sign_in_at: Faker::Date.between(from: 12.months.ago, to: 9.months.ago),
    last_sign_in_at: Faker::Date.between(from: 18.months.ago, to: 12.months.ago),
    current_sign_in_ip: Faker::Internet.ip_v4_address,
    last_sign_in_ip: Faker::Internet.ip_v4_address,
    created_at: Faker::Date.between(from: 24.months.ago, to: 18.months.ago),
    updated_at: Faker::Date.between(from: 18.months.ago, to: 12.months.ago),
    active: false,
    preferences: {
      theme: 'light',
      notifications: false,
      language: 'en'
    }
  )
end

# Create Tags
puts "Creating tags..."
tags = []
[ 'Technology', 'Science', 'Health', 'Politics', 'Entertainment',
 'Sports', 'Business', 'Education', 'Art', 'Travel',
 'Food', 'Fashion', 'Environment', 'Personal', 'News' ].each do |tag_name|
  tags << Tag.create!(
    name: tag_name,
    popularity: rand(1..100)
  )
end

# Create Posts with varied characteristics
puts "Creating posts..."
posts = []

# Regular posts spread across users
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

# Create some popular posts with high view counts
10.times do
  user = users.sample
  posts << Post.create!(
    user: user,
    title: "Popular: #{Faker::Lorem.sentence(word_count: rand(5..10))}",
    content: Faker::Lorem.paragraphs(number: rand(3..7)).join("\n\n"),
    created_at: Faker::Date.between(from: 1.year.ago, to: 6.months.ago),
    updated_at: Faker::Date.between(from: 6.months.ago, to: Date.today),
    published: true,
    published_at: Faker::Date.between(from: 6.months.ago, to: Date.today),
    view_count: rand(1000..5000),
    status: 1,  # or use :published
    metadata: {
      source: [ 'web', 'mobile', 'api' ].sample,
      word_count: rand(500..2000),
      reading_time: rand(5..20),
      featured: true
    }
  )
end

# Assign Tags to Posts (many-to-many)
puts "Assigning tags to posts..."
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

# Create Comments
puts "Creating comments..."
comments = []

# Regular comments on posts
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

puts "Seed data creation complete!"
puts "Created #{User.count} users"
puts "Created #{Post.count} posts"
puts "Created #{Tag.count} tags"
puts "Created #{PostTag.count} post tags"
puts "Created #{Comment.count} comments"
