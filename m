Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38248 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753210AbdEIJVf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:21:35 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 29/32] RFC: sunrpc: remove pc_count
Date: Tue,  9 May 2017 11:20:07 +0200
Message-Id: <20170509092010.30752-30-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pc_count is the only writeable memeber of struct svc_procinfo, which is
a good candidate to be const-ified as it contains function pointers.

This patch just removes it and returns zero in the /proc file as the
count of calls per procedure doesn't seem all that useful.  But it's
just a dumb hack and we might need a proper fix instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/svc.h | 1 -
 net/sunrpc/stats.c         | 2 +-
 net/sunrpc/svc.c           | 3 ---
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8eeb39286422..cab77b0904b0 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -430,7 +430,6 @@ struct svc_procedure {
 	void			(*pc_release)(struct svc_rqst *);
 	unsigned int		pc_argsize;	/* argument struct size */
 	unsigned int		pc_ressize;	/* result struct size */
-	unsigned int		pc_count;	/* call count */
 	unsigned int		pc_cachetype;	/* cache info (NFS) */
 	unsigned int		pc_xdrressize;	/* maximum size of XDR reply */
 };
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 42053510b96b..f37d0fc835d7 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -102,7 +102,7 @@ void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
 			continue;
 		seq_printf(seq, "proc%d %u", i, vers->vs_nproc);
 		for (j = 0; j < vers->vs_nproc; j++, proc++)
-			seq_printf(seq, " %u", proc->pc_count);
+			seq_printf(seq, " %u", 0);
 		seq_putc(seq, '\n');
 	}
 }
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index bbf8d938812e..af74604fdadd 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1202,9 +1202,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	statp = resv->iov_base +resv->iov_len;
 	svc_putnl(resv, RPC_SUCCESS);
 
-	/* Bump per-procedure stats counter */
-	procp->pc_count++;
-
 	/* Initialize storage for argp and resp */
 	memset(rqstp->rq_argp, 0, procp->pc_argsize);
 	memset(rqstp->rq_resp, 0, procp->pc_ressize);
-- 
2.11.0

