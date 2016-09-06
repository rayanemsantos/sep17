class Package < ActiveRecord::Base
  has_many :users


  def remaining
    @remaining = self.limit - self.users.count
  end


  def cart_total_price( current_user)
   total_price = 0
   partial_price = 0
   event_partial_price = 0
   current_user.get_cart_events.each { |event| event_partial_price+= event.price }
   partial_price = event_partial_price - self.package_discount(current_user)
   if package_fit?(current_user)
       total_price = Package.second.price + partial_price 
   else
        total_price = event_partial_price
   end

  end

  def package_discount(current_user)

  	package= self
  	prices = Event.events_prices
    total_discount = 0

    if package_fit?(current_user)
    	total_discount = prices[0]*package.lectures + prices[1]*package.courses + prices[2]*package.visits
      

  	else
  		total_discount = 0
  	end
  end




  def package_fit?(current_user)
  	count = self.event_kind_count(current_user)
  	package = self
    if count[lectures] >= package.lectures && count[visits] >= package.visits && count[courses] >= package.courses
    	true
    else
    	false
    end
  end


    def event_kind_count(current_user)
    events = current_user.get_cart_events
    count = Hash.new
    count[lectures] = 0
    count[courses] = 0
    count[visits] = 0
    events.each do |event|
      count[lectures] +=1 if event.kind== 'palestra'
      count[courses] +=1 if event.kind== 'mini-curso'
      count[visits] +=1 if event.kind== 'visita'
    end
    count
       

  end

end
