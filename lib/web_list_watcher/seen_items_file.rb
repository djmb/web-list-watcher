module WebListWatcher
  class SeenItemsFile
    def initialize(data_directory, id)
      @file_name = "#{data_directory}/#{id}.seen"
    end

    def load
      File.exists?(@file_name) ?
          Set.new(IO.readlines(@file_name).collect {|x| x.strip}) :
          nil
    end

    def save(items)
      File.open(@file_name, 'w') {|f| f.write(items.to_a.sort.join("\n")) }
    end
  end
end