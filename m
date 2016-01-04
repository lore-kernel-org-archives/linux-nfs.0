Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35124 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbcADSVu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:50 -0500
Received: by mail-ig0-f174.google.com with SMTP id to4so249279977igc.0
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/18] NFS/pNFS: Fix up pNFS write reschedule layering violations and bugs
Date: Mon,  4 Jan 2016 13:21:05 -0500
Message-Id: <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flexfiles layout in particular, seems to want to poke around in the
O_DIRECT flags when retransmitting.
This patch sets up an interface to allow it to call back into O_DIRECT
to handle retransmission correctly. It also fixes a potential bug whereby
we could change the behaviour of O_DIRECT if an error is already pending.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c                        | 21 +++++++++++++++------
 fs/nfs/flexfilelayout/flexfilelayout.c | 13 +------------
 fs/nfs/internal.h                      |  1 -
 fs/nfs/write.c                         |  6 ++++++
 include/linux/nfs_xdr.h                |  1 +
 5 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4b1d08f56aba..e73693f75dee 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -117,12 +117,6 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
 	return atomic_dec_and_test(&dreq->io_count);
 }
 
-void nfs_direct_set_resched_writes(struct nfs_direct_req *dreq)
-{
-	dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-}
-EXPORT_SYMBOL_GPL(nfs_direct_set_resched_writes);
-
 static void
 nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
 {
@@ -839,10 +833,25 @@ static void nfs_write_sync_pgio_error(struct list_head *head)
 	}
 }
 
+static void nfs_direct_write_reschedule_io(struct nfs_pgio_header *hdr)
+{
+	struct nfs_direct_req *dreq = hdr->dreq;
+
+	spin_lock(&dreq->lock);
+	if (dreq->error == 0) {
+		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+		/* fake unstable write to let common nfs resend pages */
+		hdr->verf.committed = NFS_UNSTABLE;
+		hdr->good_bytes = hdr->args.count;
+	}
+	spin_unlock(&dreq->lock);
+}
+
 static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops = {
 	.error_cleanup = nfs_write_sync_pgio_error,
 	.init_hdr = nfs_direct_pgio_init,
 	.completion = nfs_direct_write_completion,
+	.reschedule_io = nfs_direct_write_reschedule_io,
 };
 
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 03516c80855a..df475d42df77 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -912,18 +912,7 @@ static void ff_layout_reset_write(struct nfs_pgio_header *hdr, bool retry_pnfs)
 			hdr->args.count,
 			(unsigned long long)hdr->args.offset);
 
-		if (!hdr->dreq) {
-			struct nfs_open_context *ctx;
-
-			ctx = nfs_list_entry(hdr->pages.next)->wb_context;
-			set_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
-			hdr->completion_ops->error_cleanup(&hdr->pages);
-		} else {
-			nfs_direct_set_resched_writes(hdr->dreq);
-			/* fake unstable write to let common nfs resend pages */
-			hdr->verf.committed = NFS_UNSTABLE;
-			hdr->good_bytes = hdr->args.count;
-		}
+		hdr->completion_ops->reschedule_io(hdr);
 		return;
 	}
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 313d55402238..99a2919047e9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -519,7 +519,6 @@ static inline void nfs_inode_dio_wait(struct inode *inode)
 	inode_dio_wait(inode);
 }
 extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
-extern void nfs_direct_set_resched_writes(struct nfs_direct_req *dreq);
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_pgio_header *);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b9316406930..0aa3e6b3db70 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1326,9 +1326,15 @@ static void nfs_async_write_error(struct list_head *head)
 	}
 }
 
+static void nfs_async_write_reschedule_io(struct nfs_pgio_header *hdr)
+{
+	nfs_async_write_error(&hdr->pages);
+}
+
 static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
 	.error_cleanup = nfs_async_write_error,
 	.completion = nfs_write_completion,
+	.reschedule_io = nfs_async_write_reschedule_io,
 };
 
 void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 11bbae44f4cb..e89dbb14138c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1460,6 +1460,7 @@ struct nfs_pgio_completion_ops {
 	void	(*error_cleanup)(struct list_head *head);
 	void	(*init_hdr)(struct nfs_pgio_header *hdr);
 	void	(*completion)(struct nfs_pgio_header *hdr);
+	void	(*reschedule_io)(struct nfs_pgio_header *hdr);
 };
 
 struct nfs_unlinkdata {
-- 
2.5.0

