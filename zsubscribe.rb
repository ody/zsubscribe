#!/usr/bin/env ruby

class Report
  def initialize(filesystem)
    @filesystem = filesystem
  end
  def summary
    @summary = %x{/usr/sbin/zfs get -H -o property,value quota,refquota,reservation,refreservation #{@filesystem}}.split(/\n/)
    @summary.each do |element| 
      if element != "none" 
        @nonone = element + "\n" + @nonone.to_s
      end
    end
    return @nonone
  end
end

mycheck = Report.new(ARGV)
puts mycheck.summary.inspect

