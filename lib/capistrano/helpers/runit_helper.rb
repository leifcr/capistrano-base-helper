module Capistrano
  module RunitHelper
    # Any command sent to this function controls _all_ services related to the app
    def runit_app_services_control(command)
      if test "[ ! -h #{runit_etc_service_app_symlink_name} ]"
        execute :sudo, :sv, "#{command} #{runit_etc_service_app_symlink_name}")
      end
    end

    # Begin - single service control functions

    # def start_service_once(service_name)
    #   control_service(service_name, "once")
    # end

    # def start_service(service_name)
    #   control_service(service_name, "start")
    # end

    # def stop_service(service_name)
    #   control_service(service_name, "stop")
    # end

    # def restart_service(service_name)
    #   control_service(service_name, "restart")
    # end

    def control_service(service_name, command, arguments, ignore_error = false)
      if test "[ ! -h #{runit_service_path(service_name)}/run ]"
        execute :sv, "#{arguments} #{command} #{runit_service_path(service_name)}"
      end
    end

    # Will not check if the service exists before trying to force it down
    def force_control_service(service_name, command, arguments, ignore_error = false)
      execute :sv, "#{arguments} #{command} #{runit_service_path(service_name)}"
    end

    def disable_service(service_name)
      force_control_service(service_name, "force-stop", "", true) # force-stop the service before disabling it
      within(runit_service_path(service_name)) do
        if test "[ ! -h ./run ]"
          execute :rm. "-f ./run"
        end
        if test "[ ! -h ./finish ]"
          execute :rm, "-f ./finish"
        end
      end
    end

    def enable_service(service_name)
      within(runit_service_path(service_name)) do
        if test "[ -h ./run ]"
          execute :ln. "-sf #{runit_service_run_config_file} ./run"
        end
        if test "[ -h ./finish ]"
          execute :ln. "-sf #{runit_service_finish_config_file} ./finish"
        end
      end
    end

    def purge_service(service_name)
      execute :rm "-rf #{runit_service_path(service_name)}"
    end

    def runit_set_executable_files(service_name)
      if test("[ -f '#{runit_service_run_config_file(service_name)}']")
        execute :chmod "u+x runit_service_run_config_file(service_name)"
        execute :chmod "g+x runit_service_run_config_file(service_name)"
      end
      if test("[ -f '#{runit_service_finish_config_file(service_name)}']")
        execute :chmod "u+x runit_service_finish_config_file(service_name)"
        execute :chmod "g+x runit_service_finish_config_file(service_name)"
      end

      if test("[ -f '#{runit_service_log_run_file(service_name)}']")
        execute :chmod "u+x runit_service_log_run_file(service_name)"
        execute :chmod "g+x runit_service_log_run_file(service_name)"
      end

      if test("[ -d '#{runit_service_control_path(service_name)}']")
        execute :chmod "u+x -R runit_service_control_path(service_name)"
        execute :chmod "g+x -R runit_service_control_path(service_name)"
      end
    end

    # End - single service control functions

    def runit_setup_log_folders_and_permissions(log_path, user = nil, group = nil)
      user  = fetch(:user) if user.nil?
      group = "syslog" if group.nil?
      # Have to sudo in case path is in /var/log
      execute :sudo, :mkdir, "-p #{log_path}"
      execute :sudo, :chown, "-R #{user}:#{group} #{log_path}"
      execute :sudo, :chmod, "u+w #{log_path}"
      execute :sudo, :chmod, "g+w #{log_path}"
    end

  end
end
