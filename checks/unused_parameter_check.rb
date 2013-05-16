class UnusedParameterCheck < MsfLint::Check

	interesting_nodes :def

	add_callback :check_def do |node| 
		
		# Because of the nature of metasploit modules, unused parameters for certain methods are quite
		# common, for example run_host(ip) for Auxiliary modules, even if the ip is not used by the scanner
		# we try to identify/block some of these methods

		common_msf_methods = ["run_host", "on_request_uri"]

		method_name = node.children[0].to_s

		if not common_msf_methods.include?(method_name) then 
			@param_names = Hash.new
		
			# First we collect the names of the variables in the method definition
			param_nodes = node.children[1].children
			param_nodes.each {|param_node| @param_names[param_node.children[0].to_s] = 0 }
		
			# Step through each child node of the function searching for lvalues
			check_param_usage(node)

			# Check how often a parameter variable was called 
			@param_names.each do |param_name, param_counter|
				next if param_name == "opts"	# we ignore 'opts' as it is so common and false positives are possible.
				add_note(MsfLint::Note::WARNING, "Parameter '#{param_name}' is not used in the method #{method_name}", node.line) if param_counter == 0
			end
		end

	end

	def check_param_usage(node)
		if node.instance_of?(Parser::AST::Node) then
				
			if node.type.to_s == "lvar" then
				lvar_name = node.children[0].to_s
				@param_names[lvar_name] += 1 if @param_names.has_key?(lvar_name) 
			end

			node.children.each do |child_node|
				if child_node.instance_of?(Parser::AST::Node) then
					check_param_usage(child_node)
				end
			end
		end
	end
end
