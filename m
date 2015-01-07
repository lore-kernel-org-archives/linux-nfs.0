Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39736 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755080AbbAGA3j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 19:29:39 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so1006857pdb.11
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 16:29:38 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 26/49] nfs41: don't use a layout if it is marked for returning
Date: Tue,  6 Jan 2015 16:28:31 -0800
Message-Id: <1420590534-84063-27-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

And if we are to return the same type of layouts, don't bother
sending more layoutgets.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/nfs4proc.c |  1 +
 fs/nfs/pnfs.c     | 23 ++++++++++++++++++-----
 fs/nfs/pnfs.h     |  1 +
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1dff02a..617ca2e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7531,6 +7531,7 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 		return;
 	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
 					  NFS_I(lgp->args.inode)->layout,
+					  &lgp->args.range,
 					  lgp->args.ctx->state)) {
 		rpc_exit(task, NFS4_OK);
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0bd149b..853b544 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -740,25 +740,37 @@ pnfs_layout_stateid_blocked(const struct pnfs_layout_hdr *lo,
 	return !pnfs_seqid_is_newer(seqid, lo->plh_barrier);
 }
 
+static bool
+pnfs_layout_returning(const struct pnfs_layout_hdr *lo,
+		      struct pnfs_layout_range *range)
+{
+	return test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags) &&
+		(lo->plh_return_iomode == IOMODE_ANY ||
+		 lo->plh_return_iomode == range->iomode);
+}
+
 /* lget is set to 1 if called from inside send_layoutget call chain */
 static bool
-pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo, int lget)
+pnfs_layoutgets_blocked(const struct pnfs_layout_hdr *lo,
+			struct pnfs_layout_range *range, int lget)
 {
 	return lo->plh_block_lgets ||
 		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
-		 (atomic_read(&lo->plh_outstanding) > lget));
+		 (atomic_read(&lo->plh_outstanding) > lget)) ||
+		pnfs_layout_returning(lo, range);
 }
 
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
+			      struct pnfs_layout_range *range,
 			      struct nfs4_state *open_state)
 {
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->plh_inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo, 1)) {
+	if (pnfs_layoutgets_blocked(lo, range, 1)) {
 		status = -EAGAIN;
 	} else if (!nfs4_valid_open_stateid(open_state)) {
 		status = -EBADF;
@@ -1192,6 +1204,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
+		    !test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags) &&
 		    pnfs_lseg_range_match(&lseg->pls_range, range)) {
 			ret = pnfs_get_lseg(lseg);
 			break;
@@ -1351,7 +1364,7 @@ lookup_again:
 			goto out_unlock;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, 0))
+	if (pnfs_layoutgets_blocked(lo, &arg, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 	spin_unlock(&ino->i_lock);
@@ -1432,7 +1445,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		goto out_forget_reply;
 	}
 
-	if (pnfs_layoutgets_blocked(lo, 1)) {
+	if (pnfs_layoutgets_blocked(lo, &lgp->args.range, 1)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3ce292e..4863991 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -249,6 +249,7 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     bool update_barrier);
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
+				  struct pnfs_layout_range *range,
 				  struct nfs4_state *open_state);
 int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
-- 
1.9.3

