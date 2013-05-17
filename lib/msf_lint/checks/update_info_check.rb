class UpdateInfoCheck < MsfLint::Check

	interesting_nodes :super, :class


	add_callback :check_class do |node|
		# Knowledge of the module type is required for check_bad_terms and other stuff
		# we try to determine the module

		begin
			base = node.children[1].children[0]
			@module_type = ""

			@module_type += base.children[0].children[1].to_s
			@module_type += "::"
			@module_type += base.children[1].to_s
		rescue
			@module_type = "unkown"
		end
	end

	add_callback :check_super do |node|

		# check if we have a metasploit module, otherwise quit
		supported_module_types = ["Msf::Exploit", "Msf::Auxiliary", "Msf::Encoder", "Msf::Exploit", "Msf::Nop", "Msf::Post" ]

		if supported_module_types.include?(@module_type)
			# Some basic quecks, if we fail, we quit
			if node.children.size > 0
				method_call_node = node.children[0]

				# Check if we are directly talking to a hash
				if method_call_node.type.to_s == "hash" then
					add_note(MsfLint::Note::ERROR, "Call to update_info is missing, hash is passed directly", method_call_node.line)
					update_info_hash = method_call_node
				else

					# check if we are talking about update_info
					if method_call_node.children[1].to_s == "update_info" and method_call_node.children[3].nil? == false then
						update_info_hash = method_call_node.children[3] 
					end
				end

				# Hmm, seems like there is no hash, that is superstrange
				if update_info_hash.nil?
					add_note(MsfLint::Note::ERROR, "No call to update_info or hash found.", method_call_node.line)	
				else
					# It seems that we really have a hash from update_info
					# Lets do some checks on it
					check_reference_identifier(update_info_hash)
					check_author_names(update_info_hash)
					check_title_casing(update_info_hash)
					check_title_badchars(update_info_hash)
					check_bad_terms(update_info_hash)
					check_disclosure_date(update_info_hash)
				end
			end
		end
	end


	def check_disclosure_date(hash_node)
		return if @module_type != "Msf::Exploit"
		disclosure_node = find_hash_entry(hash_node, "DisclosureDate")
		if disclosure_node.nil? then
			add_note(MsfLint::Note::ERROR, "Exploit is missing a disclosure date", hash_node.line)
		else

			date = disclosure_node.children[0]

			#Flag if overall format is wrong
			if date =~ /^... \d{1,2}\,* \d{4}/
            	# Flag if month format is wrong
				month= date.split[0]
				months = [
					'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
					'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
				]

				add_note(MsfLint::Note::ERROR, "Incorrect disclosure month format: #{date}", disclosure_node.line) if months.index(month).nil?
			else
				add_note(MsfLint::Note::ERROR, "Incorrect disclosure date format: #{date}", disclosure_node.line)
			end
		end
	end

	def check_title_badchars(hash_node)
		title_node = find_hash_entry(hash_node, "Name")
		title = title_node.children[0]

		badchars = %Q|&<=>|
		title.each_char do |c|
			if badchars.include?(c)
				add_note(MsfLint::Note::ERROR, "'#{c}' is a bad character in module title.", title_node.line)
			end
		end	
	end


	def check_title_casing(hash_node)
		title_node = find_hash_entry(hash_node, "Name")
		title = title_node.children[0]

		words = title.split
			words.each do |word|
				if %w{and or the for to in of as with a an on at via}.include?(word)
					next
 				elsif %w{pbot}.include?(word)
				elsif word =~ /^[a-z]+$/
					add_note(MsfLint::Note::WARNING, "Improper capitalization in module title: '#{word}'", title_node.line)
				end
			end
	end

	def check_bad_terms(hash_node)
		# "Stack overflow" vs "Stack buffer overflow" - See explanation:
		# http://blogs.technet.com/b/srd/archive/2009/01/28/stack-overflow-stack-exhaustion-not-the-same-as-stack-buffer-overflow.aspx
		
		# Module name first
		name_node = find_hash_entry(hash_node, "Name")
		name= name_node.children[0]

		if name =~ /stack[[:space:]]+overflow/i and @module_type == "Msf::Exploit" then
			add_note(MsfLint::Note::WARNING, "Title contains \"stack overflow\" You mean \"stack buffer overflow\"?", title_node.line) 
		end

		if name =~ /stack[[:space:]]+overflow/i and @module_type == "Msf::Auxiliary" then
			add_note(MsfLint::Note::WARNING, "Title contains \"stack overflow\" You mean \"stack exhaustion\"?", title_node.line) 
		end

		# Description next
		description_node = find_hash_entry(hash_node, "Description")

		if description_node.nil? 
			add_note(MsfLint::Note::WARNING, "No module description found", hash_node.line)
			return
		end

		# Have we a single node
		if description_node.type == :str
			if description_node.children[0] =~ /stack[[:space:]]+overflow/i and @module_type == "Msf::Exploit" then
				add_note(MsfLint::Note::WARNING, "Description contains \"stack overflow\" You mean \"stack buffer overflow\"?", description_node.line) 
			end

			if description_node.children[0] =~ /stack[[:space:]]+overflow/i and @module_type == "Msf::Auxiliary" then
				add_note(MsfLint::Note::WARNING, "Description contains \"stack overflow\" You mean \"stack exhaustion\"?", description_node.line) 
			end

		# No, we have an multi-line array
		else	
			description_node.children.each do |child|

				if child.children[0] =~ /stack[[:space:]]+overflow/i and @module_type == "Msf::Exploit" then
					add_note(MsfLint::Note::WARNING, "Description contains \"stack overflow\" You mean \"stack buffer overflow\"?", child.line) 
				end

				if child.children[0] =~ /stack[[:space:]]+overflow/i and @module_type == "Msf::Auxiliary" then
					add_note(MsfLint::Note::WARNING, "Description contains \"stack overflow\" You mean \"stack exhaustion\"?", child.line) 
				end
			end
		end

	end

	def check_author_names(hash_node)
		authors_node = find_hash_entry(hash_node, "Author")
		authors = Hash.new
		
		# Authors can be an string or an array (for multiple authors)
		# So we create a hash from the code line and the name
		if authors_node.type == :array then 
			authors_node.children.each { |entry| authors[entry.line] = entry.children[0]  } 
		else
			authors[authors_node.line] = authors_node.children[0]
		end

		authors.each do |line, author_name|
			add_note(MsfLint::Note::WARNING, "No Twitter handles, please. Try leaving it in a comment instead", line) if author_name =~ /^@.+$/
			add_note(MsfLint::Note::WARNING, "Please avoid unicode or non-printable characters in Author", line) if not author_name.ascii_only?
		end
	end


	def check_reference_identifier(hash_node)
		references = find_hash_entry(hash_node, "References")
		return if references.nil?

		# step through the array
		references.children.each do |ref|

			begin
				identifier = ref.children[0].children[0]
				value = ref.children[1].children[0]
			rescue
				add_note(MsfLint::Note::ERROR, "Error parsing references which is very strange, plase review manually", ref.line)
			end


			case identifier
			when 'CVE'
				add_note(MsfLint::Note::WARNING, "Invalid CVE format: '#{value}'", ref.line) if value !~ /^\d{4}\-\d{4}$/
			when 'OSVDB'
				add_note(MsfLint::Note::WARNING, "Invalid OSVDB format: '#{value}'", ref.line) if value !~ /^\d+$/
			when 'BID'
				add_note(MsfLint::Note::WARNING, "Invalid BID format: '#{value}'", ref.line) if value !~ /^\d+$/
			when 'MSB'
				add_note(MsfLint::Note::WARNING, "Invalid MSB format: '#{value}'", ref.line) if value !~ /^MS\d+\-\d+$/
			when 'MIL'
				add_note(MsfLint::Note::WARNING, "milw0rm references are no longer supported", ref.line) if value !~ /^\d+$/
			when 'EDB'
				add_note(MsfLint::Note::WARNING, "Invalid EDB reference: '#{value}'", ref.line) if value !~ /^\d+$/
			when 'WVE'
				add_note(MsfLint::Note::WARNING, "Invalid WVE reference: '#{value}'", ref.line) if value !~ /^\d+\-\d+$/
			when 'US-CERT-VU'
				add_note(MsfLint::Note::WARNING, "Invalid US-CERT-VU reference '#{value}'", ref.line) if value !~ /^\d+$/
			when 'URL'
				if value =~ /^http:\/\/www\.osvdb\.org/
					add_note(MsfLint::Note::WARNING, "Please use 'OSVDB' for '#{value}'", ref.line) 
				elsif value =~ /^http:\/\/cvedetails\.com\/cve/
					add_note(MsfLint::Note::WARNING, "Please use 'CVE' for '#{value}'", ref.line) 
				elsif value =~ /^http:\/\/www\.securityfocus\.com\/bid\//
					add_note(MsfLint::Note::WARNING, "Please use 'BID' for '#{value}'", ref.line) 
				elsif value =~ /^http:\/\/www\.microsoft\.com\/technet\/security\/bulletin\//
					add_note(MsfLint::Note::WARNING, "Please use 'MSB' for '#{value}'", ref.line) 
				elsif value =~ /^http:\/\/www\.exploit\-db\.com\/exploits\//
					add_note(MsfLint::Note::WARNING, "Please use 'EDB' for '#{value}'", ref.line) 
				elsif value =~ /^http:\/\/www\.wirelessve\.org\/entries\/show\/WVE\-/
					add_note(MsfLint::Note::WARNING, "Please use 'WVE' for '#{value}'", ref.line) 
				elsif value =~ /^http:\/\/www\.kb\.cert\.org\/vuls\/id\//
					add_note(MsfLint::Note::WARNING, "Please use 'US-CERT-VU' for '#{value}'", ref.line) 
				end
			end
		end
	end



	def find_hash_entry(hash_node, key)
		return if hash_node.type != :hash

		hash_node.children.each do |pair|

			# Check if we have the value with the right key
			if pair.children[0].children[0] == key then
				return pair.children[1]
			end
		end

		# We didn't find anything
		return nil

	end

end
