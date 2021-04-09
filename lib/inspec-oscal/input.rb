require "json"
require "jsonpath"

# See https://github.com/inspec/inspec/blob/master/docs/dev/plugins.md#implementing-input-plugins

module InspecPlugins::Oscal
  class Input < Inspec.plugin(2, :input)

    attr_reader :plugin_conf
    attr_reader :extension_schema
    attr_reader :model_path
    attr_reader :model
    attr_reader :priority
    attr_reader :logger
    attr_reader :component_props
    attr_reader :component_set_params

    def initialize
      @plugin_conf = Inspec::Config.cached.fetch_plugin_config("inspec-oscal")

      @logger = Inspec::Log
      logger.debug format("inspec-oscal plugin version %s", VERSION)

      extension_schema_path = fetch_plugin_setting("extension_schema_path", "extension.json")
      @extension_schema = JSON.parse(open(extension_schema_path).read)

      model_path = fetch_plugin_setting("model_path", "component.json")
      @model = JSON.parse(open(model_path).read)

      props_json_path = JsonPath.new("$..components..control-implementations..implemented-requirements..props[?(@.ns==#{namespace})][?(@.name==inspec)]")
      @component_props = props_json_path.on(@model).flatten

      set_parameters_json_path = JsonPath.new('$..components..control-implementations..implemented-requirements..set-parameters')
      @component_set_params = set_parameters_json_path.on(@model).reduce({}, :merge)
    end

    def list_inputs
      @extension_schema.fetch('extensions', {})
    end

    def namespace
      @extension_schema.dig('extensions', 'extension-namespace', 'ns') || '*'
    end

    def fetch(profile_name, input_name)
      results = @component_props.select { |obj| obj['class'] == input_name }
      if results.length == 1
        return resolve_references(results.first['value'])
      end
    end

    private

    def resolve_references(variable_or_value)
      if @component_set_params.has_key?(variable_or_value)
        return @component_set_params[variable_or_value]['value']
      else # No matching component_set_params found, isn't a variable, just return the value
        return variable_or_value
      end
    end

    def fetch_plugin_setting(setting_name, default = nil)
      env_var_name = "INSPEC_OSCAL_#{setting_name.upcase}"
      ENV[env_var_name] || plugin_conf[setting_name] || default
    end

    def fetch_vault_setting(setting_name)
      ENV[setting_name.upcase] || plugin_conf[setting_name]
    end
  end
end
