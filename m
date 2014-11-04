Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:58971 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaKDWOi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 17:14:38 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so8246673iga.15
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2014 14:14:37 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id c18sm728530ioe.22.2014.11.04.14.14.36
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Nov 2014 14:14:37 -0800 (PST)
Subject: [PATCH] mountstats: Sort RPC statistics by operation count
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Tue, 04 Nov 2014 17:14:35 -0500
Message-ID: <20141104221043.13019.51333.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sort the RPC statistics in descending order by operation count, so
that the most frequently executed operation appears at the top of
the listing (a la `top`).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hey folks-

Any opinions about this? I considered adding a "--sort" command line
option to enable sorting, but instead made it always-on.

Could also use --sort to specify which individual statistic is used
for sorting (op count, RTT, retransmit rate, and so forth).

Try: watch -d "mountstats --rpc /mnt/your-mount-here"

 tools/mountstats/mountstats.py |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 9a6ec43..f75103c 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -24,6 +24,7 @@ MA 02110-1301 USA
 """
 
 import sys, os, time
+from operator import itemgetter
 
 Mountstats_version = '0.2'
 
@@ -262,27 +263,29 @@ class DeviceData:
         """
         sends = self.__rpc_data['rpcsends']
 
-        # XXX: these should be sorted by 'count'
-        print()
+        allstats = []
         for op in self.__rpc_data['ops']:
-            stats = self.__rpc_data[op]
-            count = stats[0]
-            retrans = stats[1] - count
+            allstats.append([op] + self.__rpc_data[op])
+
+        print()
+        for stats in sorted(allstats, key=itemgetter(1), reverse=True):
+            count = stats[1]
             if count != 0:
-                print('%s:' % op)
+                print('%s:' % stats[0])
                 print('\t%d ops (%d%%)' % \
                     (count, ((count * 100) / sends)), end=' ')
+                retrans = stats[2] - count
                 if retrans != 0:
                     print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
-                    print('\t%d major timeouts' % stats[2])
+                    print('\t%d major timeouts' % stats[3])
                 else:
                     print('')
                 print('\tavg bytes sent per op: %d\tavg bytes received per op: %d' % \
-                    (stats[3] / count, stats[4] / count))
-                print('\tbacklog wait: %f' % (float(stats[5]) / count), end=' ')
-                print('\tRTT: %f' % (float(stats[6]) / count), end=' ')
+                    (stats[4] / count, stats[5] / count))
+                print('\tbacklog wait: %f' % (float(stats[6]) / count), end=' ')
+                print('\tRTT: %f' % (float(stats[7]) / count), end=' ')
                 print('\ttotal execute time: %f (milliseconds)' % \
-                    (float(stats[7]) / count))
+                    (float(stats[8]) / count))
 
     def compare_iostats(self, old_stats):
         """Return the difference between two sets of stats

