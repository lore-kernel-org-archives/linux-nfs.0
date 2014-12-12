Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966278AbaLLTPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 14:15:01 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBCJF1MN019188
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:15:01 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBCJF1jq028410
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:15:01 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sBCJF0ma000371
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:15:00 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sBCJF0s4000370
	for linux-nfs@vger.kernel.org; Fri, 12 Dec 2014 14:15:00 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v4 09/14] mountstats: Add support for -S/--since
Date: Fri, 12 Dec 2014 14:14:52 -0500
Message-Id: <1418411697-65535-10-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418411697-65535-1-git-send-email-smayhew@redhat.com>
References: <1418411697-65535-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for -S/--since to display the delta between a previous
copy of /proc/self/mountstats and the current /proc/self/mountstats
file.  Can be combined with the -f option to show the statistics
between two different points in time.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 51 +++++++++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 032d8d6..18d9514 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -556,11 +556,28 @@ def parse_stats_file(f):
 
     return ms_dict
 
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
 def mountstats_command(args):
     """Mountstats command
     """
     mountstats = parse_stats_file(args.infile)
 
+    if args.since:
+        old_mountstats = parse_stats_file(args.since)
+
     for mp in args.mountpoints:
         if mp not in mountstats:
             print('Statistics for mount point %s not found' % mp)
@@ -573,20 +590,19 @@ def mountstats_command(args):
             print('Mount point %s exists but is not an NFS mount' % mp)
             continue
 
-        if args.nfs_only:
-           stats.display_nfs_options()
-           stats.display_nfs_events()
-           stats.display_nfs_bytes()
-        elif args.rpc_only:
-           stats.display_rpc_generic_stats()
-           stats.display_rpc_op_stats()
+        if not args.since:
+            print_mountstats(stats, args.nfs_only, args.rpc_only)
+        elif args.since and mp not in old_mountstats:
+            print_mountstats(stats, args.nfs_only, args.rpc_only)
         else:
-           stats.display_nfs_options()
-           stats.display_nfs_bytes()
-           stats.display_rpc_generic_stats()
-           stats.display_rpc_op_stats()
+            old_stats = DeviceData()
+            old_stats.parse_stats(old_mountstats[mp])
+            diff_stats = stats.compare_iostats(old_stats)
+            print_mountstats(diff_stats, args.nfs_only, args.rpc_only)
 
     args.infile.close()
+    if args.since:
+        args.since.close()
 
 def nfsstat_command(args):
     return
@@ -609,6 +625,11 @@ def iostat_command(args):
     mountstats = parse_stats_file(args.infile)
     devices = args.mountpoints
 
+    if args.since:
+        old_mountstats = parse_stats_file(args.since)
+    else:
+        old_mountstats = None
+
     # make certain devices contains only NFS mount points
     if len(devices) > 0:
         check = []
@@ -631,7 +652,6 @@ def iostat_command(args):
         print('No NFS mount points were found')
         return
 
-    old_mountstats = None
     sample_time = 0
 
     if args.interval is None:
@@ -656,6 +676,8 @@ def iostat_command(args):
             mountstats = parse_stats_file(args.infile)
 
     args.infile.close()
+    if args.since:
+        args.since.close()
 
 class ICMAction(argparse.Action):
     """Custom action to deal with interval, count, and mountpoints.
@@ -675,7 +697,7 @@ class ICMAction(argparse.Action):
         try:
             intval = int(value)
             if namespace.infile.name != '/proc/self/mountstats':
-                raise argparse.ArgumentError(self, "not allowed with argument -f/--file")
+                raise argparse.ArgumentError(self, "not allowed with argument -f/--file or -S/--since")
             self._handle_int(namespace, intval)
         except ValueError:
             namespace.mountpoints.append(value)
@@ -699,6 +721,9 @@ def main():
     common_parser.add_argument('-f', '--file', default=open('/proc/self/mountstats', 'r'),
         type=argparse.FileType('r'), dest='infile',
         help='Read stats from %(dest)s instead of /proc/self/mountstats')
+    common_parser.add_argument('-S', '--since', type=argparse.FileType('r'),
+        metavar='SINCEFILE',
+        help='Show difference between current stats and those in SINCEFILE')
 
     mountstats_parser = subparsers.add_parser('mountstats',
         parents=[common_parser],
-- 
1.9.3

