Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:33163 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbaF3Pv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:59 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so6524492qaq.2
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:58 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 061/114] nfsd: clean up lockowner refcounting when finding them
Date: Mon, 30 Jun 2014 11:49:30 -0400
Message-Id: <1404143423-24381-62-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
 fs/nfsd/nfs4state.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 98cbe9b7c01e..395232b7efef 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4702,6 +4702,7 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 			continue;
 		if (!same_owner_str(so, owner, clid))
 			continue;
+		atomic_inc(&so->so_count);
 		return lockowner(so);
 	}
 	return NULL;
@@ -4732,9 +4733,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 		return NULL;
 	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
 	lo->lo_owner.so_is_open_owner = 0;
-	/* It is the openowner seqid that will be incremented in encode in the
-	 * case of new lockowners; so increment the lock seqid manually: */
-	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
+	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	lo->lo_owner.so_free = nfs4_free_lockowner;
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	return lo;
@@ -4835,8 +4834,13 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 	set_access(access, lock_stp);
 }
 
-static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
+static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
+					  struct nfs4_ol_stateid *ost,
+					  struct nfsd4_lock *lock,
+					  struct nfs4_ol_stateid **lst,
+					  bool *new)
 {
+	__be32 status;
 	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
@@ -4851,19 +4855,26 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
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
 
 	*lst = find_or_create_lock_stateid(lo, fi, ost, new);
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
@@ -4881,9 +4892,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
 	__be32 status = 0;
-	bool new_state = false;
 	int lkflg;
 	int err;
+	bool new = false;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -4926,7 +4937,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						&lock->v.new.clientid))
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
-							&lock_stp, &new_state);
+							&lock_stp, &new);
 	} else {
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
@@ -5020,12 +5031,24 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
 		put_generic_stateid(lock_stp);
+	}
 	if (open_stp)
 		put_generic_stateid(open_stp);
-	if (status && new_state)
-		release_lockowner_if_empty(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
 	if (file_lock)
@@ -5060,7 +5083,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_lockt *lockt)
 {
 	struct file_lock *file_lock = NULL;
-	struct nfs4_lockowner *lo;
+	struct nfs4_lockowner *lo = NULL;
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -5123,6 +5146,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

