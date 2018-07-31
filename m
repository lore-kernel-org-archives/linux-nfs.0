Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60974 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729592AbeGaPvX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 11:51:23 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2D2594021701
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 14:10:52 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 21ADE10EE6C3
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 14:10:52 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3] sunrpc: Change rpc_print_iostats to rpc_clnt_show_stats and handle rpc_clnt clones
Date: Tue, 31 Jul 2018 10:10:51 -0400
Message-Id: <20180731141051.1482-1-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The existing rpc_print_iostats has a few shortcomings.  First, the naming
is not consistent with other functions in the kernel that display stats.
Second, it is really displaying stats for an rpc_clnt structure as it
displays both xprt stats and per-op stats.  Third, it does not handle
rpc_clnt clones, which is important for the one in-kernel tree caller
of this function, the NFS client's nfs_show_stats function.

Fix all of the above by renaming the rpc_print_iostats to
rpc_clnt_show_stats and looping through any rpc_clnt clones via
cl_parent.

Once this interface is fixed, this addresses a problem with NFSv4.
Before this patch, the /proc/self/mountstats always showed incorrect
counts for NFSv4 lease and session related opcodes such as SEQUENCE,
RENEW, SETCLIENTID, CREATE_SESSION, etc.  These counts were always 0
even though many ops would go over the wire.  The reason for this is
there are multiple rpc_clnt structures allocated for any given NFSv4
mount, and inside nfs_show_stats() we callled into rpc_print_iostats()
which only handled one of them, nfs_server->client.  Fix these counts
by calling sunrpc's new rpc_clnt_show_stats() function, which handles
cloned rpc_clnt structs and prints the stats together.

Note that one side-effect of the above is that multiple mounts from
the same NFS server will show identical counts in the above ops due
to the fact the one rpc_clnt (representing the NFSv4 client state)
is shared across mounts.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/super.c                 |  2 +-
 include/linux/sunrpc/metrics.h |  4 ++--
 net/sunrpc/stats.c             | 17 ++++++++++++-----
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5e470e233c83..bdf39fa1bfbc 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -884,7 +884,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 #endif
 	seq_printf(m, "\n");
 
-	rpc_print_iostats(m, nfss->client);
+	rpc_clnt_show_stats(m, nfss->client);
 
 	return 0;
 }
diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
index 9baed7b355b2..1b3751327575 100644
--- a/include/linux/sunrpc/metrics.h
+++ b/include/linux/sunrpc/metrics.h
@@ -82,7 +82,7 @@ void			rpc_count_iostats(const struct rpc_task *,
 					  struct rpc_iostats *);
 void			rpc_count_iostats_metrics(const struct rpc_task *,
 					  struct rpc_iostats *);
-void			rpc_print_iostats(struct seq_file *, struct rpc_clnt *);
+void			rpc_clnt_show_stats(struct seq_file *, struct rpc_clnt *);
 void			rpc_free_iostats(struct rpc_iostats *);
 
 #else  /*  CONFIG_PROC_FS  */
@@ -95,7 +95,7 @@ static inline void rpc_count_iostats_metrics(const struct rpc_task *task,
 {
 }
 
-static inline void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt) {}
+static inline void rpc_clnt_show_stats(struct seq_file *seq, struct rpc_clnt *clnt) {}
 static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
 
 #endif  /*  CONFIG_PROC_FS  */
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 32adddd7fb78..ffae7c2245b1 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -235,13 +235,12 @@ static void _print_rpc_iostats(struct seq_file *seq, struct rpc_iostats *stats,
 		   ktime_to_ms(stats->om_execute));
 }
 
-void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
+void rpc_clnt_show_stats(struct seq_file *seq, struct rpc_clnt *clnt)
 {
-	struct rpc_iostats *stats = clnt->cl_metrics;
 	struct rpc_xprt *xprt;
 	unsigned int op, maxproc = clnt->cl_maxproc;
 
-	if (!stats)
+	if (!clnt->cl_metrics)
 		return;
 
 	seq_printf(seq, "\tRPC iostats version: %s  ", RPC_IOSTATS_VERS);
@@ -256,10 +255,18 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
 
 	seq_printf(seq, "\tper-op statistics\n");
 	for (op = 0; op < maxproc; op++) {
-		_print_rpc_iostats(seq, &stats[op], op, clnt->cl_procinfo);
+		struct rpc_iostats stats = {};
+		struct rpc_clnt *next = clnt;
+		do {
+			_add_rpc_iostats(&stats, &next->cl_metrics[op]);
+			if (next == next->cl_parent)
+				break;
+			next = next->cl_parent;
+		} while (next);
+		_print_rpc_iostats(seq, &stats, op, clnt->cl_procinfo);
 	}
 }
-EXPORT_SYMBOL_GPL(rpc_print_iostats);
+EXPORT_SYMBOL_GPL(rpc_clnt_show_stats);
 
 /*
  * Register/unregister RPC proc files
-- 
2.14.3

