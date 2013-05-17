module MsfLint

	# A Check class that takes care of checking the AST node
	class Check

		def interesting_nodes
			self.class.interesting_nodes
		end


		# can be called after the file has been checked, to test complex scenarios
		def check_completed
		end
		# delegate to check_### according to the sexp_type, like
		#
		#     check_call
		#     check_def
		#
		# @param [Ast::Node] node
		def check_node(node)
			@node = node
			self.class.get_callbacks("check_#{node.type}".to_sym).each do |block|
				self.instance_exec(node, &block)
			end
		end

		# check for each code line for style checks that can't be done via AST:Nodes
		# for example checks for tabs, etc.
		# 
		#
		# @param [string] filename
		# @param [int] line_number
		# @oaram [string] line_content
		def check_line(filename, line_number, line_content)
		end



		# add a note (error/warning/info message).
		#
		# @param [String] severity, the severity of the note
		# @param [String] message, the message of the note
		# @param [Integer] line_number, is the line number of the source code which is reviewing
		def add_note(severity, message, line_number)
			notes << Note.new(severity, message, line_number)
		end

		# all check marks.
		def notes
			@notes ||= []
		end

		class <<self
			def interesting_nodes(*nodes)
				@interesting_nodes ||= []
				@interesting_nodes += nodes
			end

			def add_callback(*names, &block)
				names.each do |name|
					callbacks[name] ||= []
					callbacks[name] << block
				end
			end

			def get_callbacks(name)
				callbacks[name] ||= []
				callbacks[name]
			end

			 def callbacks
				@callbacks ||= {}
			end
		end
	end
end
