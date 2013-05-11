class LoadUsageCheck < LintWorm::Check

	interesting_nodes :send

	# A call to load looks as follows
	#
	#  (send nil :load
	#    (str "base64"))

	add_callback :check_send do |node|
		if node.children[0].nil? and node.children[1] == :load then
			puts "load detected"
			puts node.line
		end
	end
end
