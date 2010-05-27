From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 1/1] nfs-iostat.py: Fixes several Divide by Zero errors
Date: Thu, 27 May 2010 16:58:38 -0700
Message-ID: <1275004718-1802-1-git-send-email-kevin.constantine@disneyanimation.com>
Cc: chuck.lever@oracle.com, steved@redhat.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([198.187.190.101]:58285 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753915Ab0E0X6o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 19:58:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There was no check to see if sample_time was zero before dividing by it.
This was causing ZeroDivisionError's:

Traceback (most recent call last):
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 628, in ?
    iostat_command(prog)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 610, in iostat_command
    print_iostat_summary(old_mountstats, mountstats, devices, sample_time, options)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 462, in print_iostat_summary
    stats[device].display_iostats(time, options.which)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 370, in display_iostats
    backlog = (float(self.__rpc_data['backlogutil']) / sends) / sample_time
ZeroDivisionError: float division

Traceback (most recent call last):
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 628, in ?
    iostat_command(prog)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 610, in iostat_command
    print_iostat_summary(old_mountstats, mountstats, devices, sample_time, options)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 462, in print_iostat_summary
    stats[device].display_iostats(time, options.which)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 380, in display_iostats
    print '%7.2f' % (sends / sample_time),
ZeroDivisionError: float division

Traceback (most recent call last):
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 630, in ?
    iostat_command(prog)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 612, in iostat_command
    print_iostat_summary(old_mountstats, mountstats, devices, sample_time, options)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 464, in print_iostat_summary
    stats[device].display_iostats(time, options.which)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 386, in display_iostats
    self.__print_rpc_op_stats('READ', sample_time)
  File "/home/fahome/kconstan/repos/nfs-utils.upstream/tools/nfs-iostat/nfs-iostat.py", line 350, in __print_rpc_op_stats
    print '\t\t%7.3f' % (ops / sample_time),
ZeroDivisionError: float division

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 tools/nfs-iostat/nfs-iostat.py |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 2d0b143..4d6b295 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -342,13 +342,19 @@ class DeviceData:
             retrans_percent = 0.0
             rtt_per_op = 0.0
             exe_per_op = 0.0
+        if sample_time != 0:
+            ops_per_sample_time = ops / sample_time
+            kb_per_sample_time = kilobytes / sample_time
+        else:
+            ops_per_sample_time = 0.0
+            kb_per_sample_time = 0.0
 
         op += ':'
         print '%s' % op.lower().ljust(15),
         print '  ops/s\t\t   kB/s\t\t  kB/op\t\tretrans\t\tavg RTT (ms)\tavg exe (ms)'
 
-        print '\t\t%7.3f' % (ops / sample_time),
-        print '\t%7.3f' % (kilobytes / sample_time),
+        print '\t\t%7.3f' % (ops_per_sample_time),
+        print '\t%7.3f' % (kb_per_sample_time),
         print '\t%7.3f' % kb_per_op,
         print ' %7d (%3.1f%%)' % (retrans, retrans_percent),
         print '\t%7.3f' % rtt_per_op,
@@ -358,7 +364,9 @@ class DeviceData:
         sends = float(self.__rpc_data['rpcsends'])
         if sample_time == 0:
             sample_time = float(self.__nfs_data['age'])
-        return (sends / sample_time)
+            return (sends / sample_time)
+        else:
+            return(0.0)
 
     def display_iostats(self, sample_time, which):
         """Display NFS and RPC stats in an iostat-like way
@@ -366,10 +374,12 @@ class DeviceData:
         sends = float(self.__rpc_data['rpcsends'])
         if sample_time == 0:
             sample_time = float(self.__nfs_data['age'])
-        if sends != 0:
+        if sends != 0 and sample_time != 0:
             backlog = (float(self.__rpc_data['backlogutil']) / sends) / sample_time
+            sends_per_sample_time = sends / sample_time
         else:
             backlog = 0.0
+            sends_per_sample_time = 0.0
 
         print
         print '%s mounted on %s:' % \
@@ -377,7 +387,7 @@ class DeviceData:
         print
 
         print '   op/s\t\trpc bklog'
-        print '%7.2f' % (sends / sample_time), 
+        print '%7.2f' % (sends_per_sample_time), 
         print '\t%7.2f' % backlog
 
         if which == 0:
-- 
1.6.5.2

