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
          comp[k] = complete_commands(new_commands, parameters, options).
            merge(complete_parameters(new_commands, parameters, options)).
            merge(complete_options(new_commands, parameters, options))
          command_class.map.select{|kk,vv| vv.to_s == k}.each do |kk,vv|
            comp[kk.to_s]=comp[k]
          end
        end
        return comp
      end

      def complete_parameters(commands, parameters, options)
        comp = {}
        if parameters.any?
          p = parameters.first
          k = case p[0]
          when :opt
            "[<#{p[1]}>]"
          when :rest
            "[<#{p[1]}>[...]]"
          else
            "<#{p[1]}>"
          end
          comp[k.upcase] = complete_commands(commands, parameters[1..-1], options).
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
            comp[o] = if v.type == :boolean
               h
            else
               { "#{v.banner}" => h }
            end
          end
        end
        return comp
      end

    end

  end

end
