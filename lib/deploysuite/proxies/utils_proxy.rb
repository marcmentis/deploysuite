module Deploysuite
	class UtilsProxy
		include CommandlineExecuter
		include ConfigValues

		def check_pwd(host_path)
			pwd = `pwd`.chomp
			unless pwd == host_path
				DeployLog.stderr_log.fatal {"ERROR: Need to run 'deploysuite' from within app root: '#{host_path}'"}
				STDERR.puts Rainbow("ERROR: Need to run 'deploysuite' from within app root: '#{host_path}'").red
				exit 1
			end
		end

		def start_application
			cmd = "touch tmp/restart.txt"
			open3method(cmd)	
		end

		def move_secret_file(file, host_path)
			final_path = "#{host_path}/config/enc_application.yml"
			cmd = "mv #{file} #{final_path}"
			open3method(cmd)
		
		    return "Success: method completed"
		end

		def set_app_group_ownership(host_path, final_deployer_group)
			cmd = "chown -R :#{final_deployer_group} #{host_path}"
			open3method(cmd)
		end

		def set_app_permissions(host_path)
			cmd = "chmod -R 775 #{host_path}"
			open3method(cmd)
		end

		def set_owned_file_privileges(final_deployer_group)
			# ENTER HIDDEN DIRECTORY .GIT. Then need to recursively enter .git's NON-HIDDEN directories
				# Pass the name of the file to 'File.owned?' Will return true if the effective user ID of the
					# process is the same as the owner of the named file. This is a way of ensuring that the
					# user has the privileges to change the name of the file, and will change all of Their files.
					# Importantly, will change any NEWLY CREATED FILES that may need changing.
			Dir.glob('.git/**/*') do |f|
				change_priv_if_owned(f, final_deployer_group)
			end				
			# DOES NOT ENTER HIDDEN DIRECTORITES
			Dir.glob('**/*') do |f|
				change_priv_if_owned(f, final_deployer_group)
			end
		end

		def make_temp_schema
			cmd = "cp db/schema.rb db/orig_schema.rb"
			open3method(cmd)
		end

		def restore_old_schema
			cmd = "mv db/orig_schema.rb db/schema.rb"
			open3method(cmd)
		end

		def change_priv_if_owned(f, deployergroup)
			if File.owned?(f)
					cmd = "chown :#{deployergroup} #{f}"
					open3method(cmd)

					cmd = "chmod 775 #{f}"
					open3method(cmd)

					# `chown :#{deployergroup} #{f} 1> out.txt 2> err.txt`

					# `chmod 775 #{f} 1> out.txt 2> err.txt`
			end
		end

		def copy_sqlrake_file(host_path, ymlfiles_path)
			# Get paths to relevant db management files
			ymlfiles = YAML.load(File.read(ymlfiles_path))
			sql_rake = ymlfiles[:paths][:sql_rake]
			final_path = "#{host_path}/lib/tasks/sql.rake"
			cmd = "cp #{sql_rake} #{final_path}"
			open3method(cmd)
		end

		def remove_sqlrake_file(host_path)
			final_path = "#{host_path}/lib/tasks/sql.rake"
			cmd = "rm #{final_path}"
			open3method(cmd)
		end

		def change_gemfile_source(host_path)
			gemfile = "#{host_path}/Gemfile"

			text = File.read(gemfile)
			new_contents = text.sub!("source 'https://rubygems.org'", "source 'http://rubygems.org'")

			File.open(gemfile, "w") do |f| 
				f.puts new_contents
			end			
		end

		def copy_structure_sql(host_path, user, app)
			time = Time.new
			now = time.strftime("%Y-%m-%d_%H:%M:%S")
			final_path = "/rails/.sql/#{app}_#{user}_#{now}_structure.sql"
			cmd = "cp #{host_path}/db/structure.sql #{final_path}"
			open3method(cmd)
		end

		def copy_upgrade_sql(host_path, user, app)
			time = Time.new
			now = time.strftime("%Y-%m-%d_%H:%M:%S")
			final_path = "/rails/.sql/#{app}_#{user}_#{now}_upgrade.sql"
			cmd = "cp #{host_path}/upgrade.sql #{final_path}"
			open3method(cmd)
		end

		# def create_sticky_gemset(ruby_version, host_name)
		# 	# cmd = "rvm use ruby-#{ruby_version}@#{host_name} --ruby-version --create"
		# 	# open3method(cmd, 'out')	
		# 	`rvm use ruby-#{ruby_version}@#{host_name} --ruby-version --create`	
		# end
	end
end