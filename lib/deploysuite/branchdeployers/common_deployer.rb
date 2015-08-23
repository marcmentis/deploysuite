module CommonDeployer
	attr_reader :r

	def initialize(args={})
		@r = args[:runner]
	end

	def encrypt_db(args={})
		r.run_in_group?('railsenc')
		r.run_encrypt_from_rails_db_yml(args[:ymlfiles_path])
	end

	def clone_new_app1(args={})
		r.run_in_final_deployer_group?(args[:host_path])
		r.run_path_to_host_legal?(args[:host_path])
		r.run_app_not_exist?(args[:host_path])
		r.run_repo_exists?(args[:repo])
		# r.run_secret_config1?(args[:host_path])
		r.run_clone_branch(args[:repo], args[:host_path], args[:ymlfiles_path])
		# r.run_move_secret_file(args[:host_path])
		r.run_set_app_privileges_ownership(args[:host_path])
	end

	def clone_new_app2(args={})
		r.run_check_pwd(args[:host_path])
		# r.run_change_gemfile_source(args[:host_path])
		# Add [and create] sticky gemset
		# r.run_create_sticky_gemset(args[:ruby_version], args[:host_path]) if args[:ruby_version]
			# rvm use ruby-2.0.0@<appname> --ruby-version --create
	    r.run_bundle
	      # r.run_create_deploy_level_db_params(args[:path_to_files_config])
	    r.run_precompile_assets
	    # HOOK for db functions
	    	clone_app_db_functions(args) if args[:db]	    
	    r.run_start_application
	      # r.run_destroy_deploy_level_db_params(args[:path_to_files_config])
	    r.run_first_commit
	    r.run_set_app_privileges_ownership(args[:host_path])
	    r.run_rspec_tests if args[:rspec]
	    r.run_cucumber_tests if args[:cucumber]
		
	end

	def update_app(args={})	
		r.run_check_pwd(args[:host_path])
		r.run_fetch_branch_from_origin(args[:ymlfiles_path])
		# r.run_secret_config1?(args[:host_path]) if args[:encrypted_file]
		# r.run_move_secret_file(args[:host_path]) if args[:encrypted_file]
	    r.run_clobber_assets
	    r.run_stash_local_changes	    
	    r.run_merge_fetched_branch(args[:message], args[:ymlfiles_path])
	    r.run_bundle
	    # r.run_create_deploy_level_db_params(args[:path_to_files_config])
	    r.run_precompile_assets
	    # DB HOOK
	    	update_app_db_functions(args) if args[:db]	
	    r.run_start_application
	    # r.run_destroy_deploy_level_db_params(args[:path_to_files_config])
	    r.run_set_owned_file_privileges(args[:host_path])
	    r.run_rspec_tests if args[:rspec]
	    r.run_cucumber_tests if args[:cucumber]	
	end

	def rspec(args={})
		r.run_check_pwd(args[:host_path])
	    r.run_rspec_tests
	end

	def cucumber(args={})
		r.run_check_pwd(args[:host_path])
    	r.run_cucumber_tests
	end

	def bundle(args={})
		r.run_check_pwd(args[:host_path])
		r.run_bundle
	end

	def clone_branch(args={})
		# r.run_clone_branch(args[:repo], args[:host_path])
		r.run_clone_branch(args[:repo], args[:host_path], args[:ymlfiles_path])
	end

	def db_structure_dump(args={})
		r.run_check_pwd(args[:host_path])
		r.run_db_structure_dump
	end

	def update_app_db_functions(args)
		# HOOK doesn't do anything from common_deployer
	end
	def clone_app_db_functions(args)
		# HOOK doesn't do anything from common_deployer
	end
end