Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab0LWRaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 12:30:24 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/15] pnfs: change layout state seqlock to a spinlock
Date: Thu, 23 Dec 2010 12:29:47 -0500
Message-Id: <1293125397-30088-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
References: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This prepares for future changes, where the layout state needs
to change atomically with several other variables.  In particular,
it will need to know if lo->segs is empty, as we test that instead
of manipulating the NFS_LAYOUT_STATEID_SET bit.  Moreover, the
layoutstateid is not really a read-mostly structure, as it is
written almost as often as it is read.

The behavior of pnfs_get_layout_stateid is also slightly changed, so that
it no longer changes the stateid.  Its name is changed to +pnfs_choose_layoutget_stateid.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 fs/nfs/pnfs.c    |   79 +++++++++++++++--------------------------------------
 fs/nfs/pnfs.h    |    7 ++---
 3 files changed, 27 insertions(+), 61 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f3f9915..4e28242 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1798,7 +1798,7 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->range.offset);
 	p = xdr_encode_hyper(p, args->range.length);
 	p = xdr_encode_hyper(p, args->minlength);
-	pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout,
+	pnfs_choose_layoutget_stateid(&stateid, NFS_I(args->inode)->layout,
 				args->ctx->state);
 	p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(args->maxcount);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6736f9e..08313f53 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -258,9 +258,6 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 	/* List does not take a reference, so no need for put here */
 	list_del_init(&lo->plh_layouts);
 	spin_unlock(&clp->cl_lock);
-	write_seqlock(&lo->plh_seqlock);
-	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
-	write_sequnlock(&lo->plh_seqlock);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -319,69 +316,40 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	}
 }
 
-/* update lo->plh_stateid with new if is more recent
- *
- * lo->plh_stateid could be the open stateid, in which case we just use what given.
- */
+/* update lo->plh_stateid with new if is more recent */
 static void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			const nfs4_stateid *new)
 {
-	nfs4_stateid *old = &lo->plh_stateid;
-	bool overwrite = false;
-
-	write_seqlock(&lo->plh_seqlock);
-	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags) ||
-	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
-		overwrite = true;
-	else {
-		u32 oldseq, newseq;
-
-		oldseq = be32_to_cpu(old->stateid.seqid);
-		newseq = be32_to_cpu(new->stateid.seqid);
-		if ((int)(newseq - oldseq) > 0)
-			overwrite = true;
-	}
-	if (overwrite)
-		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
-	write_sequnlock(&lo->plh_seqlock);
-}
-
-static void
-pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
-			      struct nfs4_state *state)
-{
-	int seq;
+	u32 oldseq, newseq;
 
-	dprintk("--> %s\n", __func__);
-	write_seqlock(&lo->plh_seqlock);
-	do {
-		seq = read_seqbegin(&state->seqlock);
-		memcpy(lo->plh_stateid.data, state->stateid.data,
-		       sizeof(state->stateid.data));
-	} while (read_seqretry(&state->seqlock, seq));
-	set_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags);
-	write_sequnlock(&lo->plh_seqlock);
-	dprintk("<-- %s\n", __func__);
+	oldseq = be32_to_cpu(lo->plh_stateid.stateid.seqid);
+	newseq = be32_to_cpu(new->stateid.seqid);
+	if ((int)(newseq - oldseq) > 0)
+		memcpy(&lo->plh_stateid, &new->stateid, sizeof(new->stateid));
 }
 
-void
-pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
-			struct nfs4_state *open_state)
+int
+pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
+			      struct nfs4_state *open_state)
 {
-	int seq;
+	int status = 0;
 
 	dprintk("--> %s\n", __func__);
-	do {
-		seq = read_seqbegin(&lo->plh_seqlock);
-		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->plh_flags)) {
-			/* This will trigger retry of the read */
-			pnfs_layout_from_open_stateid(lo, open_state);
-		} else
-			memcpy(dst->data, lo->plh_stateid.data,
-			       sizeof(lo->plh_stateid.data));
-	} while (read_seqretry(&lo->plh_seqlock, seq));
+	spin_lock(&lo->plh_inode->i_lock);
+	if (list_empty(&lo->plh_segs)) {
+		int seq;
+
+		do {
+			seq = read_seqbegin(&open_state->seqlock);
+			memcpy(dst->data, open_state->stateid.data,
+			       sizeof(open_state->stateid.data));
+		} while (read_seqretry(&open_state->seqlock, seq));
+	} else
+		memcpy(dst->data, lo->plh_stateid.data, sizeof(lo->plh_stateid.data));
+	spin_unlock(&lo->plh_inode->i_lock);
 	dprintk("<-- %s\n", __func__);
+	return status;
 }
 
 /*
@@ -496,7 +464,6 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo->plh_refcount = 1;
 	INIT_LIST_HEAD(&lo->plh_layouts);
 	INIT_LIST_HEAD(&lo->plh_segs);
-	seqlock_init(&lo->plh_seqlock);
 	lo->plh_inode = ino;
 	return lo;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c2f1086..1093720 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -44,7 +44,6 @@ struct pnfs_layout_segment {
 enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
-	NFS_LAYOUT_STATEID_SET,		/* have a valid layout stateid */
 };
 
 /* Per-layout driver specific registration structure */
@@ -63,7 +62,6 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_refcount;
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_segs;      /* layout segments list */
-	seqlock_t		plh_seqlock;   /* Protects the stateid */
 	nfs4_stateid		plh_stateid;
 	unsigned long		plh_flags;
 	struct inode		*plh_inode;
@@ -143,8 +141,9 @@ int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout_hdr(struct inode *inode);
-void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
-			     struct nfs4_state *open_state);
+int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
+				  struct pnfs_layout_hdr *lo,
+				  struct nfs4_state *open_state);
 
 
 static inline int lo_fail_bit(u32 iomode)
-- 
1.7.2.1

