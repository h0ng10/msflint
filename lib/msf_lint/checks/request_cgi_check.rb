class RequestCgiCheck < MsfLint::Check

	interesting_nodes :send

	add_callback :check_send do |node| 
	
		if node.children[1].to_s == "send_request_cgi" then
			if node.children[2].type == :hash then

				args = Hash.new
				node.children[2].children.each do |pair|

					name  = pair.children[0].children[0].to_s
					value = pair.children[1].children[0].to_s

					args[name] = value
				end

				if args['method'].nil?
					add_note(MsfLint::Note::WARNING, "For convenience, please set the 'method' key to 'GET'", node.line)
				else
					if args['method'].upcase == "POST" and args.has_key?('data')
						add_note(MsfLint::Note::SUGGESTION, "Use 'vars_post' key instead of 'data', unless you're trying to avoid the API escaping your parameter names", node.line)
					end

					if args['method'].upcase == "GET" and args.has_key?('data')
						add_note(MsfLint::Note::SUGGESTION, "Use 'vars_get' key instead of 'data', unless you're trying to avoid the API escaping your parameter names", node.line)
					end
				end
			end
		end
	end
end
