class RankingCheck < MsfLint::Check

	interesting_nodes :cdecl, :class

	add_callback :check_class do |node| 
		# Knowledge of the module type is needed to identify the requirement of a ranking

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

	add_callback :check_cdecl do |node| 

		available_ranks = [
			'ManualRanking',
			'LowRanking',
			'AverageRanking',
			'NormalRanking',
			'GoodRanking',
			'GreatRanking',
			'ExcellentRanking'
		]

		if @module_type == "Msf::Exploit" and node.children[1].to_s == "Rank" then
			ranking = node.children[2].children[1].to_s
			if not available_ranks.include?(ranking) then
				add_note(MsfLint::Note::ERROR, "Invalid ranking. You have '#{ranking}' which is a unknown ranking value", node.line)
			end

			@ranking_exists = true
		end
	end

	def check_completed
		if not @ranking_exists and @module_type == "Msf::Exploit" then
			add_note(MsfLint::Note::ERROR, "Class of type 'Msf::Exploit' but no ranking found", 0)
		end
	end

end
