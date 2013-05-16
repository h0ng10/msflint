class EmptyRescueCheck < MsfLint::Check

	interesting_nodes :resbody

	add_callback :check_resbody do |node| 

		# A rescue body looks like this
		#
		# (resbody
        #   (array
        #     (const nil :Exception))
        #   (lvasgn :ee)
        #   (send nil :puts
        #     (str "error"))) nil)))
		#
		#  So the rescue body is returned as array on children[2].children
		#  if the array is empty we don't have a rescue body
 		#

 		# there are some special conditions like calling "next" which we want
 		# to ignore

		bypass_nodes = [:next]

		if node.children[2].children.size == 0

			add_note(MsfLint::Note::WARNING, "Empty rescue body found.", node.line)
		end 
	end
end
