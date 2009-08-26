Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:6791 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755542AbZHZE7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 00:59:23 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.112])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n7Q4xN9N014282
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 21:59:24 -0700
Message-ID: <4A94C13E.6070403@dreamworks.com>
Date: Tue, 25 Aug 2009 21:59:42 -0700
From: Lans Carstensen <Lans.Carstensen@dreamworks.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

commit 062577877bd3f1d8da1edeb889a09d380da83364
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Aug 25 21:53:54 2009 -0700

     Adds --sort option to display mount point stats sorted by ops/s
     Adds -<n> option to only display stats for first <n> mount points
     E.g. the use of "--sort -1" should be useful in seeing stats for
     only the mountpoint with the highest ops/s.

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 9f3b3eb..5df9bfb 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -20,7 +20,7 @@ along with this program; if not, write to the Free 
Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  """

-import sys, os, time
+import sys, os, time, re

  Iostats_version = '0.3'

@@ -353,6 +353,12 @@ class DeviceData:
          print '\t%7.3f' % rtt_per_op,
          print '\t%7.3f' % exe_per_op

+    def ops(self, sample_time):
+        sends = float(self.__rpc_data['rpcsends'])
+        if sample_time == 0:
+            sample_time = float(self.__nfs_data['age'])
+        return (sends / sample_time)
+
      def display_iostats(self, sample_time, which):
          """Display NFS and RPC stats in an iostat-like way
          """
@@ -421,6 +427,11 @@ def print_iostat_help(name):
      print ' If one or more <mount point> names are specified, 
statistics for only these'
      print ' mount points will be displayed.  Otherwise, all NFS mount 
points on the'
      print ' client are listed.'
+    print
+    print ' You can also specify "--sort" to sort the NFS mount points 
by ops/second,'
+    print ' and specify a number of mount points to return with -<num>, 
e.g. -1.'
+    print ' For example, use of "--sort -1" will iterate only showing 
you the stats'
+    print ' for the mount point with the highest ops/second.'

  def parse_stats_file(filename):
      """pop the contents of a mountstats file into a dictionary,
@@ -446,7 +457,10 @@ def parse_stats_file(filename):

      return ms_dict

-def print_iostat_summary(old, new, devices, time, ac):
+def print_iostat_summary(old, new, devices, time, ac, sortbyops, 
entrycount):
+    diff_stats = {}
+    count = 1
+
      if old:
          # Trim device list to only include intersection of old and new 
data,
          # this addresses umounts due to autofs mountpoints
@@ -455,15 +469,34 @@ def print_iostat_summary(old, new, devices, time, ac):
          devicelist = devices

      for device in devicelist:
+        count += 1
          stats = DeviceData()
          stats.parse_stats(new[device])
          if not old:
              stats.display_iostats(time, ac)
+            if (count>entrycount):
+                return
          else:
              old_stats = DeviceData()
              old_stats.parse_stats(old[device])
-            diff_stats = stats.compare_iostats(old_stats)
-            diff_stats.display_iostats(time, ac)
+            diff_stats[device] = stats.compare_iostats(old_stats)
+            if not sortbyops:
+                diff_stats[device].display_iostats(time, ac)
+                if (count>entrycount):
+                    return
+
+    if old and sortbyops:
+        # We now have compared data and can print a comparison
+        # ordered by mountpoint ops per second
+        count = 1
+
+        devicelist.sort(key=lambda x: diff_stats[x].ops(time), 
reverse=True)
+
+        for device in devicelist:
+            count += 1
+            diff_stats[device].display_iostats(time, ac)
+            if (count>entrycount):
+                return

  def list_nfs_mounts(givenlist, mountstats):
      """return a list of NFS mounts given a list to validate or
@@ -497,6 +530,8 @@ def iostat_command(name):
      which = 0
      interval_seen = False
      count_seen = False
+    sortbyops = False
+    entrycount = sys.maxint

      for arg in sys.argv:
          if arg in ['-h', '--help', 'help', 'usage']:
@@ -507,6 +542,19 @@ def iostat_command(name):
              print '%s version %s' % (name, Iostats_version)
              return

+        if arg in ['-s', '--sort', 'sort']:
+            sortbyops = True
+            # sorted display infers a loop, default to 1 second
+            if not interval_seen:
+                interval = 1
+                interval_seen = True
+            continue
+
+        stop_re = re.compile('-[0-9]+')
+        if stop_re.match(arg):
+            entrycount = int(arg.lstrip('-'))
+            continue
+
          if arg in ['-a', '--attr']:
              which = 1
              continue
@@ -546,12 +594,12 @@ def iostat_command(name):
      sample_time = 0.0

      if not interval_seen:
-        print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which)
+        print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which, sortbyops, entrycount)
          return

      if count_seen:
          while count != 0:
-            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which)
+            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which, sortbyops, entrycount)
              old_mountstats = mountstats
              time.sleep(interval)
              sample_time = interval
@@ -562,7 +610,7 @@ def iostat_command(name):
              count -= 1
      else:
          while True:
-            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which)
+            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, which, sortbyops, entrycount)
              old_mountstats = mountstats
              time.sleep(interval)
              sample_time = interval



