Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755887Ab0KLItY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:24 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fF025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:10 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/22] pnfs-submit: change layout state seqlock to a spinlock
Date: Fri, 12 Nov 2010 03:48:27 -0500
Message-Id: <1289551724-18575-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This prepares for future changes, where the layout state needs
to change atomically with several other variables.  In particular,
it will need to know if lo->segs is empty.  Moreover, the
layoutstateid is not really a read-mostly structure, as it is
written on each LAYOUTGET.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    8 +++---
 fs/nfs/nfs4xdr.c       |    6 +++-
 fs/nfs/pnfs.c          |   50 ++++++++++++++++-------------------------------
 fs/nfs/pnfs.h          |    4 +--
 4 files changed, 26 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 4dabc62..74a6d6b 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -121,12 +121,11 @@ static bool
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
@@ -144,7 +143,8 @@ pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
 			if (res)
 				res = (newseqid == 1);
 		}
-	} while (read_seqretry(&lo->seqlock, seqlock));
+	}
+	spin_unlock(&lo->inode->i_lock);
 
 	return res;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 238eeb2..550e457 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1915,8 +1915,10 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
 		p = xdr_encode_hyper(p, args->range.offset);
 		p = xdr_encode_hyper(p, args->range.length);
-		pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout,
-					NULL);
+		spin_lock(&args->inode->i_lock);
+		memcpy(stateid.data, NFS_I(args->inode)->layout->stateid.data,
+		       NFS4_STATEID_SIZE);
+		spin_unlock(&args->inode->i_lock);
 		p = xdr_encode_opaque_fixed(p, &stateid.data,
 					    NFS4_STATEID_SIZE);
 		p = reserve_space(xdr, 4);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ec291d3..519055d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -437,7 +437,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 	nfs4_stateid *old = &lo->stateid;
 	bool overwrite = false;
 
-	write_seqlock(&lo->seqlock);
+	assert_spin_locked(&lo->inode->i_lock);
 	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
 	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
 		overwrite = true;
@@ -451,43 +451,27 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
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
 
@@ -761,7 +745,6 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo->refcount = 1;
 	INIT_LIST_HEAD(&lo->layouts);
 	INIT_LIST_HEAD(&lo->segs);
-	seqlock_init(&lo->seqlock);
 	lo->inode = ino;
 	return lo;
 }
@@ -1182,7 +1165,8 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	nfsi->layout->write_end_pos = 0;
 	nfsi->layout->cred = NULL;
 	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->state);
-	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout, NULL);
+	memcpy(data->args.stateid.data, nfsi->layout->stateid.data,
+	       NFS4_STATEID_SIZE);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
 	get_layout_hdr_locked(NFS_I(inode)->layout);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7e06437..fdcfb9b 100644
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
@@ -223,9 +222,8 @@ static inline int lo_fail_bit(u32 iomode)
 
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

