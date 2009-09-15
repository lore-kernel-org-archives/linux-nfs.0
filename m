From: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH 4/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Date: Mon, 14 Sep 2009 21:57:51 -0700
Message-ID: <4AAF1ECF.3090209@dreamworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:11161 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751495AbZIOFAF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 01:00:05 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.78])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n8F5084v015412
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2009 22:00:08 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  Adds --sort option to display mount point stats sorted by ops/s
  Adds --list=<n> option to only display stats for first <n> mount points
  E.g. the use of "--sort --list=1" should be useful in seeing stats for
  only the mountpoint with the highest ops/s.

Signed-off-by: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
---
  tools/nfs-iostat/nfs-iostat.py |   65 
++++++++++++++++++++++++++++++++--------
  1 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index fc2cac8..665b26a 100755
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -354,6 +354,12 @@ class DeviceData:
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
@@ -420,7 +426,10 @@ def parse_stats_file(filename):

      return ms_dict

-def print_iostat_summary(old, new, devices, time, ac):
+def print_iostat_summary(old, new, devices, time, options):
+    stats = {}
+    diff_stats = {}
+
      if old:
          # Trim device list to only include intersection of old and new 
data,
          # this addresses umounts due to autofs mountpoints
@@ -429,15 +438,33 @@ def print_iostat_summary(old, new, devices, time, ac):
          devicelist = devices

      for device in devicelist:
-        stats = DeviceData()
-        stats.parse_stats(new[device])
-        if not old:
-            stats.display_iostats(time, ac)
-        else:
+        stats[device] = DeviceData()
+        stats[device].parse_stats(new[device])
+        if old:
              old_stats = DeviceData()
              old_stats.parse_stats(old[device])
-            diff_stats = stats.compare_iostats(old_stats)
-            diff_stats.display_iostats(time, ac)
+            diff_stats[device] = stats[device].compare_iostats(old_stats)
+
+    if options.sort:
+        if old:
+            # We now have compared data and can print a comparison
+            # ordered by mountpoint ops per second
+            devicelist.sort(key=lambda x: diff_stats[x].ops(time), 
reverse=True)
+        else:
+            # First iteration, just sort by newly parsed ops/s
+            devicelist.sort(key=lambda x: stats[x].ops(time), reverse=True)
+
+    count = 1
+    for device in devicelist:
+        if old:
+            diff_stats[device].display_iostats(time, options.which)
+        else:
+            stats[device].display_iostats(time, options.which)
+
+        count += 1
+        if (count > options.list):
+            return
+

  def list_nfs_mounts(givenlist, mountstats):
      """return a list of NFS mounts given a list to validate or
@@ -485,10 +512,10 @@ client are listed.
          usage="usage: %prog [ <interval> [ <count> ] ] [ <options> ] [ 
<mount point> ]",
          description=mydescription,
          version='version %s' % Iostats_version)
-    parser.set_defaults(which=0)
+    parser.set_defaults(which=0, sort=False, list=sys.maxint)

      statgroup = OptionGroup(parser, "Statistics Options",
-                               'File I/O is displayed unless one of the 
following is specified:')
+                            'File I/O is displayed unless one of the 
following is specified:')
      statgroup.add_option('-a', '--attr',
                              action="store_const",
                              dest="which",
@@ -505,6 +532,18 @@ client are listed.
                              const=3,
                              help='displays statistics related to the 
page cache')
      parser.add_option_group(statgroup)
+    displaygroup = OptionGroup(parser, "Display Options",
+                               'Options affecting display format:')
+    displaygroup.add_option('-s', '--sort',
+                            action="store_true",
+                            dest="sort",
+                            help="Sort NFS mount points by ops/second")
+    displaygroup.add_option('-l','--list',
+                            action="store",
+                            type="int",
+                            dest="list",
+                            help="only print stats for first LIST mount 
points")
+    parser.add_option_group(displaygroup)

      (options, args) = parser.parse_args(sys.argv)

@@ -549,12 +588,12 @@ client are listed.
      sample_time = 0.0

      if not interval_seen:
-        print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options.which)
+        print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options)
          return

      if count_seen:
          while count != 0:
-            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options.which)
+            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options)
              old_mountstats = mountstats
              time.sleep(interval)
              sample_time = interval
@@ -568,7 +607,7 @@ client are listed.
              count -= 1
      else:
          while True:
-            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options.which)
+            print_iostat_summary(old_mountstats, mountstats, devices, 
sample_time, options)
              old_mountstats = mountstats
              time.sleep(interval)
              sample_time = interval
-- 
1.5.5.6



