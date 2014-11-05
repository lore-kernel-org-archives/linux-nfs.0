Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932251AbaKERBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:17 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1G12009265
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1FCU004637
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1F2G000935
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1FZ5000934
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:15 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 09/15] mountstats: Add support for -S/--since to the mountstats and ms-iostat commands
Date: Wed,  5 Nov 2014 12:01:06 -0500
Message-Id: <1415206872-864-10-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for -S/--since to the mountstats and ms-iostat commands to
display the delta between a previous copy of /proc/self/mountstats and
the current /proc/self/mountstats file.  Can be combined with the -f
option to show the statistics between two different points in time.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 61 +++++++++++++++++++++++++++++-------------
 1 file changed, 43 insertions(+), 18 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 23def92..b3231b2 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -562,13 +562,28 @@ def print_mountstats_help(name):
     print('  --rpc        display only the RPC statistics')
     print('  --start      sample and save statistics')
     print('  --end        resample statistics and compare them with saved')
+    print('  --since <file> shows difference between current stats and those in \'file\'')
     print()
 
+def print_mountstats(stats, nfs_only, rpc_only):
+    if nfs_only:
+       stats.display_nfs_options()
+       stats.display_nfs_events()
+       stats.display_nfs_bytes()
+    elif rpc_only:
+       stats.display_rpc_generic_stats()
+       stats.display_rpc_op_stats()
+    else:
+       stats.display_nfs_options()
+       stats.display_nfs_bytes()
+       stats.display_rpc_generic_stats()
+       stats.display_rpc_op_stats()
+
 def mountstats_command():
     """Mountstats command
     """
     try:
-        opts, args = getopt.getopt(sys.argv[1:], "ef:hnrsv", ["end", "file=", "help", "nfs", "rpc", "start", "version"])
+        opts, args = getopt.getopt(sys.argv[1:], "ef:hnrsvS:", ["end", "file=", "help", "nfs", "rpc", "start", "version", "since="])
     except getopt.GetoptError as err:
         print_mountstats_help(prog)
 
@@ -576,6 +591,7 @@ def mountstats_command():
     nfs_only = False
     rpc_only = False
     infile = None
+    since = None
 
     for o, a in opts:
         if o in ("-e", "--end"):
@@ -594,6 +610,8 @@ def mountstats_command():
         elif o in ("-v", "--version"):
             print('%s version %s' % (sys.argv[0], Mountstats_version))
             sys.exit(0)
+        elif o in ("-S", "--since"):
+            since = a
         else:
             assert False, "unhandled option"
     mountpoints += args
@@ -610,6 +628,9 @@ def mountstats_command():
         infile = '/proc/self/mountstats'
     mountstats = parse_stats_file(infile)
 
+    if since:
+        old_mountstats = parse_stats_file(since)
+
     for mp in mountpoints:
         if mp not in mountstats:
             print('Statistics for mount point %s not found' % mp)
@@ -622,18 +643,15 @@ def mountstats_command():
             print('Mount point %s exists but is not an NFS mount' % mp)
             continue
 
-        if nfs_only:
-           stats.display_nfs_options()
-           stats.display_nfs_events()
-           stats.display_nfs_bytes()
-        elif rpc_only:
-           stats.display_rpc_generic_stats()
-           stats.display_rpc_op_stats()
+        if not since:
+            print_mountstats(stats, nfs_only, rpc_only)
+        elif since and mp not in old_mountstats:
+            print_mountstats(stats, nfs_only, rpc_only)
         else:
-           stats.display_nfs_options()
-           stats.display_nfs_bytes()
-           stats.display_rpc_generic_stats()
-           stats.display_rpc_op_stats()
+            old_stats = DeviceData()
+            old_stats.parse_stats(old_mountstats[mp])
+            diff_stats = stats.compare_iostats(old_stats)
+            print_mountstats(diff_stats, nfs_only, rpc_only)
 
 def print_nfsstat_help(name):
     print('usage: %s [ options ]' % name)
@@ -684,7 +702,7 @@ def iostat_command():
     """iostat-like command for NFS mount points
     """
     try:
-        opts, args = getopt.getopt(sys.argv[1:], "f:hv", ["file=", "help", "version"])
+        opts, args = getopt.getopt(sys.argv[1:], "f:hvS:", ["file=", "help", "version", "since="])
     except getopt.GetoptError as err:
         print_iostat_help(prog)
     devices = []
@@ -692,6 +710,7 @@ def iostat_command():
     count_seen = False
     infile_seen = False
     infile = None
+    since = None
 
     for o, a in opts:
         if o in ("-f", "--file"):
@@ -703,6 +722,8 @@ def iostat_command():
         elif o in ("-v", "--version"):
             print('%s version %s' % (sys.argv[0], Mountstats_version))
             sys.exit(0)
+        elif o in ("-S", "--since"):
+            since = a
         else:
             assert False, "unhandled option"
     if not infile:
@@ -715,8 +736,8 @@ def iostat_command():
         elif not interval_seen:
             interval = int(arg)
             if interval > 0:
-                if infile_seen:
-                    print('interval may not be used with the -f option')
+                if infile_seen or since:
+                    print('interval may not be used with the -f or -S options')
                     return
                 else:
                     interval_seen = True
@@ -726,8 +747,8 @@ def iostat_command():
         elif not count_seen:
             count = int(arg)
             if count > 0:
-                if infile_seen:
-                    print('count may not be used with the -f option')
+                if infile_seen or since:
+                    print('count may not be used with the -f or -S options')
                     return
                 else:
                     count_seen = True
@@ -735,6 +756,11 @@ def iostat_command():
                 print('Illegal <count> value')
                 return
 
+    if since:
+        old_mountstats = parse_stats_file(since)
+    else:
+        old_mountstats = None
+
     # make certain devices contains only NFS mount points
     if len(devices) > 0:
         check = []
@@ -754,7 +780,6 @@ def iostat_command():
         print('No NFS mount points were found')
         return
 
-    old_mountstats = None
     sample_time = 0
 
     if not interval_seen:
-- 
1.9.3

