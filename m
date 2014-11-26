Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41883 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbaKZTOC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:14:02 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE19e016785
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:01 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJE14f023663
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:01 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJE0Tc037769
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:14:00 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJE0Ce037768
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:14:00 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 13/17] mountstats: Implement nfsstat_command
Date: Wed, 26 Nov 2014 14:13:51 -0500
Message-Id: <1417029235-37675-14-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Displays nfssstat-like statistics (client statistics only).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 153 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 150 insertions(+), 3 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index a1ce8f4..b886e5a 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -25,8 +25,9 @@ MA 02110-1301 USA
 
 import sys, os, time
 import argparse
+import operator
 
-Mountstats_version = '0.2'
+Mountstats_version = '0.3'
 
 def difference(x, y):
     """Used for a map() function
@@ -305,6 +306,11 @@ class DeviceData:
             return True
         return False
 
+    def nfs_version(self):
+        if self.is_nfs_mountpoint():
+            prog, vers = self.__rpc_data['programversion'].split('/')
+            return int(vers)
+
     def display_raw_stats(self):
         """Prints out stats in the same format as /proc/self/mountstats
         """
@@ -448,6 +454,50 @@ class DeviceData:
                 print('\ttotal execute time: %f (milliseconds)' % \
                     (float(stats[7]) / count))
 
+    def client_rpc_stats(self):
+        """Tally high-level rpc stats for the nfsstat command
+        """
+        sends = 0
+        trans = 0
+        authrefrsh = 0
+        for op in self.__rpc_data['ops']:
+            sends += self.__rpc_data[op][0]
+            trans += self.__rpc_data[op][1]
+        retrans = trans - sends
+        # authrefresh stats don't actually get captured in
+        # /proc/self/mountstats, so we fudge it here
+        authrefrsh = sends
+        return (sends, trans, authrefrsh)
+
+    def display_nfsstat_stats(self):
+        """Pretty-print nfsstat-style stats
+        """
+        sends = 0
+        for op in self.__rpc_data['ops']:
+            sends += self.__rpc_data[op][0]
+        if sends == 0:
+            return
+        print()
+        vers = self.nfs_version()
+        print('Client nfs v%d' % vers)
+        info = []
+        for op in self.__rpc_data['ops']:
+            print('%-13s' % str.lower(op)[:12], end='')
+            count = self.__rpc_data[op][0]
+            pct = (count * 100) / sends
+            info.append((count, pct))
+            if (self.__rpc_data['ops'].index(op) + 1) % 6 == 0:
+                print()
+                for (count, pct) in info:
+                    print('%-8u%3u%% ' % (count, pct), end='')
+                print()
+                info = []
+        print()
+        if len(info) > 0:
+            for (count, pct) in info:
+                print('%-8u%3u%% ' % (count, pct), end='')
+            print()
+
     def compare_iostats(self, old_stats):
         """Return the difference between two sets of stats
         """
@@ -487,6 +537,27 @@ class DeviceData:
             result.__nfs_data[key] -= old_stats.__nfs_data[key]
         return result
 
+    def setup_accumulator(self, ops):
+        """Initialize a DeviceData instance to tally stats for all mountpoints
+        with the same major version. This is for the nfsstat command.
+        """
+        if ops == Nfsv3ops:
+            self.__rpc_data['programversion'] = '100003/3'
+            self.__nfs_data['fstype'] = 'nfs'
+        elif ops == Nfsv4ops:
+            self.__rpc_data['programversion'] = '100003/4'
+            self.__nfs_data['fstype'] = 'nfs4'
+        self.__rpc_data['ops'] = ops
+        for op in ops:
+            self.__rpc_data[op] = [0 for i in range(8)]
+
+    def accumulate_iostats(self, new_stats):
+        """Accumulate counters from all RPC op buckets in new_stats.  This is
+        for the nfsstat command.
+        """
+        for op in new_stats.__rpc_data['ops']:
+            self.__rpc_data[op] = list(map(operator.add, self.__rpc_data[op], new_stats.__rpc_data[op]))
+
     def __print_rpc_op_stats(self, op, sample_time):
         """Print generic stats for one RPC op
         """
@@ -653,7 +724,78 @@ def mountstats_command(args):
         args.since.close()
 
 def nfsstat_command(args):
-    return
+    """nfsstat-like command for NFS mount points
+    """
+    mountstats = parse_stats_file(args.infile)
+    mountpoints = args.mountpoints
+    v3stats = DeviceData()
+    v3stats.setup_accumulator(Nfsv3ops)
+    v4stats = DeviceData()
+    v4stats.setup_accumulator(Nfsv4ops)
+
+    # ensure stats get printed if neither v3 nor v4 was specified
+    if args.show_v3 or args.show_v4:
+        show_both = False
+    else:
+        show_both = True
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
+
+    if args.since:
+        old_mountstats = parse_stats_file(args.since)
+
+    for mp in mountpoints:
+        stats = DeviceData()
+        stats.parse_stats(mountstats[mp])
+        vers = stats.nfs_version()
+
+        if not args.since:
+            acc_stats = stats
+        elif args.since and mp not in old_mountstats:
+            acc_stats = stats
+        else:
+            old_stats = DeviceData()
+            old_stats.parse_stats(old_mountstats[mp])
+            acc_stats = stats.compare_iostats(old_stats)
+
+        if vers == 3 and (show_both or args.show_v3):
+           v3stats.accumulate_iostats(acc_stats)
+        elif vers == 4 and (show_both or args.show_v4):
+           v4stats.accumulate_iostats(acc_stats)
+
+    sends, retrans, authrefrsh = map(operator.add, v3stats.client_rpc_stats(), v4stats.client_rpc_stats())
+    print('Client rpc stats:')
+    print('calls      retrans    authrefrsh')
+    print('%-11u%-11u%-11u' % (sends, retrans, authrefrsh))
+
+    if show_both or args.show_v3:
+        v3stats.display_nfsstat_stats()
+    if show_both or args.show_v4:
+        v4stats.display_nfsstat_stats()
+
+    args.infile.close()
+    if args.since:
+        args.since.close()
 
 def print_iostat_summary(old, new, devices, time):
     for device in devices:
@@ -790,9 +932,14 @@ def main():
         nfsstat_parser = argparse.ArgumentParser(
             description='nfsstat-like program that uses NFS client per-mount statistics.',
             parents=[parser])
+        nfsstat_parser.add_argument('-3', action='store_true', dest='show_v3',
+            help='Show NFS version 3 statistics')
+        nfsstat_parser.add_argument('-4', action='store_true', dest='show_v4',
+            help='Show NFS version 4 statistics')
+        nfsstat_parser.add_argument('mountpoints', nargs='*', metavar='mountpoint',
+            help='Display statistics for this mountpoint')
         nfsstat_parser.set_defaults(func=nfsstat_command)
         args = nfsstat_parser.parse_args()
-        nfsstat_parser.print_help()
 
     elif prog == 'ms-iostat':
         iostat_parser = argparse.ArgumentParser(
-- 
1.9.3

