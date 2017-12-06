Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:42914 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdLFQEj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 11:04:39 -0500
Received: by mail-io0-f193.google.com with SMTP id u42so3186218ioi.9
        for <linux-nfs@vger.kernel.org>; Wed, 06 Dec 2017 08:04:39 -0800 (PST)
Subject: [PATCH v1] mountstats: Add option to pretty-print xprt statistics
From: Chuck Lever <chuck.lever@oracle.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 06 Dec 2017 11:04:36 -0500
Message-ID: <20171206160236.16373.93332.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add "-x" option to display the statistics reported on the "xprt:"
line in mountstats. This is not terribly interesting for UDP and
TCP, but it can be for RDMA transports.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Changes since RFC-v3:
- More testing
- Add maxslots/sending/pending utilization statistics

Hi Steve- Please consider this update for the mountstats command.


 tools/mountstats/mountstats.man |    5 ++
 tools/mountstats/mountstats.py  |  125 +++++++++++++++++++++++++++++++++++----
 2 files changed, 117 insertions(+), 13 deletions(-)
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
index 29b5f5a..440aa72
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -87,7 +87,10 @@ XprtUdpCounters = [
     'rpcreceives',
     'badxids',
     'inflightsends',
-    'backlogutil'
+    'backlogutil',
+    'maxslots',
+    'sendutil',
+    'pendutil'
 ]
 
 XprtTcpCounters = [
@@ -100,7 +103,10 @@ XprtTcpCounters = [
     'rpcreceives',
     'badxids',
     'inflightsends',
-    'backlogutil'
+    'backlogutil',
+    'maxslots',
+    'sendutil',
+    'pendutil'
 ]
 
 XprtRdmaCounters = [
@@ -112,6 +118,7 @@ XprtRdmaCounters = [
     'rpcsends',
     'rpcreceives',
     'badxids',
+    'inflightsends',
     'backlogutil',
     'read_chunks',
     'write_chunks',
@@ -122,7 +129,14 @@ XprtRdmaCounters = [
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
@@ -273,17 +287,20 @@ class DeviceData:
             if words[1] == 'udp':
                 i = 2
                 for key in XprtUdpCounters:
-                    self.__rpc_data[key] = int(words[i])
+                    if i < len(words):
+                        self.__rpc_data[key] = int(words[i])
                     i += 1
             elif words[1] == 'tcp':
                 i = 2
                 for key in XprtTcpCounters:
-                    self.__rpc_data[key] = int(words[i])
+                    if i < len(words):
+                        self.__rpc_data[key] = int(words[i])
                     i += 1
             elif words[1] == 'rdma':
                 i = 2
                 for key in XprtRdmaCounters:
-                    self.__rpc_data[key] = int(words[i])
+                    if i < len(words):
+                        self.__rpc_data[key] = int(words[i])
                     i += 1
         elif words[0] == 'per-op':
             self.__rpc_data['per-op'] = words
@@ -361,12 +378,11 @@ class DeviceData:
     def display_stats_header(self):
         print('Stats for %s mounted on %s:' % \
             (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
+        print()
 
     def display_nfs_options(self):
         """Pretty-print the NFS options
         """
-        self.display_stats_header()
-
         print('  NFS mount options: %s' % ','.join(self.__nfs_data['mountoptions']))
         print('  NFS server capabilities: %s' % ','.join(self.__nfs_data['servercapabilities']))
         if 'nfsv4flags' in self.__nfs_data:
@@ -432,7 +448,6 @@ class DeviceData:
         """
         sends = self.__rpc_data['rpcsends']
 
-        print()
         print('RPC statistics:')
 
         print('  %d RPC requests sent, %d RPC replies received (%d XIDs not found)' % \
@@ -655,6 +670,83 @@ class DeviceData:
         self.__print_rpc_op_stats('WRITE', sample_time)
         sys.stdout.flush()
 
+    def display_xprt_stats(self):
+        """Pretty-print the xprt statistics
+        """
+        if self.__rpc_data['protocol'] == 'udp':
+            print('\tTransport protocol: udp')
+            print('\tSource port: %d' % self.__rpc_data['port'])
+            print('\tBind count: %d' % self.__rpc_data['bind_count'])
+            print('\tRPC requests: %d' % self.__rpc_data['rpcsends'])
+            print('\tRPC replies: %d' % self.__rpc_data['rpcreceives'])
+            print('\tXIDs not found: %d' % self.__rpc_data['badxids'])
+            print('\tMax slots: %d' % self.__rpc_data['maxslots'])
+            if self.__rpc_data['rpcsends'] != 0:
+                print('\tAvg backlog length: %d' % \
+                    (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
+                print('\tAvg send queue length: %d' % \
+                    (float(self.__rpc_data['sendutil']) / self.__rpc_data['rpcsends']))
+                print('\tAvg pending queue length: %d' % \
+                    (float(self.__rpc_data['pendutil']) / self.__rpc_data['rpcsends']))
+        elif self.__rpc_data['protocol'] == 'tcp':
+            print('\tTransport protocol: tcp')
+            print('\tSource port: %d' % self.__rpc_data['port'])
+            print('\tBind count: %d' % self.__rpc_data['bind_count'])
+            print('\tConnect count: %d' % self.__rpc_data['connect_count'])
+            print('\tConnect time: %d seconds' % self.__rpc_data['connect_time'])
+            print('\tIdle time: %d seconds' % self.__rpc_data['idle_time'])
+            print('\tRPC requests: %d' % self.__rpc_data['rpcsends'])
+            print('\tRPC replies: %d' % self.__rpc_data['rpcreceives'])
+            print('\tXIDs not found: %d' % self.__rpc_data['badxids'])
+            print('\tMax slots: %d' % self.__rpc_data['maxslots'])
+            if self.__rpc_data['rpcsends'] != 0:
+                print('\tAvg backlog length: %d' % \
+                    (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
+                print('\tAvg send queue length: %d' % \
+                    (float(self.__rpc_data['sendutil']) / self.__rpc_data['rpcsends']))
+                print('\tAvg pending queue length: %d' % \
+                    (float(self.__rpc_data['pendutil']) / self.__rpc_data['rpcsends']))
+        elif self.__rpc_data['protocol'] == 'rdma':
+            print('\tTransport protocol: rdma')
+            print('\tConnect count: %d' % self.__rpc_data['connect_count'])
+            print('\tConnect time: %d seconds' % self.__rpc_data['connect_time'])
+            print('\tIdle time: %d seconds' % self.__rpc_data['idle_time'])
+            sends = self.__rpc_data['rpcsends']
+            print('\tRPC requests: %d' % self.__rpc_data['rpcsends'])
+            print('\tRPC replies: %d' % self.__rpc_data['rpcreceives'])
+            print('\tXIDs not found: %d' % self.__rpc_data['badxids'])
+            if self.__rpc_data['rpcsends'] != 0:
+                print('\tAvg backlog length: %d' % \
+                    (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
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
+                print('\tEmpty sendctx queue count: %d' % self.__rpc_data['empty_sendctx_q'])
+            if 'reply_waits_for_send' in self.__rpc_data:
+                print('\tReplies that waited for Send completion: %d' % self.__rpc_data['reply_waits_for_send'])
+        else:
+            raise Exception('Unknown RPC transport protocol %s' % self.__rpc_data['protocol'])
+
 def parse_stats_file(f):
     """pop the contents of a mountstats file into a dictionary,
     keyed by mount point.  each value object is a list of the
@@ -681,8 +773,9 @@ def parse_stats_file(f):
 
     return ms_dict
 
-def print_mountstats(stats, nfs_only, rpc_only, raw):
+def print_mountstats(stats, nfs_only, rpc_only, raw, xprt_only):
     if nfs_only:
+       stats.display_stats_header()
        stats.display_nfs_options()
        stats.display_nfs_events()
        stats.display_nfs_bytes()
@@ -692,7 +785,11 @@ def print_mountstats(stats, nfs_only, rpc_only, raw):
        stats.display_rpc_op_stats()
     elif raw:
        stats.display_raw_stats()
+    elif xprt_only:
+       stats.display_stats_header()
+       stats.display_xprt_stats()
     else:
+       stats.display_stats_header()
        stats.display_nfs_options()
        stats.display_nfs_bytes()
        stats.display_rpc_generic_stats()
@@ -734,14 +831,14 @@ def mountstats_command(args):
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
@@ -953,6 +1050,8 @@ def main():
         help='Display only the RPC statistics')
     group.add_argument('-R', '--raw', action='store_true',
         help='Display only the raw statistics')
+    group.add_argument('-x', '--xprt', action='store_true', dest='xprt_only',
+        help='Display only the xprt statistics')
     # The mountpoints argument cannot be moved into the common_parser because
     # it will screw up the parsing of the iostat arguments (interval and count)
     mountstats_parser.add_argument('mountpoints', nargs='*', metavar='mountpoint',

