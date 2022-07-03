require 'yaml'

class Parser
  def self.call(*args)
    new(*args).call
  end

  def initialize(file_path = 'config.yml')
    @file_path = file_path
  end

  def call
    [].tap do |code|
      code << 'source ${0:A:h}/functions.zsh'
      code << "set_state '#{config['default_view']}'"
      code << views_functions
      code << define_views_functions
      code << main_function
      code << 'autoload -Uz add-zsh-hook'
      code << "add-zsh-hook precmd precmd_apple_touchbar\n"
    end.join("\n\n")
  end

  private

  attr_reader :file_path

  def create_key_pattern(key, value)
    if value['view']
      command = "#{value['view']}_view"
    elsif value['command']
      command = value['command']
    else
      command = value['command_to_complete']
    end

    "\tcreate_key #{key} '#{value['text']}' '#{command}'".tap do |code|
      code << " '-s'" if value['command'] || value['command_to_complete']
      code << " '-n'" if value['command']
    end if (1..12).include?(key)
  end

  def function_pattern(view, commands, back = nil)
    [].tap do |code|
      code << "function #{view}_view() {"
      code << "\tremove_and_unbind_keys\n"
      code << "\tset_state '#{view}'\n"
      code << commands.join("\n")
      code << "\n\tset_state '#{back}'" if back
      code << "}"

    end.join("\n")
  end

  def views_functions
    config['views'].map do |view, keys|
      commands = keys.map { |k, v| create_key_pattern(k, v) }.compact

      function_pattern(view, commands, keys['back'])
    end.join("\n\n")
  end

  def define_views_functions
    config['views'].keys.map do |view|
      "zle -N #{view}_view"
    end.join("\n")
  end

  def main_function
    [].tap do |code|
      code << 'precmd_apple_touchbar() {'
      code << "\tcase $state in"
      code << config['views'].keys.map { |view| "\t\t#{view}) #{view}_view ;;"}.join("\n")
      code << "\tesac"
      code << '}'
    end.join("\n")
  end

  def config
    @config ||= YAML.load(File.read(file_path))
  end
end

File.open('zsh-apple-touchbar.zsh', 'w') {|f| f.write(Parser.call) }
