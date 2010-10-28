Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29210 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758406Ab0J1TKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 15:10:08 -0400
Received: from localhost.localdomain (elee16240.hq.netapp.com [10.58.53.47] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o9SJA27g000482
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 12:10:06 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] pnfs-submit: change layout state seqlock to a spinlock
Date: Thu, 28 Oct 2010 15:09:59 -0400
Message-Id: <1288293001-26289-4-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
References: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This prepares for future changes, where the layout state needs
to change atomically with several other variables.  In particular,
it will need to know if lo->segs is empty.  One possible future
alternative is to have a statelock that also covers lo->segs, but
this method is less intrusive.  Moreover, the layoutstateid is not really
a read-mostly structure, as it is written on each LAYOUTGET.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    8 +++---
 fs/nfs/nfs4proc.c      |    2 +
 fs/nfs/nfs4xdr.c       |    2 +
 fs/nfs/pnfs.c          |   57 +++++++++++++++--------------------------------
 fs/nfs/pnfs.h          |    6 ++--
 5 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 84c5a1b..3e022a8 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -135,12 +135,11 @@ static bool
 pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
 			    const nfs4_stateid stateid)
 {
-	int seqlock;
 	bool res;
 	u32 oldseqid, newseqid;
 
-	do {
-		seqlock = read_seqbegin(&lo->seqlock);
+	spin_lock(&lo->inode->i_lock);
+	{
 		oldseqid = be32_to_cpu(lo->stateid.stateid.seqid);
 		newseqid = be32_to_cpu(stateid.stateid.seqid);
 		res = !memcmp(lo->stateid.stateid.other,
@@ -158,7 +157,8 @@ pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
 			if (res)
 				res = (newseqid == 1);
 		}
-	} while (read_seqretry(&lo->seqlock, seqlock));
+	}
+	spin_unlock(&lo->inode->i_lock);
 
 	return res;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c854814..4705ea6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5675,8 +5675,10 @@ static void nfs4_layoutreturn_release(void *calldata)
 		lrp->args.return_type, lo);
 
 	if (lrp->args.return_type == RETURN_FILE) {
+		spin_lock(&lo->inode->i_lock);
 		if (!lrp->res.lrs_present)
 			pnfs_invalidate_layout_stateid(lo);
+		spin_unlock(&lo->inode->i_lock);
 		pnfs_layoutreturn_release(lo, &lrp->args.range);
 	}
 	kfree(calldata);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c178946..b146b48 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1904,7 +1904,9 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
 		p = xdr_encode_hyper(p, args->range.offset);
 		p = xdr_encode_hyper(p, args->range.length);
+		spin_lock(&args->inode->i_lock);
 		pnfs_copy_layout_stateid(&stateid, NFS_I(args->inode)->layout);
+		spin_unlock(&args->inode->i_lock);
 		p = xdr_encode_opaque_fixed(p, &stateid.data,
 					    NFS4_STATEID_SIZE);
 		p = reserve_space(xdr, 4);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c088cd4..7a6b24c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -480,14 +480,14 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
  *
  * lo->stateid could be the open stateid, in which case we just use what given.
  */
-static void
+void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			const nfs4_stateid *new)
 {
 	nfs4_stateid *old = &lo->stateid;
 	bool overwrite = false;
 
-	write_seqlock(&lo->seqlock);
+	assert_spin_locked(&lo->inode->i_lock);
 	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
 	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
 		overwrite = true;
@@ -501,54 +501,34 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 	}
 	if (overwrite)
 		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
-	write_sequnlock(&lo->seqlock);
-}
-
-static void
-pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
-			      struct nfs4_state *state)
-{
-	int seq;
-
-	dprintk("--> %s\n", __func__);
-	write_seqlock(&lo->seqlock);
-	do {
-		seq = read_seqbegin(&state->seqlock);
-		memcpy(lo->stateid.data, state->stateid.data,
-		       sizeof(state->stateid.data));
-	} while (read_seqretry(&state->seqlock, seq));
-	set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
-	write_sequnlock(&lo->seqlock);
-	dprintk("<-- %s\n", __func__);
 }
 
 /* Layoutreturn may use an invalid stateid, just copy what is there */
 void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo)
 {
-	int seq;
-
-	do {
-		seq = read_seqbegin(&lo->seqlock);
-		memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
-	} while (read_seqretry(&lo->seqlock, seq));
+	assert_spin_locked(&lo->inode->i_lock);
+	memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
 }
 
 void
 pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			struct nfs4_state *open_state)
 {
-	int seq;
-
 	dprintk("--> %s\n", __func__);
-	do {
-		seq = read_seqbegin(&lo->seqlock);
-		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
-			/* This will trigger retry of the read */
-			pnfs_layout_from_open_stateid(lo, open_state);
-		} else
-			memcpy(dst->data, lo->stateid.data,
-			       sizeof(lo->stateid.data));
-	} while (read_seqretry(&lo->seqlock, seq));
+	spin_lock(&lo->inode->i_lock);
+	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
+		int seq;
+
+		do {
+			seq = read_seqbegin(&open_state->seqlock);
+			memcpy(dst->data, open_state->stateid.data,
+			       sizeof(open_state->stateid.data));
+		} while (read_seqretry(&open_state->seqlock, seq));
+		set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
+	} else
+		memcpy(dst->data, lo->stateid.data,
+		       sizeof(lo->stateid.data));
+	spin_unlock(&lo->inode->i_lock);
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -807,7 +787,6 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo->refcount = 1;
 	INIT_LIST_HEAD(&lo->layouts);
 	INIT_LIST_HEAD(&lo->segs);
-	seqlock_init(&lo->seqlock);
 	lo->inode = ino;
 	return lo;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c06b510..6e73fbe 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -96,7 +96,6 @@ struct pnfs_layout_hdr {
 	struct list_head	layouts;   /* other client layouts */
 	struct list_head	segs;      /* layout segments list */
 	int			roc_iomode;/* return on close iomode, 0=none */
-	seqlock_t		seqlock;   /* Protects the stateid */
 	nfs4_stateid		stateid;
 	unsigned long		state;
 	struct rpc_cred		*cred;     /* layoutcommit credential */
@@ -208,6 +207,8 @@ void pnfs_layoutreturn_release(struct pnfs_layout_hdr *,
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout_hdr(struct inode *inode);
+void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
+			     const nfs4_stateid *new);
 void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo);
 void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			     struct nfs4_state *open_state);
@@ -227,9 +228,8 @@ static inline int lo_fail_bit(u32 iomode)
 
 static inline void pnfs_invalidate_layout_stateid(struct pnfs_layout_hdr *lo)
 {
-	write_seqlock(&lo->seqlock);
+	assert_spin_locked(&lo->inode->i_lock);
 	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
-	write_sequnlock(&lo->seqlock);
 }
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
-- 
1.7.2.1

