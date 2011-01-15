class CIJoe
  class Config
    def self.method_missing(command, *args)
      new(command, *args)
    end

    def initialize(command, parent = nil)
      @command  = command
      @parent   = parent
    end

    def method_missing(command, *args)
      Config.new(command, self)
    end

    def config_string
      @parent ? "#{@parent.config_string}_#{@command}" : @command.to_s
    end

    def to_s
      ENV[config_string] || ""
    end
  end
end
