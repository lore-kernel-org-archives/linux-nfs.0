Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423251AbbD2Oia (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 10:38:30 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] Documentation: remove overloads-avoided counter from knfsd-stats.txt
Date: Wed, 29 Apr 2015 10:38:26 -0400
Message-Id: <1430318306-26029-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'overloads-avoided' counter itself was removed several years ago by
commit 78c210e (Revert "knfsd: avoid overloading the CPU scheduler with
enormous load averages").

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 Documentation/filesystems/nfs/knfsd-stats.txt | 44 +++------------------------
 1 file changed, 4 insertions(+), 40 deletions(-)

diff --git a/Documentation/filesystems/nfs/knfsd-stats.txt b/Documentation/filesystems/nfs/knfsd-stats.txt
index 64ced51..1a5d821 100644
--- a/Documentation/filesystems/nfs/knfsd-stats.txt
+++ b/Documentation/filesystems/nfs/knfsd-stats.txt
@@ -68,16 +68,10 @@ sockets-enqueued
 	rate of change for this counter is zero; significantly non-zero
 	values may indicate a performance limitation.
 
-	This can happen either because there are too few nfsd threads in the
-	thread pool for the NFS workload (the workload is thread-limited),
-	or because the NFS workload needs more CPU time than is available in
-	the thread pool (the workload is CPU-limited).  In the former case,
-	configuring more nfsd threads will probably improve the performance
-	of the NFS workload.  In the latter case, the sunrpc server layer is
-	already choosing not to wake idle nfsd threads because there are too
-	many nfsd threads which want to run but cannot, so configuring more
-	nfsd threads will make no difference whatsoever.  The overloads-avoided
-	statistic (see below) can be used to distinguish these cases.
+	This can happen because there are too few nfsd threads in the thread
+	pool for the NFS workload (the workload is thread-limited), in which
+	case configuring more nfsd threads will probably improve the
+	performance of the NFS workload.
 
 threads-woken
 	Counts how many times an idle nfsd thread is woken to try to
@@ -88,36 +82,6 @@ threads-woken
 	thing.  The ideal rate of change for this counter will be close
 	to but less than the rate of change of the packets-arrived counter.
 
-overloads-avoided
-	Counts how many times the sunrpc server layer chose not to wake an
-	nfsd thread, despite the presence of idle nfsd threads, because
-	too many nfsd threads had been recently woken but could not get
-	enough CPU time to actually run.
-
-	This statistic counts a circumstance where the sunrpc layer
-	heuristically avoids overloading the CPU scheduler with too many
-	runnable nfsd threads.  The ideal rate of change for this counter
-	is zero.  Significant non-zero values indicate that the workload
-	is CPU limited.  Usually this is associated with heavy CPU usage
-	on all the CPUs in the nfsd thread pool.
-
-	If a sustained large overloads-avoided rate is detected on a pool,
-	the top(1) utility should be used to check for the following
-	pattern of CPU usage on all the CPUs associated with the given
-	nfsd thread pool.
-
-	 - %us ~= 0 (as you're *NOT* running applications on your NFS server)
-
-	 - %wa ~= 0
-
-	 - %id ~= 0
-
-	 - %sy + %hi + %si ~= 100
-
-	If this pattern is seen, configuring more nfsd threads will *not*
-	improve the performance of the workload.  If this patten is not
-	seen, then something more subtle is wrong.
-
 threads-timedout
 	Counts how many times an nfsd thread triggered an idle timeout,
 	i.e. was not woken to handle any incoming network packets for
-- 
1.9.3

