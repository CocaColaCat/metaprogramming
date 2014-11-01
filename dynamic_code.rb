class DataSource
	def get_mouse_info; end
	def get_cpu_info; end
	def get_keyboard_info; end

	def get_mouse_price; end
	def get_cpu_price; end
	def get_keyboard_price; end
end


class Computer 
	def initialize(computer_id, data_source)
		@computer_id = computer_id
		@data_source = data_source
	end

	def mouse
		info = @data_source.get_mouse_info(@id)
		price = @data_source.get_mouse_price(@id)
		result = "Mouse: #{info} (#{price})"
		return "* #{result}" if price >= 100
		result
	end


	def cpu
		info = @data_source.get_cpu_info(@id)
		price = @data_source.get_cpu_price(@id)
		result = "Mouse: #{info} (#{price})"
		return "* #{result}" if price >= 100
		result
	end

	def keyboard
		info = @data_source.get_keyboard_info(@id)
		price = @data_source.get_keyboard_price(@id)
		result = "Mouse: #{info} (#{price})"
		return "* #{result}" if price >= 100
		result
	end
end


# First refactor attemp: use dynamic dispatch and dynamic method to dynamically define new method
# pro: reduce duplication
# con: still need to maintain the method name list with there is new component.
class Computer
	COMPONETS = [:mouse, :cpu, :keyboard]

	def initialize(computer_id, data_source)
		@computer_id = computer_id
		@data_source = data_source
	end

	COMPONETS.each do |name|
		define_method name do 
			info = @data_source.send("get_#{c}_info", @id)
			price = @data_source.send("get_#{c}_price", @id) 
			result = "#{c.to_s.capitalize}: #{info} (#{price})"
			return "* #{result}" if price >= 100
			result
		end
	end

end


# Second refactor attemp: leverage introspection to get method name
# pro: reduce duplication and free from code maintainance.
class Computer
	def initialize(computer_id, data_source)
		@computer_id = computer_id
		@data_source = data_source
		data_source.methods.grep(/^get_(.*)_info$/) { |name| Computer.define_component $1 }
	end

	def self.define_component(name)
		define_method name do 
			info = @data_source.send("get_#{name}_info", @id)
			price = @data_source.send("get_#{name}_price", @id) 
			result = "#{name.capitalize}: #{info} (#{price})"
			return "* #{result}" if price >= 100
			result
		end
	end
end


# Alternative refactor attemp: method_missing
# traps: 
# 1. respond_to? Ghost method is false
# 2. infinite loop
# 3. method clash
# 4. performance (should base on benchemark, most of time, it is no a big deal)
class Computer
	# instance_methods.each do |m|
	# 	undef_method m unless m.to_s =~ /^__|method_missing|respond_to?|object_id/
	# end

	def initialize(computer_id, data_source)
		@computer_id = computer_id
		@data_source = data_source
	end


	def method_missing(name, *args)
		super if !respond_to?(name)
		self.class.send(:define_method, name) do
			info = @data_source.send("get_#{name}_info",args[0])
			price = @data_source.send("get_#{name}_price", args[0]) 
			result = "#{name.to_s.capitalize}: #{info} (#{price})"
			return "* #{result}" if price >= 100
			result
		end
		name
	end


	def respond_to?(method)
		@data_source.respond_to?("get_#{method}_info") || super
	end

end





