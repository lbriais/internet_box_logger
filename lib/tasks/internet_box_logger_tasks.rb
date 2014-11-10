require 'tempfile'
require File.expand_path '../file.rb', __FILE__
require File.expand_path '../elastic_search.rb', __FILE__
require File.expand_path '../cron.rb', __FILE__
require File.expand_path '../kibana.rb', __FILE__


module InternetBoxLogger
  module Tasks

    def ibl_gem_path
      spec = Gem::Specification.find_by_name('internet_box_logger')
      File.expand_path "../#{spec.name}", spec.spec_dir
    end

  end
end