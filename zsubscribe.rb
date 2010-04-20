#!/usr/bin/env ruby

class Report
  def initialize(filesystem)
    @filesystem = filesystem
  end
  def summary
    @hashed = {}
    @summary = %x{/usr/sbin/zfs get -p -H -o property,value quota,refquota,reserv,refreserv,referenced #{@filesystem}}.split(/\n/)
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
  def convert
    %x{/usr/sbin/zfs set refquota=#{@hashed["quota"]} #{@filesystem}}
    %x{/usr/sbin/zfs set refreserv=#{@hashed["reservation"]} #{@filesystem}}
    %x{/usr/sbin/zfs set quota=none #{@filesystem}}
    %x{/usr/sbin/zfs set reserv=none #{@filesystem}}
    return 0
  end  
end

class Math
  def initialize(filesystem, hashed)
    @filesystem = filesystem
    @hashed = hashed
  end
  def ratios
    @realuse = @hashed["referenced"].quo(@hashed["refreserv"])
    if @realuse < .5
      return 0
    elsif @realuse = (0.5..0.85) 
      return 1
    else
      return 2
    end
  end
end

myreport = Report.new(ARGV)
hashed = myreport.summary
if hashed['quota'] != "none" and hashed['refquota'] == "none"
  print "Not Referenced\nShall I convert it to a referenced quota and reservation? "
  a = STDIN.gets.chomp
  if a == "y" or a == "yes"
    myrefit = Refit.new(ARGV, hashed)
    myrefit.convert
  elsif a == "n" or a == "no"
    puts "Not fixing\nExited!"
  else
    puts "Valid answers are Yes/No"
  end 
end
