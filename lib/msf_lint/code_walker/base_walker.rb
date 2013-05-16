# encoding: utf-8
module MsfLint::CodeWalker

	# Base class for a test case.
	class BaseWalker
		def initialize(options={})
			@checks = options[:checks]
		end

		def notes
			@notes ||= @checks.map(&:notes).flatten
		end
	end
end
