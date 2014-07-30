Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:40663 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbaG3BfZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:25 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so645681qga.22
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 23/38] nfsd: clean up lockowner refcounting when finding them
Date: Tue, 29 Jul 2014 21:34:28 -0400
Message-Id: <1406684083-19736-24-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that when finding or creating a lockowner, that we get a
reference to it. For now, we also take an extra reference when a
lockowner is created that can be put when release_lockowner is called,
but we'll remove that in a later patch once we change how references are
held.

Since we no longer destroy lockowners in the event of an error in
nfsd4_lock, we must change how the seqid gets bumped in the lk_is_new
case. Instead of doing so on creation, do it manually in nfsd4_lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 45 +++++++++++++++++++++++++++++++++------------
 1 file changed, 33 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 749608b914b4..eaa5f9ebf444 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4754,6 +4754,7 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 			continue;
 		if (!same_owner_str(so, owner, clid))
 			continue;
+		atomic_inc(&so->so_count);
 		return lockowner(so);
 	}
 	return NULL;
@@ -4787,9 +4788,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 		return NULL;
 	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
 	lo->lo_owner.so_is_open_owner = 0;
-	/* It is the openowner seqid that will be incremented in encode in the
-	 * case of new lockowners; so increment the lock seqid manually: */
-	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
+	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	lo->lo_owner.so_ops = &lockowner_ops;
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	return lo;
@@ -4895,6 +4894,7 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 			    struct nfsd4_lock *lock,
 			    struct nfs4_ol_stateid **lst, bool *new)
 {
+	__be32 status;
 	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
@@ -4910,19 +4910,26 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 		if (lo == NULL)
 			return nfserr_jukebox;
+		/* FIXME: extra reference for new lockowners for the client */
+		atomic_inc(&lo->lo_owner.so_count);
 	} else {
 		/* with an existing lockowner, seqids must be the same */
+		status = nfserr_bad_seqid;
 		if (!cstate->minorversion &&
 		    lock->lk_new_lock_seqid != lo->lo_owner.so_seqid)
-			return nfserr_bad_seqid;
+			goto out;
 	}
 
 	*lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
 	if (*lst == NULL) {
 		release_lockowner_if_empty(lo);
-		return nfserr_jukebox;
+		status = nfserr_jukebox;
+		goto out;
 	}
-	return nfs_ok;
+	status = nfs_ok;
+out:
+	nfs4_put_stateowner(&lo->lo_owner);
+	return status;
 }
 
 /*
@@ -4941,9 +4948,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
 	__be32 status = 0;
-	bool new_state = false;
 	int lkflg;
 	int err;
+	bool new = false;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -4986,7 +4993,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						&lock->v.new.clientid))
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
-							&lock_stp, &new_state);
+							&lock_stp, &new);
 	} else {
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
@@ -5085,12 +5092,24 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (filp)
 		fput(filp);
-	if (lock_stp)
+	if (lock_stp) {
+		/* Bump seqid manually if the 4.0 replay owner is openowner */
+		if (cstate->replay_owner &&
+		    cstate->replay_owner != &lock_sop->lo_owner &&
+		    seqid_mutating_err(ntohl(status)))
+			lock_sop->lo_owner.so_seqid++;
+
+		/*
+		 * If this is a new, never-before-used stateid, and we are
+		 * returning an error, then just go ahead and release it.
+		 */
+		if (status && new)
+			release_lock_stateid(lock_stp);
+
 		nfs4_put_stid(&lock_stp->st_stid);
+	}
 	if (open_stp)
 		nfs4_put_stid(&open_stp->st_stid);
-	if (status && new_state)
-		release_lock_stateid(lock_stp);
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
 	if (file_lock)
@@ -5125,7 +5144,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_lockt *lockt)
 {
 	struct file_lock *file_lock = NULL;
-	struct nfs4_lockowner *lo;
+	struct nfs4_lockowner *lo = NULL;
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -5188,6 +5207,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		nfs4_set_lock_denied(file_lock, &lockt->lt_denied);
 	}
 out:
+	if (lo)
+		nfs4_put_stateowner(&lo->lo_owner);
 	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
-- 
1.9.3

