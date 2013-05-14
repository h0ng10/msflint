class RegisterOptionCheck < LintWorm::Check

	interesting_nodes :def

	add_callback :check_def do |node| 
		if node.children[0].to_s == "initialize" then
			
			node.children[2].children.each do |child|
				if child.instance_of?(Parser::AST::Node) then
					if child.type.to_s == "send" then
						if child.children[1].to_s == "register_options" then
							check_options(child)
						end
					end
				end
			end
		end
	end

	def check_options(node)
		node.children[2].children.each do |option|
			if option.children[2].type.to_s == "str"
				option_name = option.children[2].children[0].upcase

				if option_name.upcase == "VERBOSE" then
					add_note(LintWorm::Note::WARNING, "VERBOSE Option is already part of advanced settings, no need to add it manually.", option.children[2].line)
				end
			end

		end
	end
end
