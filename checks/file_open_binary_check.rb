class FileOpenBinaryCheck < MsfLint::Check

	interesting_nodes :send

	add_callback :check_send do |node|
		check_file_open_attributes(node) 
	end


	def check_file_open_attributes(node)
		# Check if we have a call to :File
		# (send
    	# 	(const nil :File) :open
    	# 		(str "test.rb")
    	# 		(str "r")))
		return if node.children[0].nil?
		return unless node.children[0].children[1] == :File
		return unless node.children[1] == :open  

		# Okay, we are in a File.open or File.new call, however you can
		# call a File.open() without any attributes, in this case "r" is set 
		if node.children[3].nil? then
			attributes = "r"
		else
			attributes = node.children[3].children[0]
		end

		# Check if the attributes of the open call contain a "b" if not add a warning
		if not attributes.include?("b") then
			add_note(MsfLint::Note::WARNING, "File open without binary mode", node.line)
		end
	end

end
