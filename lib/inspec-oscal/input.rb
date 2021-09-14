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

      # The schema is currently disabled for simplicity and due to a lack of use by implementers
      # extension_schema_path = fetch_plugin_setting("extension_schema_path", "extension.json")
      # @extension_schema = JSON.parse(open(extension_schema_path).read)

      model_path = fetch_plugin_setting("model_path")

      return unless model_path

      @model = JSON.parse(open(model_path).read)

      props_json_path = JsonPath.new("$..components..control-implementations..implemented-requirements..props[?(@.ns==#{namespace})]")
      @component_props = props_json_path.on(@model).flatten

      set_parameters_json_path = JsonPath.new('$..components..control-implementations..implemented-requirements..set-parameters')

      component_set_params_result = set_parameters_json_path.on(@model)
      @component_set_params = if component_set_params_result.is_a?(Hash)
                                component_set_params_result.reduce({}, :merge)
                              else
                                component_set_params_result.flatten.map do |params|
                                  [params['param-id'], (params['values'].length.eql?(1) ? params['values'].first : params['values'])]
                                end.to_h
                              end
  end

    # Given a profile name, list all input names for which the plugin
    # would offer a response.
    def list_inputs(_profile)
      @component_props&.map { |obj| obj['class'] } || []
    end

    def namespace
      'https://mitre.org/ns/inspec'
    end

    def fetch(profile_name, input_name)
      return unless @component_props

      results = @component_props.select { |obj| obj['class'] == input_name }
      if results.length > 0
        result = results.first
        resolved_result = resolve_references(results.first['value'])
        return convert_to_type(resolved_result, result['remarks'])
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

    # Converts the resolved input into the type provided in remarks, defaulting to passing the value through
    # with no modification
    def convert_to_type(input, type)
      case type
      when "integer"
        return input.to_i
      when "array"
        return JSON.load(input)
      else
        return input
      end
    end

    def fetch_plugin_setting(setting_name, default = nil)
      env_var_name = "INSPEC_OSCAL_#{setting_name.upcase}"
      ENV[env_var_name] || plugin_conf[setting_name] || default
    end
  end
end
