#!/usr/bin/env ruby

class Report
  def initialize(filesystem)
    @filesystem = filesystem
  end
  def summary
    @summary = %x{/usr/sbin/zfs get -H -o property,value quota,refquota,reservation,refreservation #{@filesystem}}.split(/\n/)
    @summary.each do |element| 
      @pieces = element.split(/\t/)
      if  @pieces[0] =~ /ref.*/ and @pieces[1] != "none"
        @refed = true
      end
    end
  return @refed
  end
end

mycheck = Report.new(ARGV)
puts mycheck.summary
