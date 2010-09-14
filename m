Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1880 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752828Ab0INKxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 06:53:43 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pnfs: allow nfs4_proc_layoutreturn to sleep on barrier
Date: Tue, 14 Sep 2010 12:53:43 +0200
Message-Id: <1284461623-4625-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C8F53FA.5060308@panasas.com>
References: <4C8F53FA.5060308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

use lo_rpcwaitq and sleep on it in the rpc prepare phase while
there's need to wait on the layoutreturn barrier.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    8 ++++++++
 fs/nfs/pnfs.c     |   12 +-----------
 fs/nfs/pnfs.h     |    1 +
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f12568d..b21a711 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5683,9 +5683,17 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 	struct inode *ino = lrp->args.inode;
+	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *server = NFS_SERVER(ino);
 
 	dprintk("--> %s\n", __func__);
+	if ((lrp->args.return_type == RETURN_FILE) &&
+	    pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
+		dprintk("%s: waiting on barrier\n", __func__);
+		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
+		return;
+	}
+
 	if (nfs4_setup_sequence(server, NULL, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2450383..0e8bb6f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -714,7 +714,7 @@ pnfs_free_layout(struct pnfs_layout_hdr *lo,
 	dprintk("%s:Return\n", __func__);
 }
 
-static bool
+bool
 pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 			   struct pnfs_layout_range *range)
 {
@@ -804,16 +804,6 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 
 		spin_unlock(&ino->i_lock);
 
-		if (pnfs_return_layout_barrier(nfsi, &arg)) {
-			if (stateid) { /* callback */
-				status = -EAGAIN;
-				goto out_put;
-			}
-			dprintk("%s: waiting\n", __func__);
-			wait_event(nfsi->lo_waitq,
-				   !pnfs_return_layout_barrier(nfsi, &arg));
-		}
-
 		if (layoutcommit_needed(nfsi)) {
 			if (stateid && !wait) { /* callback */
 				dprintk("%s: layoutcommit pending\n", __func__);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f7f567e..81534aa 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -41,6 +41,7 @@ void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	loff_t pos, u64 count, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
+bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type, bool wait);
-- 
1.7.2.2

