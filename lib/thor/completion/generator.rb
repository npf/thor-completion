class Thor

  module Completion

    class Generator

      def initialize(thor, name)
        @thor = thor
        @name = name
      end

      def to_yaml
        self.to_h.to_yaml
      end

      def to_s
        self.to_a.join("\n")
      end

      def to_a
        completion_list = []
        self.to_s_rec(self.complete, @name, completion_list)
        return completion_list
      end

      def to_h
        return self.complete
      end

      def to_s_rec(completion_hash, str, completion_list)
        if completion_hash.empty?
          completion_list.push("'#{str}'")
        else
          completion_hash.each do |k,v|
            to_s_rec(v, "#{str} #{k}", completion_list)
          end
        end
      end

      def complete()
        commands = @thor.all_commands.select{|k,v| not v.hidden?}.transform_values{|v| [v, @thor]}
        parameters = []
        options = @thor.class_options.select{|kk,vv| not vv.hide}
        completions = complete_commands(commands, parameters, options).
          merge(complete_parameters(commands, parameters, options)).
          merge(complete_options(commands, parameters, options))
        return completions
      end

      def complete_commands(commands, parameters, options)
        comp = {}
        commands.each do |k,v|
          command, command_class = v
          new_commands = {}
          if command_class.subcommands.include?(k)
            subcommand_class = command_class.subcommand_classes.find{|kk,vv| kk == k}[1]
            new_commands = subcommand_class.all_commands.select{|kk,vv| not vv.hidden?}.transform_values{|vv| [vv, subcommand_class]}
            parameters = []
          else
            parameters = command_class.new.method(k).parameters
          end
          options = command.options.merge(options).select{|kk,vv| not vv.hide}
          r = str2regex(k)
          comp[r] = complete_commands(new_commands, parameters, options).
            merge(complete_parameters(new_commands, parameters, options)).
            merge(complete_options(new_commands, parameters, options))
          command_class.map.select{|kk,vv| vv.to_s == k}.each do |kk,vv|
            comp[str2regex(kk.to_s)]=comp[r]
          end
        end
        return comp
      end

      def complete_parameters(commands, parameters, options)
        comp = {}
        if parameters.any?
          p = parameters.first
          r = case p[0]
          when :opt
            #"[<#{p[1]}>]"
            %r{^[^\s]*$}
          when :rest
            #"[<#{p[1]}>[...]]"
            %r{^[^\s]+(\s+[^\s]+)*$}
          else
            #"<#{p[1]}>"
            %r{^[^\s]+$}
          end
          comp[r] = complete_commands(commands, parameters[1..-1], options).
            merge(complete_parameters(commands, parameters[1..-1], options)).
            merge(complete_options(commands, parameters[1..-1], options))
        end
        return comp
      end

      def complete_options(commands, parameters, options)
        comp = {}
        options.each do |k,v|
          h = complete_commands(commands, parameters, options.select{|kk,vv| kk != k}).
            merge(complete_parameters(commands, parameters, options.select{|kk,vv| kk != k})).
            merge(complete_options(commands, parameters, options.select{|kk,vv| kk != k}))
          ([ "--#{v.name}" ] + v.aliases).each do |o|
            if v.type == :boolean
              comp[str2regex(o)] = h
            else
              comp[str2regex(o)] = { %r{^[^\s]+$} => h }
              comp[str2regex(o, "=[^\s]+")] = h
            end
          end
        end
        return comp
      end

      def escape_char(char)
        to_escape = [ '?', '*', '+', '(', ')', '{', '}', '[', ']', '^', ':', '!', '|', '\\', '-', '\$', '#' ]
        if to_escape.include?(char)
          return "\\#{char}"
        else
          return char
        end
      end

      def str2regex(str, suffix="", regex="")
        puts "str2regex(#{str}, #{suffix}, #{regex})"
        char = escape_char(str[-1])
        if str.size == 1
          return %r{^#{char}#{regex}#{suffix}$}
        else
          str2regex(str[0..-2], suffix, "(?:#{char}#{regex})?")
        end
      end

    end

  end

end
