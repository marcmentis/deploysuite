module Deploysuite
	class Runner
		attr_reader :v, :ev, :g, :u, :r, :encr

		def initialize(args={})
			@v = args[:validator] 
			@ev = args[:env_values] 
			@g = args[:git_proxy] 
			@u = args[:utils_proxy]
			@r = args[:rails_proxy]
			@encr = args[:encryptor]
		end

		def run_move_secret_file(host_path)
			app_name = v.get_app_name(host_path)
			file = "/rails/#{app_name}_enc_application.yml"
			final_path = "#{host_path}/config/enc_application.yml"
			u.move_secret_file(file, host_path)

			$stdout.puts Rainbow("Success: #{file} moved to #{final_path}").green
		end

		def run_set_app_privileges_ownership(host_path)
			final_deployer_group = v.get_final_deployer_group(host_path)
			u.set_app_group_ownership(host_path, final_deployer_group)
			u.set_app_permissions(host_path)
			app_name = v.get_app_name(host_path)

			$stdout.puts Rainbow("Success: Group ownership and privileges set for #{app_name}").green
		end

		# VALIDATIONS
		# Check that app directory does not exist
		def run_app_not_exist?(host_path)
			if v.app_not_exist?(host_path)
				$stdout.puts Rainbow("Success: No pre-existig app at '#{host_path}'").green
			else
				exit 1
			end
		end

		# Check that user is member of 'final_deployer_group'
		def run_in_final_deployer_group?(host_path)
			path_to_host = v.get_path_to_host(host_path)
			if v.in_final_deployer_group?(ev.user, ev.user_groups, host_path)
				$stdout.puts Rainbow("Success: '#{ev.user}' is member of '#{path_to_host}' group").green
			else
				
			end
		end

		# Check that user is member of 'deployers' group
		def run_valid_user?
			if v.valid_user?(ev.user, ev.user_groups, "railsdep")
				$stdout.puts Rainbow("Success: '#{ev.user}' is member of 'railsdep' group").green
			else
				exit 1
			end
		end

		def run_in_group?(group)
			if v.in_group?(ev.user, ev.user_groups, group)
				$stdout.puts Rainbow("Success: '#{ev.user}' has appropriate privileges").green
			end
		end

		# Check that path to app is legal
		def run_path_to_host_legal?(host_path)
			if v.path_to_host_legal?(host_path)
				path_to_host = v.get_path_to_host(host_path)
				$stdout.puts Rainbow("Success: '#{path_to_host}' is legal path for app").green
			else
				exit 1
			end
		end

		# Check that Repo exists and user has privileges
		def run_repo_exists?(repo)
			if v.repo_exists?(repo)
				$stdout.puts Rainbow("Success: '#{repo}' exists and '#{ev.user}' has privileges").green
			else
				exit 1
			end
		end

		# Check that secret_config1 file exists
		def run_secret_config1?(host_path)
			if v.secret_config1?(host_path)
				$stdout.puts Rainbow("Success: secret_config1 exists").green
			else
				exit 1
			end
		end

		def run_clone_branch(repo, host_path, ymlfiles_path)
		    git_branch = v.get_git_branch(ev.machine_name, ymlfiles_path)

		    g.clone_branch(git_branch, repo, host_path)
		    $stdout.puts Rainbow("Success: '#{repo}' cloned into '#{host_path}'").green
		end

		def run_check_pwd(host_path)
			u.check_pwd(host_path)
			$stdout.puts Rainbow("Success: 'deploysuite' run from root dir of app: '#{host_path}'").green
		end

		# def run_create_sticky_gemset(ruby_version, host_path)
		# 	host_name = v.get_app_name(host_path)
		# 	u.create_sticky_gemset(ruby_version, host_name)
		# 	$stdout.puts Rainbow("Success: Sticky RVM Gemset created for host")
		# end

		def run_bundle
			$stdout.puts Rainbow("Bundle ...").green
			r.bundle
			$stdout.puts Rainbow("Success: Production env 'bundle' command run for app").green
		end

		def run_precompile_assets
			$stdout.puts Rainbow("Precompiling assets ...").green
			r.precompile_assets
			$stdout.puts Rainbow("Success: Production env assets precompiled for app").green
		end

		def run_load_schema
			r.load_schema
			$stdout.puts Rainbow("Success: Schema loaded").green
		end

		def run_db_rollback_all_migrations
			r.db_rollback_all_migrations
			$stdout.puts Rainbow("Success: All migrations rolled back").green
		end

		def run_generate_sql_script
			r.generate_sql_script 
			$stdout.puts Rainbow("Success: SQL script for DB migrations generated").green
		end

		def run_db_structure_dump
			r.db_structure_dump
			$stdout.puts Rainbow("Success: SQL script for schema dump generated").green
		end

		def run_migrate_db
			r.migrate_db
			$stdout.puts Rainbow("Success: Database migrated").green
		end

		def run_first_commit
			g.first_commit
			$stdout.puts Rainbow("Success: First Commit performed for app").green
		end

		def run_start_application
			u.start_application
			$stdout.puts Rainbow("Success: Application restarted").green
		end

		def run_copy_structure_sql(host_path)
			user = ev.user
			app = v.get_app_name(host_path)
			u.copy_structure_sql(host_path, user, app)
			$stdout.puts Rainbow("Success: structure.sql file copied to /rails/.sql").green
		end

		def run_copy_upgrade_sql(host_path)
			user = ev.user
			app = v.get_app_name(host_path)
			u.copy_upgrade_sql(host_path, user, app)
			$stdout.puts Rainbow("Success: upgrade.sql file copied to /rails/.sql").green
		end

		def run_rspec_tests
			r.rspec_tests
			$stdout.puts Rainbow("Success: Rspec tests run").green
		end

		def run_cucumber_tests
			r.cucumber_tests
			$stdout.puts Rainbow("Success: Cucumber tests run").green
		end

		def run_clobber_assets
			r.clobber_assets
			$stdout.puts Rainbow("Success: Assets clobbered").green
		end

		def run_stash_local_changes
			g.stash_local_changes
			$stdout.puts Rainbow("Success: Local changes stashed").green
		end

		def run_fetch_branch_from_origin(ymlfiles_path)
			# git_branch = v.get_git_branch(ev.machine_name)
			git_branch = v.get_git_branch(ev.machine_name, ymlfiles_path)
			out = g.fetch_branch_from_origin(git_branch)
			if out[:stderr].include? "up to date"
				DeployLog.stderr_log.fatal {"Exit Update: This branch already up-to-date"}
				$stdout.puts Rainbow("Exit: This branch already up-to-date").green
				exit 1
			else
				$stdout.puts Rainbow("Success: fetch branch from origin").green
			end
			
		end

		def run_merge_fetched_branch(message, ymlfiles_path)
			# git_branch = v.get_git_branch(ev.machine_name)
			git_branch = v.get_git_branch(ev.machine_name, ymlfiles_path)
			g.merge_fetched_branch(git_branch, message)
			$stdout.puts Rainbow("Success: merge fetched branch").green
		end

		def run_set_owned_file_privileges(host_path)
			final_deployer_group = v.get_final_deployer_group(host_path)
			u.set_owned_file_privileges(final_deployer_group)
			$stdout.puts Rainbow("Success: privileges and grp ownership set for owned files").green
		end

		def run_make_temp_schema
			u.make_temp_schema
		end

		def run_restore_old_schema
			u.restore_old_schema
		end

		def run_copy_sqlrake_file(host_path, ymlfiles_path)
			u.copy_sqlrake_file(host_path, ymlfiles_path)
			$stdout.puts Rainbow("Success: sql.rake copied to app: #{host_path}").green
		end

		def run_remove_sqlrake_file(host_path)
			u.remove_sqlrake_file(host_path)
			$stdout.puts Rainbow("Success: sql.rake removed from app: #{host_path}").green
		end

		

		def run_encrypt_from_rails_db_yml(ymlfiles_path)
			deploy_level = v.get_machine_deployment_level(ev.machine_name, ymlfiles_path)
			encr.encrypt_from_rails_db_yml(deploy_level, ymlfiles_path)
			$stdout.puts Rainbow("Success: encrypted database file created").green
		end

		def run_change_gemfile_source(host_path)
			u.change_gemfile_source(host_path)
			$stdout.puts Rainbow("Success: Gemfile source changed").green
		end
		
			
	end
end