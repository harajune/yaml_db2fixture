# encoding: utf-8
#

require "yaml"
require "pp"

if ARGV.size != 2
  STDERR.puts "trans_yml2fixtures.rb dump_yaml dest_dir"
  exit
end

text = File.read(ARGV[0])
yamls = text.split("---")

yamls.delete_if do |text|
  text.strip == ""
end
yamls.map! do |text|
  text.strip
end

yamls.each do |y|
  hash = YAML.load(y)

  keys = []
  open("#{ARGV[1]}/#{hash.keys[0]}.yml", "w") do |file|
    hash[hash.keys[0]]["columns"].each do |k|
      keys << k
    end

    hash[hash.keys[0]]["records"].each_index do |ind|
      vals = hash[hash.keys[0]]["records"][ind]

      file.puts "#{vals[0]}:"
      (0..vals.size).each do |i|
        next if vals[i].nil? or (vals[i].is_a? String and vals[i].strip == "")
        value = vals[i]
        value = "\"#{value}\"" if value.is_a? String
        value = "<%= Time.now.to_s %>" if keys[i] == "service_at"
        file.puts "  #{keys[i]}: #{value}"
      end

      file.puts ""
    end
  end
end

