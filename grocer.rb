require "pry"

def consolidate_cart(cart)
  counts = Hash.new(0)
  # creates a count of each unique item in the cart
  cart.each {|e| e.each {|item, attributes| counts[item] += 1}}

  cart_hash = {}
  # takes the cart that is passed in (which is an array in which each element is a hash with a key of a cart item and a value of a nested
  # hash that describes the cart item), and generates one consolidated hash, in which each key-value pair represents a cart item.
  # this []= method will only result in one key-value pair for each type of item (i.e. will not reflect repeated items)
  cart.each {|item| item.each{|item, attributes|
    cart_hash[item] = attributes
  }}
  # adds the number of each unique item in the cart as a key-value pair within the hash that each item points to
  # thus generating a consolidated hash that describes item occurrences in the cart with a number count instead of item repetition
  counts.each {|item, count| cart_hash[item][:count] = count if cart_hash[item]}

  cart_hash
end

def apply_coupons(cart, coupons)
  coupons.each {|coupon| item = coupon[:item] # iterate over array of coupons, extract item coupon applies to and assign to variable
    if cart[item] && cart[item][:count] >= coupon[:num] # check if 1) the coupon applies to any items in the cart
    # and 2) the quantity of the coupon-eligible item in the cart meets the quantity terms of the coupon
      if cart["#{item} W/COUPON"] # check if the couponed item has already been added to the cart
        cart["#{item} W/COUPON"][:count] += 1 # increment if the same coupon is being applied more than once
      else # if the coupon has not yet been applied, add the couponed item to the cart
        cart["#{item} W/COUPON"] = {:price => coupon[:cost], :clearance => cart[item][:clearance], :count => 1}
      end
      cart[item][:count] -= coupon[:num] #subtract from the number of regularly priced items in the cart to account for the coupon use
    end
  }
  cart
end

def apply_clearance(cart)
  cart.each {|item, attributes| # iterate over each item in the cart
    # check if the item is on clearance, if so, discount the price by 20%
    if attributes[:clearance] == true
      attributes[:price] = (attributes[:price] *= 0.8).round(1)
    end
  }
  #binding.pry
  cart
end

def checkout(cart, coupons)
  consolidated_cart = consolidate_cart(cart)
  couponed_cart = apply_coupons(consolidated_cart, coupons)
  discounted_cart = apply_clearance(couponed_cart)
  total = 0
  discounted_cart.each {|item, attributes|
    binding.pry
    total += attributes[:count] * attributes[:cost]
  }
  total * 0.90 if total > 100
  total
end
