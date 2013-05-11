require 'pp'

class RegisterOptionsCheck < LintWorm::Check

	interesting_nodes :def

	add_callback :check_def do |node| 
		if node.children[0].to_s == "initialize" then
			
		end
	end

	def check_option(option)
		puts "xxx" + option.to_s
	end
end
