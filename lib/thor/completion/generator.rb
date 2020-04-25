class Thor
  module Completion
    # This is the competion generator class: it build the completion data
    class Generator
      def initialize(thor, name)
        @thor = thor
        @name = name
      end

      def to_yaml
        to_h.to_yaml
      end

      def to_s
        to_a.join("\n")
      end

      def to_a
        completion_list = []
        to_s_rec(complete, @name, completion_list)
        completion_list
      end

      def to_h
        complete
      end

      def to_s_rec(completion_hash, str, completion_list)
        if completion_hash.empty?
          completion_list.push("'#{str}'")
        else
          completion_hash.each do |k, v|
            to_s_rec(v[:children], "#{str} #{k}", completion_list)
          end
        end
      end

      def match(line, _point, _key, _type)
        words = line.split(/\s+/)[1..-1]
        words.push('') if line.match?(/\s$/)
        filter(complete, words).flatten.uniq
      end

      def filter(completions, words)
        filtered = completions.select { |_k, v| words.first.match(v[:regex]) }
        return filtered.keys if words.size == 1
        filtered.values.map { |v| filter(v[:children], words[1..-1]) }
      end

      def complete
        commands = @thor.all_commands.reject { |_k, v| v.hidden? }.transform_values { |v| [v, @thor] }
        parameters = []
        options = @thor.class_options.reject { |_kk, vv| vv.hide }
        completions = complete_commands(commands, parameters, options)
                      .merge(complete_parameters(commands, parameters, options))
                      .merge(complete_options(commands, parameters, options))
        completions
      end

      def complete_commands(commands, parameters, options)
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
          children = complete_commands(new_commands, parameters, options)
                     .merge(complete_parameters(new_commands, parameters, options))
                     .merge(complete_options(new_commands, parameters, options))
          comp[k] = { regex: str2regex(k), children: children }
          command_class.map.select { |_kk, vv| vv.to_s == k }.each_key do |kk|
            comp[kk.to_s] = { regex: str2regex(kk.to_s), children: children }
          end
        end
        comp
      end

      def complete_parameters(commands, parameters, options)
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
          comp['ARGS'] = { regex: r, children: complete_commands(commands, parameters[1..-1], options)
                         .merge(complete_parameters(commands, parameters[1..-1], options))
                         .merge(complete_options(commands, parameters[1..-1], options)) }
        end
        comp
      end

      def complete_options(commands, parameters, options)
        comp = {}
        options.each do |k, v|
          h = complete_commands(commands, parameters, options.reject { |kk, _vv| kk == k })
              .merge(complete_parameters(commands, parameters, options.reject { |kk, _vv| kk == k }))
              .merge(complete_options(commands, parameters, options.reject { |kk, _vv| kk == k }))
          (["--#{v.name}"] + v.aliases).each do |o|
            if v.type == :boolean
              comp[o] = { regex: str2regex(o), children: h }
            else
              comp[o] = { regex: str2regex(o), children: { /^[^\s]+$/ => { str: 'ARGS', children: h } } }
              comp["#{o}=ARGS"] = { regex: str2regex(o + '=', "[^\s]*"), children: h }
            end
          end
        end
        comp
      end

      def escape_char(char)
        to_escape = ['?', '*', '+', '(', ')', '{', '}', '[', ']', '^', ':', '!', '|', '\\', '-', '\$', '#']
        return "\\#{char}" if to_escape.include?(char)
        char
      end

      def str2regex(str, regex = '')
        if str.empty?
          /^#{regex}$/
        else
          char = escape_char(str[-1])
          str2regex(str[0..-2], "(?:#{char}#{regex})?")
        end
      end
    end
  end
end
