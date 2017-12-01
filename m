Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:40102 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdLAT25 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Dec 2017 14:28:57 -0500
Received: by mail-it0-f52.google.com with SMTP id f190so3605175ita.5
        for <linux-nfs@vger.kernel.org>; Fri, 01 Dec 2017 11:28:56 -0800 (PST)
Received: from manet.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g79sm899213itb.29.2017.12.01.11.28.55
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 11:28:55 -0800 (PST)
Subject: [RFC PATCH] mountstats: Add option to pretty-print xprt statistics
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 01 Dec 2017 14:28:55 -0500
Message-ID: <20171201192655.2092.11587.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add "-x" option to display the statistics reported on the "xprt:"
line in mountstats. This is not terribly interesting for UDP and
TCP, but it can be for RDMA transports.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
This has seen a little testing, but probably needs more. My Python
chops are rusty, so go easy on me.


 tools/mountstats/mountstats.man |    5 ++
 tools/mountstats/mountstats.py  |   89 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 89 insertions(+), 5 deletions(-)
 mode change 100644 => 100755 tools/mountstats/mountstats.py

diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
index a55130b..ff2f8ba 100644
--- a/tools/mountstats/mountstats.man
+++ b/tools/mountstats/mountstats.man
@@ -19,6 +19,8 @@ mountstats \- Displays various NFS client per-mount statistics
 .RB [ \-r | \-\-rpc ]
 |
 .RB  [ \-R | \-\-raw ]
+|
+.RB  [ \-x | \-\-xprt ]
 ]
 .RI [ mountpoint ] ...
 .P
@@ -110,6 +112,9 @@ Display only the raw statistics.  This is intended for use with the
 and
 .BR \-S | \-\-since
 options.
+.TP
+.B \-x, \-\-xprt
+Display only the transport statistics
 .SS Options specific to the iostat sub-command
 .IP "\fIinterval\fP"
 Specifies the amount of time in seconds between each report.  The first report contains statistics for the time since each file system was mounted.  Each subsequent report contains statistics collected during the interval since the previous report.  This may not be used with the
diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
old mode 100644
new mode 100755
index 29b5f5a..39b9165
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -112,6 +112,7 @@ XprtRdmaCounters = [
     'rpcsends',
     'rpcreceives',
     'badxids',
+    'inflightsends',
     'backlogutil',
     'read_chunks',
     'write_chunks',
@@ -122,7 +123,14 @@ XprtRdmaCounters = [
     'fixup',
     'hardway',
     'failed_marshal',
-    'bad_reply'
+    'bad_reply',
+    'nomsg_calls',
+    'recovered_mrs',
+    'orphaned_mrs',
+    'allocated_mrs',
+    'local_invalidates',
+    'empty_sendctx_q',
+    'reply_waits_for_send',
 ]
 
 Nfsv3ops = [
@@ -655,6 +663,73 @@ class DeviceData:
         self.__print_rpc_op_stats('WRITE', sample_time)
         sys.stdout.flush()
 
+    def display_xprt_stats(self):
+        """Pretty-print the xprt statistics
+        """
+        if self.__rpc_data['protocol'] == 'udp':
+            print('Transport protocol: udp')
+            print('\tSource port: %s' % self.__rpc_data['port'])
+            print('\tBind count: %s' % self.__rpc_data['bind_count'])
+            print('\tRPC requests: %d' % self.__rpc_data['rpcsends'])
+            print('\tRPC replies: %d' % self.__rpc_data['rpcreceives'])
+            print('\tXIDs not found: %d' % self.__rpc_data['badxids'])
+            if self.__rpc_data['rpcsends'] != 0:
+                print('\tAvg backlog length: %d' % \
+                    (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
+        elif self.__rpc_data['protocol'] == 'tcp':
+            print('Transport protocol: tcp')
+            print('\tSource port: %s' % self.__rpc_data['port'])
+            print('\tBind count: %s' % self.__rpc_data['bind_count'])
+            print('\tConnect count: %s' % self.__rpc_data['connect_count'])
+            print('\tConnect time: %s seconds' % self.__rpc_data['connect_time'])
+            print('\tIdle time: %s seconds' % self.__rpc_data['idle_time'])
+            print('\tRPC requests: %d' % self.__rpc_data['rpcsends'])
+            print('\tRPC replies: %d' % self.__rpc_data['rpcreceives'])
+            print('\tXIDs not found: %d' % self.__rpc_data['badxids'])
+            if self.__rpc_data['rpcsends'] != 0:
+                print('\tAvg backlog length: %d' % \
+                    (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
+        elif self.__rpc_data['protocol'] == 'rdma':
+            print('Transport protocol: rdma')
+            print('\tConnect count: %s' % self.__rpc_data['connect_count'])
+            print('\tConnect time: %s seconds' % self.__rpc_data['connect_time'])
+            print('\tIdle time: %s seconds' % self.__rpc_data['idle_time'])
+            sends = self.__rpc_data['rpcsends']
+            print('\tRPC requests: %d' % sends)
+            print('\tRPC replies: %d' % self.__rpc_data['rpcreceives'])
+            print('\tXIDs not found: %d' % self.__rpc_data['badxids'])
+            if sends != 0:
+                print('\tAvg backlog length: %d' % \
+                    (float(self.__rpc_data['backlogutil']) / sends))
+            print('\tRead chunks: %d' % self.__rpc_data['read_chunks'])
+            print('\tWrite chunks: %d' % self.__rpc_data['write_chunks'])
+            print('\tReply chunks: %d' % self.__rpc_data['reply_chunks'])
+            print('\tRegistered: %d bytes' % self.__rpc_data['total_rdma_req'])
+            print('\tRDMA received: %d bytes' % self.__rpc_data['total_rdma_rep'])
+            print('\tTotal pull-up: %d bytes' % self.__rpc_data['pullup'])
+            print('\tTotal fix-up: %d bytes' % self.__rpc_data['fixup'])
+            print('\tHardway allocations: %d bytes' % self.__rpc_data['hardway'])
+            print('\tFailed marshals: %d' % self.__rpc_data['failed_marshal'])
+            print('\tBad replies: %d' % self.__rpc_data['bad_reply'])
+
+            """ Counters not present in all kernels """
+            if 'nomsg_calls' in self.__rpc_data:
+                print('\tRDMA_NOMSG calls: %d' % self.__rpc_data['nomsg_calls'])
+            if 'allocated_mrs' in self.__rpc_data:
+                print('\tAllocated MRs: %d' % self.__rpc_data['allocated_mrs'])
+            if 'recovered_mrs' in self.__rpc_data:
+                print('\tRecovered MRs: %d' % self.__rpc_data['recovered_mrs'])
+            if 'orphaned_mrs' in self.__rpc_data:
+                print('\tOrphaned MRs: %d' % self.__rpc_data['orphaned_mrs'])
+            if 'local_invalidates' in self.__rpc_data:
+                print('\tLocal Invalidates needed: %d' % self.__rpc_data['local_invalidates'])
+            if 'empty_sendctx_q' in self.__rpc_data:
+                print('\tEmpy sendctx queue count: %d' % self.__rpc_data['empty_sendctx_q'])
+            if 'reply_waits_for_send' in self.__rpc_data:
+                print('\tReplies that waited for Send completion: %d' % self.__rpc_data['reply_waits_for_send'])
+        else:
+            raise Exception('Unknown RPC transport protocol %s' % self.__rpc_data['protocol'])
+
 def parse_stats_file(f):
     """pop the contents of a mountstats file into a dictionary,
     keyed by mount point.  each value object is a list of the
@@ -681,7 +756,7 @@ def parse_stats_file(f):
 
     return ms_dict
 
-def print_mountstats(stats, nfs_only, rpc_only, raw):
+def print_mountstats(stats, nfs_only, rpc_only, raw, xprt_only):
     if nfs_only:
        stats.display_nfs_options()
        stats.display_nfs_events()
@@ -692,6 +767,8 @@ def print_mountstats(stats, nfs_only, rpc_only, raw):
        stats.display_rpc_op_stats()
     elif raw:
        stats.display_raw_stats()
+    elif xprt_only:
+       stats.display_xprt_stats()
     else:
        stats.display_nfs_options()
        stats.display_nfs_bytes()
@@ -734,14 +811,14 @@ def mountstats_command(args):
         stats = DeviceData()
         stats.parse_stats(mountstats[mp])
         if not args.since:
-            print_mountstats(stats, args.nfs_only, args.rpc_only, args.raw)
+            print_mountstats(stats, args.nfs_only, args.rpc_only, args.raw, args.xprt_only)
         elif args.since and mp not in old_mountstats:
-            print_mountstats(stats, args.nfs_only, args.rpc_only, args.raw)
+            print_mountstats(stats, args.nfs_only, args.rpc_only, args.raw, args.xprt_only)
         else:
             old_stats = DeviceData()
             old_stats.parse_stats(old_mountstats[mp])
             diff_stats = stats.compare_iostats(old_stats)
-            print_mountstats(diff_stats, args.nfs_only, args.rpc_only, args.raw)
+            print_mountstats(diff_stats, args.nfs_only, args.rpc_only, args.raw, args.xprt_only)
 
     args.infile.close()
     if args.since:
@@ -953,6 +1030,8 @@ def main():
         help='Display only the RPC statistics')
     group.add_argument('-R', '--raw', action='store_true',
         help='Display only the raw statistics')
+    group.add_argument('-x', '--xprt', action='store_true', dest='xprt_only',
+        help='Display only the xprt statistics')
     # The mountpoints argument cannot be moved into the common_parser because
     # it will screw up the parsing of the iostat arguments (interval and count)
     mountstats_parser.add_argument('mountpoints', nargs='*', metavar='mountpoint',

