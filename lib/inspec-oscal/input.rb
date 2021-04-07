require "json"

# See https://github.com/inspec/inspec/blob/master/docs/dev/plugins.md#implementing-input-plugins

module InspecPlugins::Oscal
  class Input < Inspec.plugin(2, :input)

    attr_reader :extension_schema_path
    attr_reader :extension_schema
    attr_reader :model_path
    attr_reader :model
    attr_reader :priority
    attr_reader :logger

    def initialize
      @plugin_conf = Inspec::Config.cached.fetch_plugin_config("inspec-oscal")

      @logger = Inspec::Log
      logger.debug format("inspec-oscal plugin version %s", VERSION)

      @extension_schema_path = fetch_plugin_setting("extension_schema_path", "extension.json")
      @model_path = fetch_plugin_setting("model_path", "component.json")

      fd = open(extension_schema_path)
      @extension_schema = JSON.parse(fd.read)

      fd = open(model_path)
      @model_path = JSON.parse(fd.read)
    end

    # What priority should an input value recieve from us?
    # This plgin does not currently allow setting this on a per-input basis,
    # so they all recieve the same "default" value.
    # Implements https://github.com/inspec/inspec/blob/master/docs/dev/plugins.md#default_priority
    def default_priority
      priority
    end

    def list_inputs
        
    end

    def namespace
        @extension_schema
            .fetch('11extensions', {})
            .fetch('extension-namespace', {})
            .fetch('ns', {})
    end

  end
end
