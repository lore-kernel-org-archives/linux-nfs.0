Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46909 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933433Ab0LUCUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 21:20:55 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/14] pnfs: wave 2: rename lo->state to lo->plh_flags
Date: Mon, 20 Dec 2010 21:20:35 -0500
Message-Id: <1292898046-7336-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Preparing for change in stateid code, and want to avoid name confusion.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   14 +++++++-------
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6e9daff..f6320e6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,7 +259,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 	list_del_init(&lo->layouts);
 	spin_unlock(&clp->cl_lock);
 	write_seqlock(&lo->seqlock);
-	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
 	write_sequnlock(&lo->seqlock);
 
 	dprintk("%s:Return\n", __func__);
@@ -331,7 +331,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 	bool overwrite = false;
 
 	write_seqlock(&lo->seqlock);
-	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags) ||
 	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
 		overwrite = true;
 	else {
@@ -360,7 +360,7 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
 		memcpy(lo->stateid.data, state->stateid.data,
 		       sizeof(state->stateid.data));
 	} while (read_seqretry(&state->seqlock, seq));
-	set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	set_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
 	write_sequnlock(&lo->seqlock);
 	dprintk("<-- %s\n", __func__);
 }
@@ -374,7 +374,7 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 	dprintk("--> %s\n", __func__);
 	do {
 		seq = read_seqbegin(&lo->seqlock);
-		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
+		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
 			/* This will trigger retry of the read */
 			pnfs_layout_from_open_stateid(lo, open_state);
 		} else
@@ -424,7 +424,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
 		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(iomode), &lo->state);
+		set_bit(lo_fail_bit(iomode), &lo->plh_flags);
 	}
 	return lseg;
 }
@@ -597,7 +597,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
 	get_layout_hdr_locked(lo); /* Matched in nfs4_layoutget_release */
@@ -606,7 +606,7 @@ pnfs_update_layout(struct inode *ino,
 	lseg = send_layoutget(lo, ctx, iomode);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout->state, lseg);
+		nfsi->layout->plh_flags, lseg);
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e12367d..5e29d31 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,7 +65,7 @@ struct pnfs_layout_hdr {
 	struct list_head	segs;      /* layout segments list */
 	seqlock_t		seqlock;   /* Protects the stateid */
 	nfs4_stateid		stateid;
-	unsigned long		state;
+	unsigned long		plh_flags;
 	struct inode		*inode;
 };
 
-- 
1.7.2.1

