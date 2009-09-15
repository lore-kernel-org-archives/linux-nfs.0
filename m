From: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH 2/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Date: Mon, 14 Sep 2009 21:57:41 -0700
Message-ID: <4AAF1EC5.3040403@dreamworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:11159 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751487AbZIOFAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 01:00:03 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.78])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n8F506XN015394
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2009 22:00:07 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update list of mount points at each interval and check for differences
when producing comparative stats.  This ensures proper stats collection
for autofs mountpoints.

Original patch corrected with email feedback from Chuck Lever

Signed-off-by: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
---
  tools/nfs-iostat/nfs-iostat.py |   60 
+++++++++++++++++++++++++++++----------
  1 files changed, 44 insertions(+), 16 deletions(-)
  mode change 100644 => 100755 tools/nfs-iostat/nfs-iostat.py

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
old mode 100644
new mode 100755
index ea02db4..b3f335a
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -447,7 +447,14 @@ def parse_stats_file(filename):
      return ms_dict

  def print_iostat_summary(old, new, devices, time, ac):
-    for device in devices:
+    if old:
+        # Trim device list to only include intersection of old and new 
data,
+        # this addresses umounts due to autofs mountpoints
+        devicelist = filter(lambda x:x in devices,old)
+    else:
+        devicelist = devices
+
+    for device in devicelist:
          stats = DeviceData()
          stats.parse_stats(new[device])
          if not old:
@@ -458,11 +465,32 @@ def print_iostat_summary(old, new, devices, time, ac):
              diff_stats = stats.compare_iostats(old_stats)
              diff_stats.display_iostats(time, ac)

+def list_nfs_mounts(givenlist, mountstats):
+    """return a list of NFS mounts given a list to validate or
+       return a full list if the given list is empty -
+       may return an empty list if none found
+    """
+    list = []
+    if len(givenlist) > 0:
+        for device in givenlist:
+            stats = DeviceData()
+            stats.parse_stats(mountstats[device])
+            if stats.is_nfs_mountpoint():
+                list += [device]
+    else:
+        for device, descr in mountstats.iteritems():
+            stats = DeviceData()
+            stats.parse_stats(descr)
+            if stats.is_nfs_mountpoint():
+                list += [device]
+    return list
+
  def iostat_command(name):
      """iostat-like command for NFS mount points
      """
      mountstats = parse_stats_file('/proc/self/mountstats')
      devices = []
+    origdevices = []
      which = 0
      interval_seen = False
      count_seen = False
@@ -492,7 +520,7 @@ def iostat_command(name):
              continue

          if arg in mountstats:
-            devices += [arg]
+            origdevices += [arg]
          elif not interval_seen:
              interval = int(arg)
              if interval > 0:
@@ -509,23 +537,11 @@ def iostat_command(name):
                  return

      # make certain devices contains only NFS mount points
-    if len(devices) > 0:
-        check = []
-        for device in devices:
-            stats = DeviceData()
-            stats.parse_stats(mountstats[device])
-            if stats.is_nfs_mountpoint():
-                check += [device]
-        devices = check
-    else:
-        for device, descr in mountstats.iteritems():
-            stats = DeviceData()
-            stats.parse_stats(descr)
-            if stats.is_nfs_mountpoint():
-                devices += [device]
+    devices = list_nfs_mounts(origdevices, mountstats)
      if len(devices) == 0:
          print 'No NFS mount points were found'
          return
+

      old_mountstats = None
      sample_time = 0.0
@@ -541,6 +557,12 @@ def iostat_command(name):
              time.sleep(interval)
              sample_time = interval
              mountstats = parse_stats_file('/proc/self/mountstats')
+            # automount mountpoints add and drop, if automount is involved
+            # we need to recheck the devices list when reparsing
+            devices = list_nfs_mounts(origdevices,mountstats)
+            if len(devices) == 0:
+                print 'No NFS mount points were found'
+                return
              count -= 1
      else:
          while True:
@@ -549,6 +571,12 @@ def iostat_command(name):
              time.sleep(interval)
              sample_time = interval
              mountstats = parse_stats_file('/proc/self/mountstats')
+            # automount mountpoints add and drop, if automount is involved
+            # we need to recheck the devices list when reparsing
+            devices = list_nfs_mounts(origdevices,mountstats)
+            if len(devices) == 0:
+                print 'No NFS mount points were found'
+                return

  #
  # Main
-- 
1.5.5.6


