module Capistrano
  module DSL
    ##
    # Base paths and filenames/folder names for both runit and monit
    #
    module BasePaths
      # user_app_env_path in basehelper 0.x / capistrano 2.x version

      def app_env_folder
        "#{fetch(:application)}_#{environment}"
      end

      def user_app_env_file_name
        "#{fetch(:user)}_#{fetch(:application)}_#{environment}"
      end
    end
  end
end
