Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbaKZTN7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:13:59 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDxOV027208
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:59 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDwSC002368
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:59 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJDw5L037738
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:58 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJDwO3037737
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:13:58 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 06/17] mountstats: Make ms-iostat output match that of nfs-iostat.py
Date: Wed, 26 Nov 2014 14:13:44 -0500
Message-Id: <1417029235-37675-7-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes mostly lifted straight from nfs-iostat.py.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 104 ++++++++++++++++++++++++-----------------
 1 file changed, 61 insertions(+), 43 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index cc5c6e5..729e01c 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -449,60 +449,78 @@ class DeviceData:
             result.__nfs_data[key] -= old_stats.__nfs_data[key]
         return result
 
+    def __print_rpc_op_stats(self, op, sample_time):
+        """Print generic stats for one RPC op
+        """
+        if op not in self.__rpc_data:
+            return
+
+        rpc_stats = self.__rpc_data[op]
+        ops = float(rpc_stats[0])
+        retrans = float(rpc_stats[1] - rpc_stats[0])
+        kilobytes = float(rpc_stats[3] + rpc_stats[4]) / 1024
+        rtt = float(rpc_stats[6])
+        exe = float(rpc_stats[7])
+
+        # prevent floating point exceptions
+        if ops != 0:
+            kb_per_op = kilobytes / ops
+            retrans_percent = (retrans * 100) / ops
+            rtt_per_op = rtt / ops
+            exe_per_op = exe / ops
+        else:
+            kb_per_op = 0.0
+            retrans_percent = 0.0
+            rtt_per_op = 0.0
+            exe_per_op = 0.0
+
+        op += ':'
+        print(format(op.lower(), '<16s'), end='')
+        print(format('ops/s', '>8s'), end='')
+        print(format('kB/s', '>16s'), end='')
+        print(format('kB/op', '>16s'), end='')
+        print(format('retrans', '>16s'), end='')
+        print(format('avg RTT (ms)', '>16s'), end='')
+        print(format('avg exe (ms)', '>16s'))
+
+        print(format((ops / sample_time), '>24.3f'), end='')
+        print(format((kilobytes / sample_time), '>16.3f'), end='')
+        print(format(kb_per_op, '>16.3f'), end='')
+        retransmits = '{0:>10.0f} ({1:>3.1f}%)'.format(retrans, retrans_percent).strip()
+        print(format(retransmits, '>16'), end='')
+        print(format(rtt_per_op, '>16.3f'), end='')
+        print(format(exe_per_op, '>16.3f'))
+
     def display_iostats(self, sample_time):
         """Display NFS and RPC stats in an iostat-like way
         """
         sends = float(self.__rpc_data['rpcsends'])
         if sample_time == 0:
             sample_time = float(self.__nfs_data['age'])
+        #  sample_time could still be zero if the export was just mounted.
+        #  Set it to 1 to avoid divide by zero errors in this case since we'll
+        #  likely still have relevant mount statistics to show.
+        #
+        if sample_time == 0:
+            sample_time = 1;
+        if sends != 0:
+            backlog = (float(self.__rpc_data['backlogutil']) / sends) / sample_time
+        else:
+            backlog = 0.0
 
         print()
         print('%s mounted on %s:' % \
             (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
+        print()
 
-        print('\top/s\trpc bklog')
-        print('\t%.2f' % (sends / sample_time), end=' ')
-        if sends != 0:
-            print('\t%.2f' % \
-                ((float(self.__rpc_data['backlogutil']) / sends) / sample_time))
-        else:
-            print('\t0.00')
-
-        # reads:  ops/s, kB/s, avg rtt, and avg exe
-        # XXX: include avg xfer size and retransmits?
-        read_rpc_stats = self.__rpc_data['READ']
-        ops = float(read_rpc_stats[0])
-        kilobytes = float(self.__nfs_data['serverreadbytes']) / 1024
-        rtt = float(read_rpc_stats[6])
-        exe = float(read_rpc_stats[7])
-
-        print('\treads:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)')
-        print('\t\t%.2f' % (ops / sample_time), end=' ')
-        print('\t\t%.2f' % (kilobytes / sample_time), end=' ')
-        if ops != 0:
-            print('\t\t%.2f' % (rtt / ops), end=' ')
-            print('\t\t%.2f' % (exe / ops))
-        else:
-            print('\t\t0.00', end=' ')
-            print('\t\t0.00')
-
-        # writes:  ops/s, kB/s, avg rtt, and avg exe
-        # XXX: include avg xfer size and retransmits?
-        write_rpc_stats = self.__rpc_data['WRITE']
-        ops = float(write_rpc_stats[0])
-        kilobytes = float(self.__nfs_data['serverwritebytes']) / 1024
-        rtt = float(write_rpc_stats[6])
-        exe = float(write_rpc_stats[7])
-
-        print('\twrites:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)')
-        print('\t\t%.2f' % (ops / sample_time), end=' ')
-        print('\t\t%.2f' % (kilobytes / sample_time), end=' ')
-        if ops != 0:
-            print('\t\t%.2f' % (rtt / ops), end=' ')
-            print('\t\t%.2f' % (exe / ops))
-        else:
-            print('\t\t0.00', end=' ')
-            print('\t\t0.00')
+        print(format('ops/s', '>16') + format('rpc bklog', '>16'))
+        print(format((sends / sample_time), '>16.3f'), end='')
+        print(format(backlog, '>16.3f'))
+        print()
+
+        self.__print_rpc_op_stats('READ', sample_time)
+        self.__print_rpc_op_stats('WRITE', sample_time)
+        sys.stdout.flush()
 
 def parse_stats_file(filename):
     """pop the contents of a mountstats file into a dictionary,
-- 
1.9.3

