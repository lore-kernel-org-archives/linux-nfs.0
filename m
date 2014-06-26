Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:64903 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbaFZTOI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:08 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so3195639qab.3
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 016/117] nfsd: Allow lockowners to hold several stateids
Date: Thu, 26 Jun 2014 15:11:56 -0400
Message-Id: <1403810017-16062-17-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A lockowner can have more than one lock stateid. For instance, if a
process has more than one file open and has locks on both, then the same
lockowner has more than one stateid associated with it. Change it so
that this reality is better reflected by the objects that nfsd uses.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 55 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 33 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2d7887a752db..5b903761ba73 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3913,12 +3913,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 
 	if (check_for_locks(stp->st_file, lo))
 		return nfserr_locks_held;
-	/*
-	 * Currently there's a 1-1 lock stateid<->lockowner
-	 * correspondance, and we have to delete the lockowner when we
-	 * delete the lock stateid:
-	 */
-	release_lockowner(lo);
+	release_lockowner_if_empty(lo);
 	return nfs_ok;
 }
 
@@ -4442,6 +4437,19 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	return stp;
 }
 
+static struct nfs4_ol_stateid *
+find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
+{
+	struct nfs4_ol_stateid *lst;
+
+	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
+		if (lst->st_file == fp)
+			return lst;
+	}
+	return NULL;
+}
+
+
 static int
 check_lock_length(u64 offset, u64 length)
 {
@@ -4471,25 +4479,28 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 
 	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid,
 				&lock->v.new.owner, nn);
-	if (lo) {
-		if (!cstate->minorversion)
+	if (!lo) {
+		strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
+				&lock->v.new.owner);
+		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
+		if (lo == NULL)
+			return nfserr_jukebox;
+	} else {
+		/* with an existing lockowner, seqids must be the same */
+		if (!cstate->minorversion &&
+		    lock->lk_new_lock_seqid != lo->lo_owner.so_seqid)
 			return nfserr_bad_seqid;
-		/* XXX: a lockowner always has exactly one stateid: */
-		*lst = list_first_entry(&lo->lo_owner.so_stateids,
-				struct nfs4_ol_stateid, st_perstateowner);
-		return nfs_ok;
 	}
-	strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
-			&lock->v.new.owner);
-	lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
-	if (lo == NULL)
-		return nfserr_jukebox;
-	*lst = alloc_init_lock_stateid(lo, fi, ost);
+
+	*lst = find_lock_stateid(lo, fi);
 	if (*lst == NULL) {
-		release_lockowner(lo);
-		return nfserr_jukebox;
+		*lst = alloc_init_lock_stateid(lo, fi, ost);
+		if (*lst == NULL) {
+			release_lockowner_if_empty(lo);
+			return nfserr_jukebox;
+		}
+		*new = true;
 	}
-	*new = true;
 	return nfs_ok;
 }
 
@@ -4646,7 +4657,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 out:
 	if (status && new_state)
-		release_lockowner(lock_sop);
+		release_lockowner_if_empty(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
-- 
1.9.3

