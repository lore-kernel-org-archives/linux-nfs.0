Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994AbaLHUwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:32 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqLUV010165
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:32 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9IJ018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:17:37 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvV8x010219
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:31 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvVNM010218
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:31 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 12/17] mountstats: Add support for -R/--raw to mountstats_command
Date: Mon,  8 Dec 2014 14:57:20 -0500
Message-Id: <1418068645-10134-13-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This option displays the mountstats in raw format (i.e. in the same
format as /proc/self/mountstats).  It's intended to be used mainly with
the -S/--since option.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 47 ++++++++++++++++++++++++++++++++++++++----
 1 file changed, 43 insertions(+), 4 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 8cfdb3b..aa93c76 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -311,6 +311,41 @@ class DeviceData:
             return True
         return False
 
+    def display_raw_stats(self):
+        """Prints out stats in the same format as /proc/self/mountstats
+        """
+        print('device %s mounted on %s with fstype %s %s' % \
+            (self.__nfs_data['export'], self.__nfs_data['mountpoint'], \
+            self.__nfs_data['fstype'], self.__nfs_data['statvers']))
+        print('\topts:\t%s' % ','.join(self.__nfs_data['mountoptions']))
+        print('\tage:\t%d' % self.__nfs_data['age'])
+        print('\tcaps:\t%s' % ','.join(self.__nfs_data['servercapabilities']))
+        print('\tsec:\tflavor=%d,pseudoflavor=%d' % (self.__nfs_data['flavor'], \
+            self.__nfs_data['pseudoflavor']))
+        print('\tevents:\t%s' % " ".join([str(self.__nfs_data[key]) for key in NfsEventCounters]))
+        print('\tbytes:\t%s' % " ".join([str(self.__nfs_data[key]) for key in NfsByteCounters]))
+        print('\tRPC iostats version: %1.1f p/v: %s (nfs)' % (self.__rpc_data['statsvers'], \
+            self.__rpc_data['programversion']))
+        if self.__rpc_data['protocol'] == 'udp':
+            print('\txprt:\tudp %s' % " ".join([str(self.__rpc_data[key]) for key in XprtUdpCounters]))
+        elif self.__rpc_data['protocol'] == 'tcp':
+            print('\txprt:\ttcp %s' % " ".join([str(self.__rpc_data[key]) for key in XprtTcpCounters]))
+        elif self.__rpc_data['protocol'] == 'rdma':
+            print('\txprt:\trdma %s' % " ".join([str(self.__rpc_data[key]) for key in XprtRdmaCounters]))
+        else:
+            raise Exception('Unknown RPC transport protocol %s' % self.__rpc_data['protocol'])
+        print('\tper-op statistics')
+        prog, vers = self.__rpc_data['programversion'].split('/')
+        if vers == '3':
+            for op in Nfsv3ops:
+                print('\t%12s: %s' % (op, " ".join(str(x) for x in self.__rpc_data[op])))
+        elif vers == '4':
+            for op in Nfsv4ops:
+                print('\t%12s: %s' % (op, " ".join(str(x) for x in self.__rpc_data[op])))
+        else:
+            print('\tnot implemented for version %d' % vers)
+        print()
+
     def display_stats_header(self):
         print('Stats for %s mounted on %s:' % \
             (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
@@ -559,7 +594,7 @@ def parse_stats_file(f):
 
     return ms_dict
 
-def print_mountstats(stats, nfs_only, rpc_only):
+def print_mountstats(stats, nfs_only, rpc_only, raw):
     if nfs_only:
        stats.display_nfs_options()
        stats.display_nfs_events()
@@ -568,6 +603,8 @@ def print_mountstats(stats, nfs_only, rpc_only):
        stats.display_stats_header()
        stats.display_rpc_generic_stats()
        stats.display_rpc_op_stats()
+    elif raw:
+       stats.display_raw_stats()
     else:
        stats.display_nfs_options()
        stats.display_nfs_bytes()
@@ -610,14 +647,14 @@ def mountstats_command(args):
         stats = DeviceData()
         stats.parse_stats(mountstats[mp])
         if not args.since:
-            print_mountstats(stats, args.nfs_only, args.rpc_only)
+            print_mountstats(stats, args.nfs_only, args.rpc_only, args.raw)
         elif args.since and mp not in old_mountstats:
-            print_mountstats(stats, args.nfs_only, args.rpc_only)
+            print_mountstats(stats, args.nfs_only, args.rpc_only, args.raw)
         else:
             old_stats = DeviceData()
             old_stats.parse_stats(old_mountstats[mp])
             diff_stats = stats.compare_iostats(old_stats)
-            print_mountstats(diff_stats, args.nfs_only, args.rpc_only)
+            print_mountstats(diff_stats, args.nfs_only, args.rpc_only, args.raw)
 
     args.infile.close()
     if args.since:
@@ -749,6 +786,8 @@ def main():
             help='Display only the NFS statistics')
         group.add_argument('-r', '--rpc', action='store_true', dest='rpc_only',
             help='Display only the RPC statistics')
+        group.add_argument('-R', '--raw', action='store_true',
+            help='Display only the raw statistics')
         mountstats_parser.add_argument('mountpoints', nargs='*', metavar='mountpoint',
             help='Display statistics for this mountpoint. More than one may be specified.'
                 'If absent, statistics for all NFS mountpoints will be generated.')
-- 
1.9.3

