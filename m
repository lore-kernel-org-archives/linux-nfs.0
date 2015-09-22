Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36732 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757795AbbIVDgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 23:36:20 -0400
Received: by padbj2 with SMTP id bj2so9879661pad.3
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 20:36:19 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v2] NFS41: make close wait for layoutreturn
Date: Tue, 22 Sep 2015 11:35:22 +0800
Message-Id: <1442892922-10834-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we send a layoutreturn asynchronously before close, the close
might reach server first and layoutreturn would fail with BADSTATEID
because there is nothing keeping the layout stateid alive.

Also do not pretend sending layoutreturn if we are not.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
v2: grab lo refcount when doing ROC

 fs/nfs/nfs4proc.c | 17 +++++++++++++++++
 fs/nfs/pnfs.c     | 35 +++++++++++++++++++++++++----------
 fs/nfs/pnfs.h     |  7 +++++++
 3 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 693b903..05f2da4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2645,6 +2645,15 @@ out:
 	return err;
 }
 
+static bool
+nfs4_wait_on_layoutreturn(struct inode *inode, struct rpc_task *task)
+{
+	if (!nfs_have_layout(inode))
+		return false;
+
+	return pnfs_wait_on_layoutreturn(inode, task);
+}
+
 struct nfs4_closedata {
 	struct inode *inode;
 	struct nfs4_state *state;
@@ -2763,6 +2772,11 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		goto out_no_action;
 	}
 
+	if (nfs4_wait_on_layoutreturn(inode, task)) {
+		nfs_release_seqid(calldata->arg.seqid);
+		goto out_wait;
+	}
+
 	if (calldata->arg.fmode == 0)
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
 	if (calldata->roc)
@@ -5308,6 +5322,9 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
+	if (nfs4_wait_on_layoutreturn(d_data->inode, task))
+		return;
+
 	if (d_data->roc)
 		pnfs_roc_get_barrier(d_data->inode, &d_data->roc_barrier);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ba12464..8abe271 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1104,20 +1104,15 @@ bool pnfs_roc(struct inode *ino)
 			mark_lseg_invalid(lseg, &tmp_list);
 			found = true;
 		}
-	/* pnfs_prepare_layoutreturn() grabs lo ref and it will be put
-	 * in pnfs_roc_release(). We don't really send a layoutreturn but
-	 * still want others to view us like we are sending one!
-	 *
-	 * If pnfs_prepare_layoutreturn() fails, it means someone else is doing
-	 * LAYOUTRETURN, so we proceed like there are no layouts to return.
-	 *
-	 * ROC in three conditions:
+	/* ROC in two conditions:
 	 * 1. there are ROC lsegs
 	 * 2. we don't send layoutreturn
-	 * 3. no others are sending layoutreturn
 	 */
-	if (found && !layoutreturn && pnfs_prepare_layoutreturn(lo))
+	if (found && !layoutreturn) {
+		/* lo ref dropped in pnfs_roc_release() */
+		pnfs_get_layout_hdr(lo);
 		roc = true;
+	}
 
 out_noroc:
 	spin_unlock(&ino->i_lock);
@@ -1172,6 +1167,26 @@ void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
 	spin_unlock(&ino->i_lock);
 }
 
+bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+        struct pnfs_layout_hdr *lo;
+        bool sleep = false;
+
+	/* we might not have grabbed lo reference. so need to check under
+	 * i_lock */
+        spin_lock(&ino->i_lock);
+        lo = nfsi->layout;
+        if (lo && test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+                sleep = true;
+        spin_unlock(&ino->i_lock);
+
+        if (sleep)
+                rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
+
+        return sleep;
+}
+
 /*
  * Compare two layout segments for sorting into layout cache.
  * We want to preferentially return RW over RO layouts, so ensure those
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 78c9351..d1990e9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -270,6 +270,7 @@ bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier);
+bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task);
 void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
@@ -639,6 +640,12 @@ pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
 {
 }
 
+static inline bool
+pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
+{
+	return false;
+}
+
 static inline void set_pnfs_layoutdriver(struct nfs_server *s,
 					 const struct nfs_fh *mntfh, u32 id)
 {
-- 
1.8.3.1

