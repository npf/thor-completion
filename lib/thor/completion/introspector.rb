class Thor
  module Completion
    # Introspection functions to retrieve the thor completions
    class Introspector
      def initialize(thor, name)
        @thor = thor
        @name = name
        build_completions
        to_a
      end

      def to_yaml
        to_h.to_yaml
      end

      def to_h
        @completions
      end

      def to_s
        to_a.join("\n")
      end

      def to_a
        completion_list = []
        to_a_rec(@completions, @name, completion_list)
        completion_list
      end

      def to_a_rec(completion_hash, str, completion_list)
        return completion_list.push("'#{str}'") if completion_hash.empty?
        completion_hash.each do |k, v|
          to_a_rec(v[:children], "#{str} #{k}", completion_list)
        end
      end

      def build_completions
        commands = @thor.all_commands.reject { |_k, v| v.hidden? }.transform_values { |v| [v, @thor] }
        parameters = []
        options = @thor.class_options.reject { |_kk, vv| vv.hide }
        completions = get_commands_rec(commands, parameters, options)
                      .merge(get_parameters_rec(commands, parameters, options))
                      .merge(get_options_rec(commands, parameters, options))
        @completions = completions
      end

      def get_commands_rec(commands, parameters, options)
        comp = {}
        commands.each do |k, v|
          command, command_class = v
          new_commands = {}
          if command_class.subcommands.include?(k)
            subcommand_class = command_class.subcommand_classes.find { |kk, _vv| kk == k }[1]
            new_commands = subcommand_class.all_commands.reject { |_kk, vv|  vv.hidden? }.transform_values do |vv|
              [vv, subcommand_class]
            end
            parameters = []
            options = command.options.reject { |_kk, vv| vv.hide }
          else
            parameters = command_class.new.method(k).parameters
            options = command.options.merge(options).reject { |_kk, vv| vv.hide }
          end
          children = get_commands_rec(new_commands, parameters, options)
                     .merge(get_parameters_rec(new_commands, parameters, options))
                     .merge(get_options_rec(new_commands, parameters, options))
          comp[k] = { regex: Completion::Regexp.build(k), children: children }
          command_class.map.select { |_kk, vv| vv.to_s == k }.each_key do |kk|
            comp[kk.to_s] = { regex: Completion::Regexp.build(kk.to_s), children: children }
          end
        end
        comp
      end

      def get_parameters_rec(commands, parameters, options)
        comp = {}
        if parameters.any?
          p = parameters.first
          r = case p[0]
              when :opt
                # "[<#{p[1]}>]"
                /^[^\s]*$/
              when :rest
                # "[<#{p[1]}>[...]]"
                /^[^\s]+(\s+[^\s]+)*$/
              else
                # "<#{p[1]}>"
                /^[^\s]+$/
              end
          comp['ARGS'] = { regex: r, children: get_commands_rec(commands, parameters[1..-1], options)
                         .merge(get_parameters_rec(commands, parameters[1..-1], options))
                         .merge(get_options_rec(commands, parameters[1..-1], options)) }
        end
        comp
      end

      def get_options_rec(commands, parameters, options)
        comp = {}
        options.each do |k, v|
          h = get_commands_rec(commands, parameters, options.reject { |kk, _vv| kk == k })
              .merge(get_parameters_rec(commands, parameters, options.reject { |kk, _vv| kk == k }))
              .merge(get_options_rec(commands, parameters, options.reject { |kk, _vv| kk == k }))
          (["--#{v.name}"] + v.aliases).each do |o|
            if v.type == :boolean
              comp[o] = { regex: Completion::Regexp.build(o), children: h }
            else
              comp[o] = { regex: Completion::Regexp.build(o), children: { /^[^\s]+$/ => { str: 'ARGS', children: h } } }
              comp["#{o}=ARGS"] = { regex: Completion::Regexp.build(o + '=', "[^\s]*"), children: h }
            end
          end
        end
        comp
      end
      private :to_a_rec, :build_completions, :get_commands_rec, :get_parameters_rec, :get_options_rec
    end
  end
end
