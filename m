Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51925 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933486Ab0LUCVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 21:21:02 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/14] pnfs: wave 2: add CB_LAYOUTRECALL handling
Date: Mon, 20 Dec 2010 21:20:44 -0500
Message-Id: <1292898046-7336-13-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is the heart of the wave 2 submission.  Add the code to trigger
drain and forget of any afected layouts.  In addition, we set a
"barrier", below which any LAYOUTGET reply is ignored.  This is to
compensate for the fact that we do not wait for outstanding LAYOUTGETs
to complete as per section 12.5.5.2.1 of RFC 5661.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h       |    1 +
 fs/nfs/pnfs.c          |   84 +++++++++++++++++++++++++++--------
 fs/nfs/pnfs.h          |   12 +++++
 4 files changed, 193 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c1bb157..7fb59d9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -12,6 +12,7 @@
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -107,10 +108,123 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
+static int initiate_layout_draining(struct nfs_client *clp,
+				    struct cb_layoutrecallargs *args)
+{
+	struct pnfs_layout_hdr *lo;
+	int rv = NFS4ERR_NOMATCHING_LAYOUT;
+
+	if (args->cbl_recall_type == RETURN_FILE) {
+		LIST_HEAD(free_me_list);
+
+		args->cbl_inode = NULL;
+		spin_lock(&clp->cl_lock);
+		list_for_each_entry(lo, &clp->cl_layouts, layouts) {
+			if (nfs_compare_fh(&args->cbl_fh,
+					   &NFS_I(lo->inode)->fh))
+				continue;
+			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+				rv = NFS4ERR_DELAY;
+			else {
+				/* Without this, layout can be freed as soon
+				 * as we release cl_lock.  Matched in
+				 * do_callback_layoutrecall.
+				 */
+				get_layout_hdr(lo);
+				args->cbl_inode = lo->inode;
+				rv = NFS4_OK;
+			}
+			break;
+		}
+		spin_unlock(&clp->cl_lock);
+
+		spin_lock(&lo->inode->i_lock);
+		if (rv == NFS4_OK) {
+			lo->plh_block_lgets++;
+			mark_matching_lsegs_invalid(lo, &free_me_list,
+						    args->cbl_range.iomode);
+		}
+		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+		spin_unlock(&lo->inode->i_lock);
+		pnfs_free_lseg_list(&free_me_list);
+	} else {
+		struct pnfs_layout_hdr *tmp;
+		LIST_HEAD(recall_list);
+		LIST_HEAD(free_me_list);
+		struct pnfs_layout_range range = {
+			.iomode = IOMODE_ANY,
+			.offset = 0,
+			.length = NFS4_MAX_UINT64,
+		};
+
+		spin_lock(&clp->cl_lock);
+		list_for_each_entry(lo, &clp->cl_layouts, layouts) {
+			if ((args->cbl_recall_type == RETURN_FSID) &&
+			    memcmp(&NFS_SERVER(lo->inode)->fsid,
+				   &args->cbl_fsid, sizeof(struct nfs_fsid)))
+				continue;
+			get_layout_hdr(lo);
+			BUG_ON(!list_empty(&lo->plh_bulk_recall));
+			list_add(&lo->plh_bulk_recall, &recall_list);
+		}
+		spin_unlock(&clp->cl_lock);
+		list_for_each_entry_safe(lo, tmp,
+					 &recall_list, plh_bulk_recall) {
+			spin_lock(&lo->inode->i_lock);
+			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
+			mark_matching_lsegs_invalid(lo, &free_me_list, range.iomode);
+			list_del_init(&lo->plh_bulk_recall);
+			spin_unlock(&lo->inode->i_lock);
+			put_layout_hdr(lo);
+			rv = NFS4_OK;
+		}
+		pnfs_free_lseg_list(&free_me_list);
+	}
+	return rv;
+}
+
+static u32 do_callback_layoutrecall(struct nfs_client *clp,
+				    struct cb_layoutrecallargs *args)
+{
+	u32 status, res = NFS4ERR_DELAY;
+
+	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
+	if (test_and_set_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state))
+		goto out;
+	status = initiate_layout_draining(clp, args);
+	if (status)
+		res = status;
+	else if (args->cbl_recall_type == RETURN_FILE) {
+		struct pnfs_layout_hdr *lo;
+
+		lo = NFS_I(args->cbl_inode)->layout;
+		spin_lock(&lo->inode->i_lock);
+		lo->plh_block_lgets--;
+		spin_unlock(&lo->inode->i_lock);
+		put_layout_hdr(lo);
+		res = NFS4ERR_DELAY;
+	}
+	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
+out:
+	dprintk("%s returning %i\n", __func__, res);
+	return res;
+
+}
+
 __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 				  void *dummy, struct cb_process_state *cps)
 {
-	return cpu_to_be32(NFS4ERR_NOTSUPP); /* STUB */
+	u32 res;
+
+	dprintk("%s: -->\n", __func__);
+
+	if (cps->clp)
+		res = do_callback_layoutrecall(cps->clp, args);
+	else
+		res = NFS4ERR_OP_NOT_IN_SESSION;
+
+	dprintk("%s: exit with status = %d\n", __func__, res);
+	return cpu_to_be32(res);
 }
 
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9fa4963..426e887 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -44,6 +44,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
+	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 };
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f49d288..531d98c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -178,7 +178,7 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
  */
 
 /* Need to hold i_lock if caller does not already hold reference */
-static void
+void
 get_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	atomic_inc(&lo->plh_refcount);
@@ -256,6 +256,7 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 			/* List does not take a reference, so no need for put here */
 			list_del_init(&lseg->layout->layouts);
 			spin_unlock(&clp->cl_lock);
+			clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->layout->plh_flags);
 		}
 		list_add(&lseg->fi_list, tmp_list);
 	}
@@ -281,7 +282,7 @@ static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 }
 
 /* Returns false if no lsegs match, true otherwise */
-static bool
+bool
 mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			    struct list_head *tmp_list,
 			    u32 iomode)
@@ -304,7 +305,7 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	return rv;
 }
 
-static void
+void
 pnfs_free_lseg_list(struct list_head *free_me)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
@@ -356,23 +357,46 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 }
 
 /* update lo->stateid with new if is more recent */
-static void
-pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
-			const nfs4_stateid *new)
+void
+pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
+			bool update_barrier)
 {
 	u32 oldseq, newseq;
 
 	oldseq = be32_to_cpu(lo->stateid.stateid.seqid);
 	newseq = be32_to_cpu(new->stateid.seqid);
-	if ((int)(newseq - oldseq) > 0)
+	if ((int)(newseq - oldseq) > 0) {
 		memcpy(&lo->stateid, &new->stateid, sizeof(new->stateid));
+		if (update_barrier) {
+			u32 new_barrier = be32_to_cpu(new->stateid.seqid);
+
+			if ((int)(new_barrier - lo->plh_barrier))
+				lo->plh_barrier = new_barrier;
+		} else {
+			/* Because of wraparound, we want to keep the barrier
+			 * "close" to the current seqids.  It needs to be
+			 * within 2**31 to count as "behind", so if it
+			 * gets too near that limit, give us a litle leeway
+			 * and bring it to within 2**30.
+			 * NOTE - and yes, this is all unsigned arithmetic.
+			 */
+			if (unlikely((newseq - lo->plh_barrier) > (3 << 29)))
+				lo->plh_barrier = newseq - (1 << 30);
+		}
+	}
 }
 
 /* lget is set to 1 if called from inside send_layoutget call chain */
 static bool
-pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, int lget)
-{
-	return (list_empty(&lo->segs) &&
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
+			int lget)
+{
+	if ((stateid) &&
+	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
+		return true;
+	return lo->plh_block_lgets ||
+		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+		(list_empty(&lo->segs) &&
 		 (atomic_read(&lo->plh_outstanding) > lget));
 }
 
@@ -384,7 +408,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo, 1)) {
+	if (pnfs_layoutgets_blocked(lo, NULL, 1)) {
 		/* We avoid -EAGAIN, as that has special meaning to
 		 * some callers.
 		 */
@@ -506,6 +530,7 @@ alloc_init_layout_hdr(struct inode *ino)
 	atomic_set(&lo->plh_refcount, 1);
 	INIT_LIST_HEAD(&lo->layouts);
 	INIT_LIST_HEAD(&lo->segs);
+	INIT_LIST_HEAD(&lo->plh_bulk_recall);
 	lo->inode = ino;
 	return lo;
 }
@@ -557,7 +582,7 @@ is_matching_lseg(struct pnfs_layout_segment *lseg, u32 iomode)
  * lookup range in layout
  */
 static struct pnfs_layout_segment *
-pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
+pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
 
@@ -602,19 +627,22 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	}
 
-	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_has_layout(lo, iomode);
-	if (lseg) {
-		dprintk("%s: Using cached lseg %p for iomode %d)\n",
-			__func__, lseg, iomode);
+	/* Do we even need to bother with this? */
+	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+		dprintk("%s matches recall, use MDS\n", __func__);
 		goto out_unlock;
 	}
+	/* Check to see if the layout for the given range already exists */
+	lseg = pnfs_find_lseg(lo, iomode);
+	if (lseg)
+		goto out_unlock;
 
 	/* if LAYOUTGET already failed once we don't try again */
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
-	if (pnfs_layoutgets_blocked(lo, 0))
+	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
@@ -637,6 +665,7 @@ pnfs_update_layout(struct inode *ino,
 			spin_lock(&clp->cl_lock);
 			list_del_init(&lo->layouts);
 			spin_unlock(&clp->cl_lock);
+			clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 		}
 		spin_unlock(&ino->i_lock);
 	}
@@ -658,6 +687,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct nfs4_layoutget_res *res = &lgp->res;
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = lo->inode;
+	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	int status = 0;
 
 	/* Verify we got what we asked for.
@@ -684,16 +714,32 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 
 	spin_lock(&ino->i_lock);
+	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+		dprintk("%s forget reply due to recall\n", __func__);
+		goto out_forget_reply;
+	}
+
+	if (pnfs_layoutgets_blocked(lo, &res->stateid, 1)) {
+		dprintk("%s forget reply due to state\n", __func__);
+		goto out_forget_reply;
+	}
 	init_lseg(lo, lseg);
 	lseg->range = res->range;
 	*lgp->lsegpp = lseg;
 	pnfs_insert_layout(lo, lseg);
 
 	/* Done processing layoutget. Set the layout stateid */
-	pnfs_set_layout_stateid(lo, &res->stateid);
+	pnfs_set_layout_stateid(lo, &res->stateid, false);
 	spin_unlock(&ino->i_lock);
 out:
 	return status;
+
+out_forget_reply:
+	spin_unlock(&ino->i_lock);
+	lseg->layout = lo;
+	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+	goto out;
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3cf6856..4c66a97 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -49,6 +49,7 @@ struct pnfs_layout_segment {
 enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
+	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
@@ -67,9 +68,12 @@ struct pnfs_layoutdriver_type {
 struct pnfs_layout_hdr {
 	atomic_t		plh_refcount;
 	struct list_head	layouts;   /* other client layouts */
+	struct list_head	plh_bulk_recall; /* clnt list of bulk recalls */
 	struct list_head	segs;      /* layout segments list */
 	nfs4_stateid		stateid;
 	atomic_t		plh_outstanding; /* number of RPCs out */
+	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
+	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
 	struct inode		*inode;
 };
@@ -139,18 +143,26 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 
 /* pnfs.c */
+void get_layout_hdr(struct pnfs_layout_hdr *lo);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
+void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout_hdr(struct pnfs_layout_hdr *lo);
+void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
+			     const nfs4_stateid *new,
+			     bool update_barrier);
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
+bool mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
+				 struct list_head *tmp_list,
+				 u32 iomode);
 
 
 static inline int lo_fail_bit(u32 iomode)
-- 
1.7.2.1

