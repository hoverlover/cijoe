class CIJoe
  class Config
    def self.method_missing(command, *args)
      new(command, *args)
    end

    def initialize(command, project_path = nil, parent = nil)
      @command  = command
      @parent   = parent
      @project_path = project_path || File.join(File.dirname(__FILE__), '../../')
    end

    def method_missing(command, *args)
      Config.new(command, @project_path, self)
    end

    def config_string
      @parent ? "#{@parent.config_string}_#{@command}" : @command.to_s
    end

    def to_s
      ENV[config_string] || ""
    end
  end
end
