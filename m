Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35244 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbcGXVbi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:38 -0400
Received: by mail-io0-f193.google.com with SMTP id q83so10786629iod.2
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 05/14] pNFS: Fix CB_LAYOUTRECALL stateid verification
Date: Sun, 24 Jul 2016 17:30:50 -0400
Message-Id: <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to evaluate in this order:

If the client holds no layout for this inode, then return
NFS4ERR_NOMATCHING_LAYOUT; it probably forgot the layout.

If the client finds the inode among the list of layouts, but the corresponding
stateid has not yet been initialised, then return NFS4ERR_DELAY to ask the
server to retry once the outstanding LAYOUTGET is complete.

If the current layout stateid's "other" field does not match the recalled
stateid, return NFS4ERR_BAD_STATEID.

If already processing a layout recall with a newer stateid, return
NFS4ERR_OLD_STATEID. This can only happens for servers that are
non-compliant with the NFSv4.1 protocol.

If already processing a layout recall with an older stateid, return
NFS4ERR_DELAY to ask the server to retry once the outstanding
LAYOUTRETURN is complete. Again, this is technically incompliant with
the NFSv4.1 protocol.

If the current layout sequence id is newer than the recalled stateid's
sequence id, return NFS4ERR_OLD_STATEID. This too implies protocol
non-compliance.

If the current layout sequence id is older than the recalled stateid's
sequence id+1, return NFS4ERR_DELAY.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 63 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 44 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index aaa2e8d3df6f..837da8a02d35 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -119,27 +119,30 @@ out:
  * hashed by filehandle.
  */
 static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
-		struct nfs_fh *fh, nfs4_stateid *stateid)
+		struct nfs_fh *fh)
 {
 	struct nfs_server *server;
+	struct nfs_inode *nfsi;
 	struct inode *ino;
 	struct pnfs_layout_hdr *lo;
 
+restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
-			if (!nfs4_stateid_match_other(&lo->plh_stateid, stateid))
+			nfsi = NFS_I(lo->plh_inode);
+			if (nfs_compare_fh(fh, &nfsi->fh))
 				continue;
-			if (nfs_compare_fh(fh, &NFS_I(lo->plh_inode)->fh))
+			if (nfsi->layout != lo)
 				continue;
 			ino = igrab(lo->plh_inode);
 			if (!ino)
 				break;
 			spin_lock(&ino->i_lock);
 			/* Is this layout in the process of being freed? */
-			if (NFS_I(ino)->layout != lo) {
+			if (nfsi->layout != lo) {
 				spin_unlock(&ino->i_lock);
 				iput(ino);
-				break;
+				goto restart;
 			}
 			pnfs_get_layout_hdr(lo);
 			spin_unlock(&ino->i_lock);
@@ -151,13 +154,13 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 }
 
 static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp,
-		struct nfs_fh *fh, nfs4_stateid *stateid)
+		struct nfs_fh *fh)
 {
 	struct pnfs_layout_hdr *lo;
 
 	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
-	lo = get_layout_by_fh_locked(clp, fh, stateid);
+	lo = get_layout_by_fh_locked(clp, fh);
 	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
 
@@ -167,17 +170,39 @@ static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp,
 /*
  * Enforce RFC5661 section 12.5.5.2.1. (Layout Recall and Return Sequencing)
  */
-static bool pnfs_check_stateid_sequence(struct pnfs_layout_hdr *lo,
+static u32 pnfs_check_callback_stateid(struct pnfs_layout_hdr *lo,
 					const nfs4_stateid *new)
 {
 	u32 oldseq, newseq;
 
-	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
+	/* Is the stateid still not initialised? */
+	if (!pnfs_layout_is_valid(lo))
+		return NFS4ERR_DELAY;
+
+	/* Mismatched stateid? */
+	if (!nfs4_stateid_match_other(&lo->plh_stateid, new))
+		return NFS4ERR_BAD_STATEID;
+
 	newseq = be32_to_cpu(new->seqid);
+	/* Are we already in a layout recall situation? */
+	if (test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags) &&
+	    lo->plh_return_seq != 0) {
+		if (newseq < lo->plh_return_seq)
+			return NFS4ERR_OLD_STATEID;
+		if (newseq > lo->plh_return_seq)
+			return NFS4ERR_DELAY;
+		goto out;
+	}
 
+	/* Check that the stateid matches what we think it should be. */
+	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	if (newseq > oldseq + 1)
-		return false;
-	return true;
+		return NFS4ERR_DELAY;
+	/* Crazy server! */
+	if (newseq <= oldseq)
+		return NFS4ERR_OLD_STATEID;
+out:
+	return NFS_OK;
 }
 
 static u32 initiate_file_draining(struct nfs_client *clp,
@@ -188,7 +213,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
 	LIST_HEAD(free_me_list);
 
-	lo = get_layout_by_fh(clp, &args->cbl_fh, &args->cbl_stateid);
+	lo = get_layout_by_fh(clp, &args->cbl_fh);
 	if (!lo) {
 		trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, NULL,
 				&args->cbl_stateid, -rv);
@@ -196,18 +221,15 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	}
 
 	ino = lo->plh_inode;
+	pnfs_layoutcommit_inode(ino, false);
+
 
 	spin_lock(&ino->i_lock);
-	if (!pnfs_check_stateid_sequence(lo, &args->cbl_stateid)) {
-		rv = NFS4ERR_DELAY;
+	rv = pnfs_check_callback_stateid(lo, &args->cbl_stateid);
+	if (rv != NFS_OK)
 		goto unlock;
-	}
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
-	spin_unlock(&ino->i_lock);
-
-	pnfs_layoutcommit_inode(ino, false);
 
-	spin_lock(&ino->i_lock);
 	/*
 	 * Enforce RFC5661 Section 12.5.5.2.1.5 (Bulk Recall and Return)
 	 */
@@ -223,6 +245,9 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto unlock;
 	}
 
+	/* Embrace your forgetfulness! */
+	rv = NFS4ERR_NOMATCHING_LAYOUT;
+
 	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
 		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
 			&args->cbl_range);
-- 
2.7.4

