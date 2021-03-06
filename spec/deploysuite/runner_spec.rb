require "spec_helper"

module Deploysuite
	describe Runner do

		context "Outgoing message from Runner to RailsProxy to:" do
			before(:each) do
				@RailsProxy = double()  # RailsProxy object
				# Pass RailsProxy double into Runner
					#Runner takes any arg & uses dependency injection			
				@r = Runner.new(rails_proxy: @RailsProxy) 
				
			end
			
			it "perform bundle command in production env" do				
				@RailsProxy.stub(:bundle)
				@r.run_bundle()
			end


			it "precompile assets in production environment" do
				@RailsProxy.stub(:precompile_assets)
				@r.run_precompile_assets()
			end

			it "load db schema" do
				@RailsProxy.stub(:load_schema)
				@r.run_load_schema()
			end

			it "generate SQL script for migration" do
				@RailsProxy.stub(:generate_sql_script)
				@r.run_generate_sql_script()
			end

			it "generate SQL script for schema" do
				@RailsProxy.stub(:db_structure_dump)
				@r.run_db_structure_dump
			end

			it "run rspec tests" do
				@RailsProxy.stub(:rspec_tests)
				@r.run_rspec_tests
			end

			it "run cucumber tests" do
				@RailsProxy.stub(:cucumber_tests)
				@r.run_cucumber_tests
			end

			it "clobbers assets" do
				@RailsProxy.stub(:clobber_assets)
				@r.run_clobber_assets
			end
		end

		context "Outgoing message from Runner to GitProxy to:" do
			before(:each) do
				@GitProxy = double()  # GitProxy object
				# Pass GitProxy double into Runner
					#Runner takes any arg & uses dependency injection			
				@r = Runner.new(git_proxy: @GitProxy) 
			end
			it "perform first commit" do
				@GitProxy.stub(:first_commit)
				@r.run_first_commit()
			end

			it "clone the appropriate branch" do
				@GitProxy.stub(:clone_branch)
				v = double()
				v.stub(:get_git_branch)
				
				r = Runner.new(git_proxy: @GitProxy, validator: v, env_values: EnvValues.new)
				r.run_clone_branch('stub-repo', 'stub-host_path', 'stub-ymlfiles_path')
			end
		end

		context "Outgoing message from Runner to UtilProxy to:" do
			before(:each) do
				@UtilsProxy = double()  #UtilProxy object
				@r = Runner.new(utils_proxy: @UtilsProxy)
			end
			it "(re)start application" do
				@UtilsProxy.stub(:start_application)
				@r.run_start_application()
			end
			it "change gemfile source" do
				@UtilsProxy.stub(:change_gemfile_source)
				@r.run_change_gemfile_source('stub-host_path')
			end
			it "copy structure.sql to change SQL folder" do
				# exists in root/db/structure.sql
				@UtilsProxy.stub(:copy_structure_sql)
				@env_values.stub(:user)
				@validator.stub(:get_app_name)
				@r.run_copy_structure_sql('stub_host_path')

			end
			it "copy upgrade.sql to change SQL folder" do
				# exists in <railsroot/upgrade.sql
				@UtilsProxy.stub(:copy_update_sql)
				@env_values.stub(:user)
				@validator.stub(:get_app_name)
				@r.run_copy_update_sql('stub_host_path')
			end
			
			# it "create sticky gemset" do
			# 	v = double()
			# 	v.stub(:get_app_name)
			# 	@UtilsProxy.stub(:create_sticky_gemset)
			# 	r = Runner.new(utils_proxy: @UtilsProxy, validator: v)
			# 	r.run_create_sticky_gemset('ruby_version', 'host_path')
			# end
		end	

		# context "Outgoing message from Runner to EncProxy" do
		# 	before(:each) do
		# 		@EncProxy = double()
		# 		@r = Runner.new(enc_proxy: @EncProxy)
		# 	end	
		# 	it "gets encoding parameters" do
		# 		@EncProxy.stub(:get_enc_params)
		# 		@r.run_get_enc_params('file')
		# 	end
		# end	
		
	end
end