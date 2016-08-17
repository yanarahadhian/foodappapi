def purge(tablename, join_table = false)
  eval("#{tablename.classify}").destroy_all unless join_table
  ActiveRecord::Base.connection.execute('ALTER TABLE ' + tablename + ' AUTO_INCREMENT = 1')
end

# START
time = Time.now
puts 'Joey Food API seeding with dummy data'

puts 'Purging tables...'
purge('images')
purge('items_stores', true)
purge('items')
purge('stores')
purge('users')
purge('item_categories')

puts 'Seeding categories...'
categories = ['Pizza', 'Cake', 'Snack', 'Sandwich', 'Noodle', 'Pasta', 'Sea', 'Soup', 'Nasi', 'Meat']
categories.each do |category|
  ItemCategory.create(:name => category)
end

puts 'Seeding users...'
users = {
          :soap_mac_tavish => 'http://img2.wikia.nocookie.net/__cb20120122010801/callofduty/images/b/b7/Soap_MW3_model.png',
          :john_price => 'https://pbs.twimg.com/profile_images/2980187161/0ffa99106808bfef266a91fdb955138e_400x400.png',
          :reznov_viktor => 'http://images1-4.gamewise.co/Reznov-102549-large.png',
          :dimitri_petrenko => 'http://img1.wikia.nocookie.net/__cb20101119200539/callofduty/images/2/22/Dimitri_Petrenko_listening_BO.jpg',
          :makarov_vladimir => 'http://pre00.deviantart.net/c237/th/pre/i/2011/327/2/f/makarov_real_by_mataleonerj-d4h2poi.jpg'
        }
users.each do |key, value|
  username = key.to_s.titleize
  email = [username.split(' ').first.downcase, 'joeyfood.com'].join('@')
  country = ''
  city = ''
  loop do
    country = Country.find_all_countries_by_subregion('South-Eastern Asia').sample
    province = CS.states(country.alpha2).map(&:first).sample
    city = CS.get(country.alpha2, province).sample rescue nil
    break city unless city.nil?
  end
  user = User.new(:email => email,
                  :password => '123456789',
                  :full_name => username,
                  :country => country.name,
                  :city => city,
                  :website_url => 'https://www.google.com',
                  :about_me => "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
  image_indexes = ['avatar', 'background'].each do |index|
    temp = open(value)
    image = user.images.build(:flag => index)
    image.storage = temp
    image.save!
  end
  user.save!
end

puts "Seeding store for user #{User.first.full_name}..."
User.first.stores.build(:name => 'Pizza Hut',
                        :country => 'Indonesia',
                        :street => 'Jl. Merdeka',
                        :latlong => '-6.908507,107.610747',
                        :location => 'Bandung Indah Plaza Lt. 1',
                        :phone => '089678968123',
                        :city => 'Bandung').save

puts "Seeding items for store #{User.first.stores.first.name}..."
items = {
          :meat_lovers =>
          [
            'http://www.thepizzabox.com.au/images/Meatlovers.png',
            'http://www.mypizzahouse.com/wp-content/uploads/2012/02/meatloverpizza.jpg',
            'https://thingsboganslike.files.wordpress.com/2011/04/meat-lovers-pizza.jpg'
          ],
          :indonesian_fried_rice =>
          [
            'http://www.taste.com.au/images/recipes/del/2008/06/26282_l.jpg',
            'https://culinarygypsy.files.wordpress.com/2013/03/nasi-goreng.jpg',
            'http://yousaytoo-us.s3-website-us-east-1.amazonaws.com/post_images/f7/43/b9/3088588/remote_image_1330864783.jpg'
          ],
          :chocolate_banana_cheese =>
          [
            'http://2.bp.blogspot.com/-QL7AV_3Gv1Q/U7a6NAC1rKI/AAAAAAAACA4/dXMXDOdEjDM/s1600/Resep+Pisang+Keju+dan+Membuatnya.jpg',
            'http://inforesepku.com/wp-content/uploads/2014/12/Sate-Pisang-Keju.jpg',
            'http://www.duniainter.net/wp-content/uploads/2013/11/pisang-keju.jpg'
          ]
        }
category_ids = ItemCategory.all.map(&:id)
delivery_fees = [*(0..30)]
prices = [*(30..100)]
items.each do |key, value|
  category_id = category_ids.sample
  delivery_fee = delivery_fees.sample
  price = prices.sample
  store = User.first.stores.first
  item = User.first.items.build(:seller => User.first,
                                :item_category_id => category_id,
                                :name => key.to_s.titleize,
                                :delivery_fee => delivery_fee,
                                :price => price,
                                :description => "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
  value.each do |img_url|
    temp = open(img_url)
    image = item.images.build
    image.storage = temp
    image.save
  end
  item.save
end

time = ((Time.now - time) / 1.second).round(2)
puts "Task completed in #{time}s"
# END
