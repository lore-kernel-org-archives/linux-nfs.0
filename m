Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1447 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755364Ab2BNVUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 16:20:07 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/1] SUNRPC: add sending,pending queue and max slot to xprt stats
Date: Tue, 14 Feb 2012 16:19:18 -0500
Message-Id: <1329254358-1638-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

With static RPC slots, the xprt backlog queue stats were useful in showing
when the transport (TCP) was starved by lack of RPC slots. The new dynamic
RPC slot code, commit d9ba131d8f58c0d2ff5029e7002ab43f913b36f9, always
provides an RPC slot and so only uses the xprt backlog queue when the
tcp_max_slot_table_entries value has been hit or when an allocation error
occurs. All requests are now placed on the xprt sending or pending queue which
need to be monitored for debugging.

The max_slot stat shows the maximum number of dynamic RPC slots reached which is
useful when debugging performance issues.

Add the new fields at the end of the mountstats xprt stanza so that mountstats
outputs the previous correct values and ignores the new fields. Bump
NFS_IOSTATS_VERS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfs_iostat.h  |    2 +-
 include/linux/sunrpc/xprt.h |    7 +++++--
 net/sunrpc/xprt.c           |    7 ++++++-
 net/sunrpc/xprtsock.c       |   23 +++++++++++++++++------
 4 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
index 8866bb3..9dcbbe9 100644
--- a/include/linux/nfs_iostat.h
+++ b/include/linux/nfs_iostat.h
@@ -21,7 +21,7 @@
 #ifndef _LINUX_NFS_IOSTAT
 #define _LINUX_NFS_IOSTAT
 
-#define NFS_IOSTAT_VERS		"1.0"
+#define NFS_IOSTAT_VERS		"1.1"
 
 /*
  * NFS byte counters
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 15518a1..344b6f2 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -219,10 +219,13 @@ struct rpc_xprt {
 					connect_time,	/* jiffies waiting for connect */
 					sends,		/* how many complete requests */
 					recvs,		/* how many complete requests */
-					bad_xids;	/* lookup_rqst didn't find XID */
+					bad_xids,	/* lookup_rqst didn't find XID */
+					max_slots;	/* max rpc_slots used */
 
 		unsigned long long	req_u,		/* average requests on the wire */
-					bklog_u;	/* backlog queue utilization */
+					bklog_u,	/* backlog queue utilization */
+					sending_u,	/* send q utilization */
+					pending_u;	/* pend q utilization */
 	} stat;
 
 	struct net		*xprt_net;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c64c0ef..fb95e25 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -884,7 +884,7 @@ void xprt_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
-	int status;
+	int status, numreqs;
 
 	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
@@ -921,9 +921,14 @@ void xprt_transmit(struct rpc_task *task)
 
 	xprt->ops->set_retrans_timeout(task);
 
+	numreqs = atomic_read(&xprt->num_reqs);
+	if (numreqs > xprt->stat.max_slots)
+		xprt->stat.max_slots = numreqs;
 	xprt->stat.sends++;
 	xprt->stat.req_u += xprt->stat.sends - xprt->stat.recvs;
 	xprt->stat.bklog_u += xprt->backlog.qlen;
+	xprt->stat.sending_u += xprt->sending.qlen;
+	xprt->stat.pending_u += xprt->pending.qlen;
 
 	/* Don't race with disconnect */
 	if (!xprt_connected(xprt))
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 55472c4..4c8281d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2227,7 +2227,7 @@ static void xs_local_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
 	seq_printf(seq, "\txprt:\tlocal %lu %lu %lu %ld %lu %lu %lu "
-			"%llu %llu\n",
+			"%llu %llu %lu %llu %llu\n",
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
 			xprt->stat.connect_time,
@@ -2236,7 +2236,10 @@ static void xs_local_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			xprt->stat.recvs,
 			xprt->stat.bad_xids,
 			xprt->stat.req_u,
-			xprt->stat.bklog_u);
+			xprt->stat.bklog_u,
+			xprt->stat.max_slots,
+			xprt->stat.sending_u,
+			xprt->stat.pending_u);
 }
 
 /**
@@ -2249,14 +2252,18 @@ static void xs_udp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
-	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %Lu %Lu\n",
+	seq_printf(seq, "\txprt:\tudp %u %lu %lu %lu %lu %llu %llu "
+			"%lu %llu %llu\n",
 			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.sends,
 			xprt->stat.recvs,
 			xprt->stat.bad_xids,
 			xprt->stat.req_u,
-			xprt->stat.bklog_u);
+			xprt->stat.bklog_u,
+			xprt->stat.max_slots,
+			xprt->stat.sending_u,
+			xprt->stat.pending_u);
 }
 
 /**
@@ -2273,7 +2280,8 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	if (xprt_connected(xprt))
 		idle_time = (long)(jiffies - xprt->last_used) / HZ;
 
-	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
+	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu "
+			"%llu %llu %lu %llu %llu\n",
 			transport->srcport,
 			xprt->stat.bind_count,
 			xprt->stat.connect_count,
@@ -2283,7 +2291,10 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			xprt->stat.recvs,
 			xprt->stat.bad_xids,
 			xprt->stat.req_u,
-			xprt->stat.bklog_u);
+			xprt->stat.bklog_u,
+			xprt->stat.max_slots,
+			xprt->stat.sending_u,
+			xprt->stat.pending_u);
 }
 
 /*
-- 
1.7.6.4

