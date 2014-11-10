class File

  def self.is_executable?(filename)
    real_name = nil
    if exists?(filename)
      real_name = filename
    else
      ENV['PATH'].split(':').each do |d|
        f = join(d, filename)
        if exists? f
          real_name = f
          break
        end
      end
    end
    return nil if real_name.nil? || real_name.empty?
    executable_real?(real_name) ? real_name : false
  end

  def self.exists_in_path?(filename)
    ENV['PATH'].split(':').collect do |d|
      Dir.entries d if Dir.exists? d
    end.flatten.include?(filename) ? filename : false
  end

end