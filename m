Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932278AbaKERBS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:18 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1HHq003103
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:18 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1Gug027918
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:17 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Gch000947
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1GP8000946
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:16 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 12/15] mountstats: Add support for -R/--raw to mountstats_command
Date: Wed,  5 Nov 2014 12:01:09 -0500
Message-Id: <1415206872-864-13-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This option displays the mountstats in raw format (i.e. in the same
format as /proc/self/mountstats).  It's intended to be used mainly with
the -S/--since option.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 50 +++++++++++++++++++++++++++++++++++++-----
 1 file changed, 45 insertions(+), 5 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 281f4be..2d6ca95 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -305,6 +305,41 @@ class DeviceData:
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
     def display_nfs_options(self):
         """Pretty-print the NFS options
         """
@@ -565,7 +600,7 @@ def print_mountstats_help(name):
     print('  --since <file> shows difference between current stats and those in \'file\'')
     print()
 
-def print_mountstats(stats, nfs_only, rpc_only):
+def print_mountstats(stats, nfs_only, rpc_only, raw):
     if nfs_only:
        stats.display_nfs_options()
        stats.display_nfs_events()
@@ -573,6 +608,8 @@ def print_mountstats(stats, nfs_only, rpc_only):
     elif rpc_only:
        stats.display_rpc_generic_stats()
        stats.display_rpc_op_stats()
+    elif raw:
+       stats.display_raw_stats()
     else:
        stats.display_nfs_options()
        stats.display_nfs_bytes()
@@ -583,13 +620,14 @@ def mountstats_command():
     """Mountstats command
     """
     try:
-        opts, args = getopt.getopt(sys.argv[1:], "ef:hnrsvS:", ["end", "file=", "help", "nfs", "rpc", "start", "version", "since="])
+        opts, args = getopt.getopt(sys.argv[1:], "ef:hnrsvS:R", ["end", "file=", "help", "nfs", "rpc", "start", "version", "since=", "raw"])
     except getopt.GetoptError as err:
         print_mountstats_help(prog)
 
     mountpoints = []
     nfs_only = False
     rpc_only = False
+    raw = False
     infile = None
     since = None
 
@@ -612,6 +650,8 @@ def mountstats_command():
             sys.exit(0)
         elif o in ("-S", "--since"):
             since = a
+        elif o in ("-R", "--raw"):
+            raw = True
         else:
             assert False, "unhandled option"
     mountpoints += args
@@ -650,14 +690,14 @@ def mountstats_command():
         stats = DeviceData()
         stats.parse_stats(mountstats[mp])
         if not since:
-            print_mountstats(stats, nfs_only, rpc_only)
+            print_mountstats(stats, nfs_only, rpc_only, raw)
         elif since and mp not in old_mountstats:
-            print_mountstats(stats, nfs_only, rpc_only)
+            print_mountstats(stats, nfs_only, rpc_only, raw)
         else:
             old_stats = DeviceData()
             old_stats.parse_stats(old_mountstats[mp])
             diff_stats = stats.compare_iostats(old_stats)
-            print_mountstats(diff_stats, nfs_only, rpc_only)
+            print_mountstats(diff_stats, nfs_only, rpc_only, raw)
 
 def print_nfsstat_help(name):
     print('usage: %s [ options ]' % name)
-- 
1.9.3

