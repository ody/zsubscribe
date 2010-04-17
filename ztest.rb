#!/usr/bin/env ruby

filesystem = ARGV
hashed = {}
summary = %x{/usr/sbin/zfs get -H -o property,value quota,refquota,reservation,refreservation #{filesystem}}.split(/\n/)
summary.each do |element| 
  pieces = element.split(/\t/)
    hashed[pieces[0]] = pieces[1]
end

puts hashed.inspect
