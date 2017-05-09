Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:39031 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752926AbdEIJUw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:52 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 14/32] RFC: sunrpc: remove p_count
Date: Tue,  9 May 2017 11:19:52 +0200
Message-Id: <20170509092010.30752-15-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

p_count is the only writeable memeber of struct rpc_procinfo, which is
a good candidate to be const-ified as it contains function pointers.

This patch just removes it and returns zero in the /proc file as the
count of calls per procedure doesn't seem all that useful.  But it's
just a dumb hack and we might need a proper fix instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/clnt.h | 1 -
 net/sunrpc/clnt.c           | 1 -
 net/sunrpc/stats.c          | 3 +--
 3 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6095ecba0dde..d1f6778c7da7 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -99,7 +99,6 @@ struct rpc_procinfo {
 	kxdrdproc_t		p_decode;	/* XDR decode function */
 	unsigned int		p_arglen;	/* argument hdr length (u32) */
 	unsigned int		p_replen;	/* reply hdr length (u32) */
-	unsigned int		p_count;	/* call count */
 	unsigned int		p_timer;	/* Which RTT timer to use */
 	u32			p_statidx;	/* Which procedure to account */
 	const char *		p_name;		/* name of procedure */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bdb75f7488e9..e6d2ae49d791 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1532,7 +1532,6 @@ call_start(struct rpc_task *task)
 			(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
 	/* Increment call count */
-	task->tk_msg.rpc_proc->p_count++;
 	clnt->cl_stats->rpccnt++;
 	task->tk_action = call_reserve;
 }
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index caeb01ad2b5a..88b1e18c0dd6 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -55,8 +55,7 @@ static int rpc_proc_show(struct seq_file *seq, void *v) {
 		seq_printf(seq, "proc%u %u",
 					vers->number, vers->nrprocs);
 		for (j = 0; j < vers->nrprocs; j++)
-			seq_printf(seq, " %u",
-					vers->procs[j].p_count);
+			seq_printf(seq, " %u", 0);
 		seq_putc(seq, '\n');
 	}
 	return 0;
-- 
2.11.0

