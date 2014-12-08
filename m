Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755117AbaLHUwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:32 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqKTM007313
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:31 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9ID018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:17:36 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvVOM010215
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:31 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvVEn010214
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:31 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 11/17] mountstats: Allow mountstats_command to take a variable number of mountpoints
Date: Mon,  8 Dec 2014 14:57:19 -0500
Message-Id: <1418068645-10134-12-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the mountstats command to take a variable number of mountpoints
(including none, in which case it will print stats for all NFS
mountpoints it finds).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 48 ++++++++++++++++++++++++++++++------------
 1 file changed, 34 insertions(+), 14 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 18e7b1a..8cfdb3b 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -311,11 +311,14 @@ class DeviceData:
             return True
         return False
 
+    def display_stats_header(self):
+        print('Stats for %s mounted on %s:' % \
+            (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
+
     def display_nfs_options(self):
         """Pretty-print the NFS options
         """
-        print('Stats for %s mounted on %s:' % \
-            (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
+        self.display_stats_header()
 
         print('  NFS mount options: %s' % ','.join(self.__nfs_data['mountoptions']))
         print('  NFS server capabilities: %s' % ','.join(self.__nfs_data['servercapabilities']))
@@ -562,6 +565,7 @@ def print_mountstats(stats, nfs_only, rpc_only):
        stats.display_nfs_events()
        stats.display_nfs_bytes()
     elif rpc_only:
+       stats.display_stats_header()
        stats.display_rpc_generic_stats()
        stats.display_rpc_op_stats()
     else:
@@ -569,27 +573,42 @@ def print_mountstats(stats, nfs_only, rpc_only):
        stats.display_nfs_bytes()
        stats.display_rpc_generic_stats()
        stats.display_rpc_op_stats()
+    print()
 
 def mountstats_command(args):
     """Mountstats command
     """
     mountstats = parse_stats_file(args.infile)
+    mountpoints = args.mountpoints
+
+    # make certain devices contains only NFS mount points
+    if len(mountpoints) > 0:
+        check = []
+        for device in mountpoints:
+            stats = DeviceData()
+            try:
+                stats.parse_stats(mountstats[device])
+                if stats.is_nfs_mountpoint():
+                    check += [device]
+            except KeyError:
+                continue
+        mountpoints = check
+    else:
+        for device, descr in mountstats.items():
+            stats = DeviceData()
+            stats.parse_stats(descr)
+            if stats.is_nfs_mountpoint():
+                mountpoints += [device]
+    if len(mountpoints) == 0:
+        print('No NFS mount points were found')
+        return
 
     if args.since:
         old_mountstats = parse_stats_file(args.since)
 
-    for mp in args.mountpoints:
-        if mp not in mountstats:
-            print('Statistics for mount point %s not found' % mp)
-            continue
-
+    for mp in mountpoints:
         stats = DeviceData()
         stats.parse_stats(mountstats[mp])
-
-        if not stats.is_nfs_mountpoint():
-            print('Mount point %s exists but is not an NFS mount' % mp)
-            continue
-
         if not args.since:
             print_mountstats(stats, args.nfs_only, args.rpc_only)
         elif args.since and mp not in old_mountstats:
@@ -730,8 +749,9 @@ def main():
             help='Display only the NFS statistics')
         group.add_argument('-r', '--rpc', action='store_true', dest='rpc_only',
             help='Display only the RPC statistics')
-        mountstats_parser.add_argument('mountpoints', nargs='+', metavar='mountpoint',
-            help='Display statistics for this mountpoint. More than one may be specified.')
+        mountstats_parser.add_argument('mountpoints', nargs='*', metavar='mountpoint',
+            help='Display statistics for this mountpoint. More than one may be specified.'
+                'If absent, statistics for all NFS mountpoints will be generated.')
         mountstats_parser.set_defaults(func=mountstats_command)
         args = mountstats_parser.parse_args()
 
-- 
1.9.3

