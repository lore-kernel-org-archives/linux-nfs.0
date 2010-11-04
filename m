Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab0KDPWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:53 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMU029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:43 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/18] pnfs-submit: rename lo->state to lo->plh_flags
Date: Thu,  4 Nov 2010 11:22:21 -0400
Message-Id: <1288884151-11128-9-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Preparing for change in stateid code, and want to avoid name confusion.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   18 +++++++++---------
 fs/nfs/pnfs.h |    6 +++---
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 44f4f30..a2d8d3f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -81,10 +81,10 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (has_layout(nfsi) &&
-	    !test_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->state)) {
+	    !test_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags)) {
 		nfsi->layout->cred = get_rpccred(ctx->state->owner->so_cred);
 		__set_bit(NFS_LAYOUT_NEED_LCOMMIT,
-			  &nfsi->layout->state);
+			  &nfsi->layout->plh_flags);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		dprintk("%s: Set layoutcommit\n", __func__);
@@ -457,7 +457,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 	bool overwrite = false;
 
 	assert_spin_locked(&lo->inode->i_lock);
-	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags) ||
 	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
 		overwrite = true;
 	else {
@@ -485,7 +485,7 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 {
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->inode->i_lock);
-	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
 		int seq;
 
 		do {
@@ -493,7 +493,7 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			memcpy(dst->data, open_state->stateid.data,
 			       sizeof(open_state->stateid.data));
 		} while (read_seqretry(&open_state->seqlock, seq));
-		set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+		set_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
 	} else
 		memcpy(dst->data, lo->stateid.data,
 		       sizeof(lo->stateid.data));
@@ -541,7 +541,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
 		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(range->iomode), &lo->state);
+		set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
 	}
 	return lseg;
 }
@@ -872,7 +872,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
 	get_layout_hdr_locked(lo); /* Matched in pnfs_layoutget_release */
@@ -881,7 +881,7 @@ pnfs_update_layout(struct inode *ino,
 	lseg = send_layoutget(lo, ctx, &arg);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout->state, lseg);
+		nfsi->layout->plh_flags, lseg);
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
@@ -1173,7 +1173,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	nfsi->layout->write_begin_pos = 0;
 	nfsi->layout->write_end_pos = 0;
 	nfsi->layout->cred = NULL;
-	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->state);
+	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
 	pnfs_copy_layout_stateid(&data->args.stateid, nfsi->layout);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f0232f5..96af66f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -97,7 +97,7 @@ struct pnfs_layout_hdr {
 	struct list_head	segs;      /* layout segments list */
 	int			roc_iomode;/* return on close iomode, 0=none */
 	nfs4_stateid		stateid;
-	unsigned long		state;
+	unsigned long		plh_flags;
 	struct rpc_cred		*cred;     /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
 	 * so the values can be used for layoutcommit.
@@ -225,7 +225,7 @@ static inline int lo_fail_bit(u32 iomode)
 static inline void pnfs_invalidate_layout_stateid(struct pnfs_layout_hdr *lo)
 {
 	assert_spin_locked(&lo->inode->i_lock);
-	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
 }
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
@@ -268,7 +268,7 @@ static inline bool
 layoutcommit_needed(struct nfs_inode *nfsi)
 {
 	return has_layout(nfsi) &&
-	       test_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->state);
+	       test_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
 }
 
 #else  /* CONFIG_NFS_V4_1 */
-- 
1.7.2.1

