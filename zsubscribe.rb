#!/usr/bin/env ruby

class Report
  def initialize(filesystem)
    @filesystem = filesystem
  end
  def summary
    @hashed = {}
    @summary = %x{/usr/sbin/zfs get -H -o property,value quota,refquota,reserv,refreserv #{@filesystem}}.split(/\n/)
    @summary.each do |element| 
      @pieces = element.split(/\t/)
      @hashed[@pieces[0]] = @pieces[1]
    end
  return @hashed 
  end
end

class Refit
  def initialize(filesystem, hashed)
    @filesystem = filesystem
    @hashed = hashed
  end
  def Convert
   %x{/usr/sbin/zfs set refquota=#{@hashed["quota"]} #{@filesystem}}
   %x{/usr/sbin/zfs set refreserv=#{@hashed["reserv"]} #{@filesystem}}
   %x{/usr/sbin/zfs set quota=none #{@filesystem}}
   %x{/usr/sbin/zfs set reserv=none #{@filesystem}}
  end  
end


myreport = Report.new(ARGV)
hashed = myreport.summary
if hashed['quota'] != "none" and hashed['refquota'] == "none"
  print "Not Referenced\nShall I convert it to a referenced quota and reservation? "
  a = STDIN.gets.chomp
  if a == "y" or a == "yes"
    myrefit = Refit.new(ARGV, hashed)
  elsif a == "n" or a == "no"
    puts "Not fixing\nExited!"
  else
    puts "Valid answers are Yes/No"
  end 
end
