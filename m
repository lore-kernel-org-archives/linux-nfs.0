Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:11444 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754850Ab3KYR54 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 12:57:56 -0500
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 fix a kswap nfs4_state_manger race
Date: Mon, 25 Nov 2013 12:57:50 -0500
Message-ID: <1385402270-14284-2-git-send-email-andros@netapp.com>
In-Reply-To: <1385402270-14284-1-git-send-email-andros@netapp.com>
References: <1385402270-14284-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The state manager is recovering expired state and recovery OPENs are being
processed. If kswapd is pruning inodes at the same time, a deadlock can occur
when kswapd calls evict_inode on an NFSv4.1 inode with a layout, and the
resultant layoutreturn gets an error that the state mangager is to handle,
causing the layoutreturn to wait on the (NFS client) cl_rpcwaitq.

At the same time an open is waiting for the inode deletion to complete in
__wait_on_freeing_inode.

If the open is either the open called by the state manager, or an open from
the same open owner that is holding the NFSv4.0 sequence id which causes the
OPEN from the state manager to wait for the sequence id on the Seqid_waitqueue,
then the state is deadlocked with kswapd.

Do not handle LAYOUTRETURN errors when called from nfs4_evict_inode.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c       | 6 ++++++
 fs/nfs/pnfs.c           | 5 ++++-
 include/linux/nfs_xdr.h | 1 +
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ca36d0d..fbeadf3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7596,6 +7596,12 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		return;
 
 	server = NFS_SERVER(lrp->args.inode);
+
+	/* Error handling can dead lock the state manager running open
+	 * recovery when kswapd is also pruning inodes. */
+	if (lrp->ino_freeing)
+		return;
+
 	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d75d938..a55ebf2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -819,7 +819,7 @@ _pnfs_return_layout(struct inode *ino)
 	LIST_HEAD(tmp_list);
 	struct nfs4_layoutreturn *lrp;
 	nfs4_stateid stateid;
-	int status = 0, empty;
+	int status = 0, empty, freeing = 0;
 
 	dprintk("NFS: %s for inode %lu\n", __func__, ino->i_ino);
 
@@ -844,6 +844,8 @@ _pnfs_return_layout(struct inode *ino)
 		goto out;
 	}
 	lo->plh_block_lgets++;
+	if (ino->i_state & I_FREEING)
+		freeing = 1;
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
@@ -863,6 +865,7 @@ _pnfs_return_layout(struct inode *ino)
 	lrp->args.layout = lo;
 	lrp->clp = NFS_SERVER(ino)->nfs_client;
 	lrp->cred = lo->plh_lc_cred;
+	lrp->ino_freeing = freeing;
 
 	status = nfs4_proc_layoutreturn(lrp);
 out:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ccfcec..b815345 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -316,6 +316,7 @@ struct nfs4_layoutreturn {
 	struct nfs4_layoutreturn_res res;
 	struct rpc_cred *cred;
 	struct nfs_client *clp;
+	int ino_freeing;
 	int rpc_status;
 };
 
-- 
1.8.3.1

