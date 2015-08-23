module Deploysuite
	class RailsProxy
		include CommandlineExecuter

		def bundle
			# cmd = "bundle --without development test"
			cmd = "bundle --local --path vendor/bundle --without development test"
			open3method(cmd, 'out')
		end

		def precompile_assets
			cmd = "RAILS_ENV=production bundle exec rake assets:precompile"
			open3method(cmd, 'out')	
		end

		def load_schema
			cmd = "bundle exec rake db:schema:load RAILS_ENV=production"
			open3method(cmd, 'out')
		end

		def migrate_db
			cmd = "bundle exec rake db:migrate RAILS_ENV=production"
			open3method(cmd, 'out')
		end

		def generate_sql_script
			cmd = "bundle exec rake db:migrate:to_sql RAILS_ENV=production"
			open3method(cmd, 'out')
		end

		def db_structure_dump
			cmd = "bundle exec rake db:structure:dump RAILS_ENV=production"
			open3method(cmd)
		end

		def db_rollback_all_migrations			
			cmd = "bundle exec rake db:migrate VERSION=0 RAILS_ENV=production"
			open3method(cmd)			
		end

		def rspec_tests
			cmd = "bundle exec rspec spec --color --format documentation"
			open3method(cmd, 'out')
		end

		def cucumber_tests
			# cmd = bundle exec rake features - PUT GLI CODE INTO APP
			cmd = "bundle exec cucumber"
			open3method(cmd, 'out')
		end

		def clobber_assets
			cmd = "bundle exec rake assets:clobber RAILS_ENV=production"
			open3method(cmd, 'out')
		end
	end
end