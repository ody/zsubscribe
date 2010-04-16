#!/usr/bin/env ruby

class report
  def getdata(filesystem)
    @filesystem = filesystem
    summary = system("/usr/sbin/zfs get 
