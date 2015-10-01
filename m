Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36195 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756209AbbJAM4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 08:56:38 -0400
Received: by qgx61 with SMTP id 61so63796114qgx.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2015 05:56:36 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: ensure that seqid morphing operations are atomic wrt to copies
Date: Thu,  1 Oct 2015 08:56:31 -0400
Message-Id: <1443704191-5984-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce points out that the increment of the seqid in stateids is not
serialized in any way, so it's possible for racing calls to bump it
twice and end up sending the same stateid. While we don't have any
reports of this problem it _is_ theoretically possible, and could lead
to spurious state recovery by the client.

In the current code, update_stateid is always followed by a memcpy of
that stateid, so we can combine the two operations. For better
atomicity, we add a spinlock to the nfs4_stid and hold that when bumping
the seqid and copying the stateid.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4layouts.c | 13 ++++---------
 fs/nfsd/nfs4state.c   | 33 ++++++++++++++++++---------------
 fs/nfsd/state.h       | 10 +---------
 3 files changed, 23 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index c6b4f0ba178a..1ee1881cf8d0 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -409,8 +409,7 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	list_add_tail(&new->lo_perstate, &ls->ls_layouts);
 	new = NULL;
 done:
-	update_stateid(&ls->ls_stid.sc_stateid);
-	memcpy(&lgp->lg_sid, &ls->ls_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&lgp->lg_sid, &ls->ls_stid);
 	spin_unlock(&ls->ls_lock);
 out:
 	spin_unlock(&fp->fi_lock);
@@ -484,11 +483,8 @@ nfsd4_return_file_layouts(struct svc_rqst *rqstp,
 		}
 	}
 	if (!list_empty(&ls->ls_layouts)) {
-		if (found) {
-			update_stateid(&ls->ls_stid.sc_stateid);
-			memcpy(&lrp->lr_sid, &ls->ls_stid.sc_stateid,
-				sizeof(stateid_t));
-		}
+		if (found)
+			nfs4_inc_and_copy_stateid(&lrp->lr_sid, &ls->ls_stid);
 		lrp->lrs_present = 1;
 	} else {
 		trace_layoutstate_unhash(&ls->ls_stid.sc_stateid);
@@ -619,8 +615,7 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
 
 	mutex_lock(&ls->ls_mutex);
-	update_stateid(&ls->ls_stid.sc_stateid);
-	memcpy(&ls->ls_recall_sid, &ls->ls_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&ls->ls_recall_sid, &ls->ls_stid);
 }
 
 static int
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 156fc9183728..87c089eafbcf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -748,6 +748,18 @@ nfs4_put_stid(struct nfs4_stid *s)
 		put_nfs4_file(fp);
 }
 
+void
+nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid)
+{
+	stateid_t *src = &stid->sc_stateid;
+
+	spin_lock(&stid->sc_lock);
+	if (unlikely(++src->si_generation == 0))
+		src->si_generation = 1;
+	memcpy(dst, src, sizeof(*dst));
+	spin_unlock(&stid->sc_lock);
+}
+
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 {
 	struct nfsd_file *nf = NULL;
@@ -4217,8 +4229,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (stp->st_clnt_odstate == open->op_odstate)
 			open->op_odstate = NULL;
 	}
-	update_stateid(&stp->st_stid.sc_stateid);
-	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&open->op_stateid, &stp->st_stid);
 	up_read(&stp->st_rwsem);
 
 	if (nfsd4_has_session(&resp->cstate)) {
@@ -4916,8 +4927,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto put_stateid;
 	}
 	oo->oo_flags |= NFS4_OO_CONFIRMED;
-	update_stateid(&stp->st_stid.sc_stateid);
-	memcpy(&oc->oc_resp_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&oc->oc_resp_stateid, &stp->st_stid);
 	up_write(&stp->st_rwsem);
 	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
 		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stid.sc_stateid));
@@ -4990,11 +5000,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		goto put_stateid;
 	}
 	nfs4_stateid_downgrade(stp, od->od_share_access);
-
 	reset_union_bmap_deny(od->od_share_deny, stp);
-
-	update_stateid(&stp->st_stid.sc_stateid);
-	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&od->od_stateid, &stp->st_stid);
 	status = nfs_ok;
 put_stateid:
 	up_write(&stp->st_rwsem);
@@ -5049,8 +5056,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	update_stateid(&stp->st_stid.sc_stateid);
-	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&close->cl_stateid, &stp->st_stid);
 	up_write(&stp->st_rwsem);
 
 	nfsd4_close_open_stateid(stp);
@@ -5533,9 +5539,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	err = vfs_lock_file(nf->nf_file, F_SETLK, file_lock, conflock);
 	switch (-err) {
 	case 0: /* success! */
-		update_stateid(&lock_stp->st_stid.sc_stateid);
-		memcpy(&lock->lk_resp_stateid, &lock_stp->st_stid.sc_stateid, 
-				sizeof(stateid_t));
+		nfs4_inc_and_copy_stateid(&lock->lk_resp_stateid, &lock_stp->st_stid);
 		status = 0;
 		break;
 	case (EAGAIN):		/* conflock holds conflicting lock */
@@ -5727,8 +5731,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
 	}
-	update_stateid(&stp->st_stid.sc_stateid);
-	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
+	nfs4_inc_and_copy_stateid(&locku->lu_stateid, &stp->st_stid);
 put_file:
 	nfsd_file_put(nf);
 put_stateid:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e3a191ea771c..732fbb3b5ef1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -365,15 +365,6 @@ struct nfs4_client_reclaim {
 	char			cr_recdir[HEXDIR_LEN]; /* recover dir */
 };
 
-static inline void
-update_stateid(stateid_t *stateid)
-{
-	stateid->si_generation++;
-	/* Wraparound recommendation from 3530bis-13 9.1.3.2: */
-	if (stateid->si_generation == 0)
-		stateid->si_generation = 1;
-}
-
 /* A reasonable value for REPLAY_ISIZE was estimated as follows:  
  * The OPEN response, typically the largest, requires 
  *   4(status) + 8(stateid) + 20(changeinfo) + 4(rflags) +  8(verifier) + 
@@ -596,6 +587,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
 		struct kmem_cache *slab);
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
+void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
 void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
 extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
-- 
2.4.3

