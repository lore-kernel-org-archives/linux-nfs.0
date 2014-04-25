Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:51153 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaDYQwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 12:52:14 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so2471228igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 25 Apr 2014 09:52:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] nfs-iostat: Fix columnarization of RPC statistics
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 25 Apr 2014 12:52:11 -0400
Message-ID: <20140425165211.30699.73059.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note: format() is new with Python 2.6

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 tools/nfs-iostat/nfs-iostat.py |   31 +++++++++++++++++++------------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 341cdbf..6831c12 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -353,15 +353,21 @@ class DeviceData:
             exe_per_op = 0.0
 
         op += ':'
-        print('%s' % op.lower().ljust(15), end='')
-        print('  ops/s\t\t   kB/s\t\t  kB/op\t\tretrans\t\tavg RTT (ms)\tavg exe (ms)')
-
-        print('\t\t%7.3f' % (ops / sample_time), end='')
-        print('\t%7.3f' % (kilobytes / sample_time), end='')
-        print('\t%7.3f' % kb_per_op, end='')
-        print(' %7d (%3.1f%%)' % (retrans, retrans_percent), end='')
-        print('\t%7.3f' % rtt_per_op, end='')
-        print('\t%7.3f' % exe_per_op)
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
 
     def ops(self, sample_time):
         sends = float(self.__rpc_data['rpcsends'])
@@ -391,9 +397,10 @@ class DeviceData:
             (self.__nfs_data['export'], self.__nfs_data['mountpoint']))
         print()
 
-        print('   op/s\t\trpc bklog')
-        print('%7.2f' % (sends / sample_time), end='')
-        print('\t%7.2f' % backlog)
+        print(format('ops/s', '>16') + format('rpc bklog', '>16'))
+        print(format((sends / sample_time), '>16.3f'), end='')
+        print(format(backlog, '>16.3f'))
+        print()
 
         if which == 0:
             self.__print_rpc_op_stats('READ', sample_time)

