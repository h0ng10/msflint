class NameCheck < MsfLint::Check

	interesting_nodes :def, :lvasgn, :ivasgn

	add_callback :check_def do |node| 
		check_name(node.children[0].to_s, "method", node.line)
	end

	add_callback :check_lvasgn do |node| 
		check_name(node.children[0].to_s, "local variable", node.line)
	end

	add_callback :check_ivasgn do |node| 
		check_name(node.children[0].to_s, "class variable", node.line)
	end

	def check_name(name, type, line)
		if name !~ /^[_a-z<>=@\[|+-\/\*`]+[_a-z0-9_<>=~@\[\]]*[=!\?]?$/ then
			add_note(MsfLint::Note::WARNING, "Bad naming style for #{type}: '#{name}'", line)
		end
	end
end
