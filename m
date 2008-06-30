From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] Python scripts: Report bandwidth in "kB/s" instead of
	"Kb/s"
Date: Mon, 30 Jun 2008 13:10:12 -0400
Message-ID: <20080630171011.9905.84503.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29549 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbYF3RKq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:10:46 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The proper abbreviation for kilobytes per second is kB/s.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 tools/mountstats/mountstats.py |    8 ++++----
 tools/nfs-iostat/nfs-iostat.py |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)


diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index f55595e..c475c9e 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -317,7 +317,7 @@ class DeviceData:
         else:
             print '\t0.00'
 
-        # reads:  ops/s, Kb/s, avg rtt, and avg exe
+        # reads:  ops/s, kB/s, avg rtt, and avg exe
         # XXX: include avg xfer size and retransmits?
         read_rpc_stats = self.__rpc_data['READ']
         ops = float(read_rpc_stats[0])
@@ -325,7 +325,7 @@ class DeviceData:
         rtt = float(read_rpc_stats[6])
         exe = float(read_rpc_stats[7])
 
-        print '\treads:\tops/s\t\tKb/s\t\tavg RTT (ms)\tavg exe (ms)'
+        print '\treads:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)'
         print '\t\t%.2f' % (ops / sample_time),
         print '\t\t%.2f' % (kilobytes / sample_time),
         if ops != 0:
@@ -335,7 +335,7 @@ class DeviceData:
             print '\t\t0.00',
             print '\t\t0.00'
 
-        # writes:  ops/s, Kb/s, avg rtt, and avg exe
+        # writes:  ops/s, kB/s, avg rtt, and avg exe
         # XXX: include avg xfer size and retransmits?
         write_rpc_stats = self.__rpc_data['WRITE']
         ops = float(write_rpc_stats[0])
@@ -343,7 +343,7 @@ class DeviceData:
         rtt = float(write_rpc_stats[6])
         exe = float(write_rpc_stats[7])
 
-        print '\twrites:\tops/s\t\tKb/s\t\tavg RTT (ms)\tavg exe (ms)'
+        print '\twrites:\tops/s\t\tkB/s\t\tavg RTT (ms)\tavg exe (ms)'
         print '\t\t%.2f' % (ops / sample_time),
         print '\t\t%.2f' % (kilobytes / sample_time),
         if ops != 0:
diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 649c1bd..9626d42 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -344,7 +344,7 @@ class DeviceData:
 
         op += ':'
         print '%s' % op.lower().ljust(15),
-        print '  ops/s\t\t   Kb/s\t\t  Kb/op\t\tretrans\t\tavg RTT (ms)\tavg exe (ms)'
+        print '  ops/s\t\t   kB/s\t\t  kB/op\t\tretrans\t\tavg RTT (ms)\tavg exe (ms)'
 
         print '\t\t%7.3f' % (ops / sample_time),
         print '\t%7.3f' % (kilobytes / sample_time),

