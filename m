Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54888 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab1KDV2T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 17:28:19 -0400
Date: Fri, 4 Nov 2011 17:28:18 -0400
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: fix handling of multiple open_to_lockowner locks.
Message-ID: <20111104212818.GG721@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After the following patches we only maintain one lock stateid at a time
per (lockowner, file).

--b.

commit def4962ffbbc6ad94360d6e95d234aaec0197d2b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Oct 20 06:57:46 2011 -0400

    nfsd4: maintain one seqid stream per (lockowner, file)
    
    Instead of creating a new lockowner and stateid for every
    open_to_lockowner call, reuse the existing lockowner if it exists.
    
    Reported-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 49e85b6..850294c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3892,6 +3892,37 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 	__set_bit(access, &lock_stp->st_access_bmap);
 }
 
+__be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
+{
+	struct nfs4_file *fi = ost->st_file;
+	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
+	struct nfs4_client *cl = oo->oo_owner.so_client;
+	struct nfs4_lockowner *lo;
+	unsigned int strhashval;
+
+	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid, &lock->v.new.owner);
+	if (lo) {
+		if (!cstate->minorversion)
+			return nfserr_bad_seqid;
+		/* XXX: a lockowner always has exactly one stateid: */
+		*lst = list_first_entry(&lo->lo_owner.so_stateids,
+				struct nfs4_ol_stateid, st_perstateowner);
+		return nfs_ok;
+	}
+	strhashval = lock_ownerstr_hashval(fi->fi_inode, cl->cl_clientid.cl_id,
+			&lock->v.new.owner);
+	lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
+	if (lo == NULL)
+		return nfserr_jukebox;
+	*lst = alloc_init_lock_stateid(lo, fi, ost);
+	if (*lst == NULL) {
+		release_lockowner(lo);
+		return nfserr_jukebox;
+	}
+	*new = true;
+	return nfs_ok;
+}
+
 /*
  *  LOCK operation 
  */
@@ -3907,7 +3938,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock file_lock;
 	struct file_lock conflock;
 	__be32 status = 0;
-	unsigned int strhashval;
+	bool new_state = false;
 	int lkflg;
 	int err;
 
@@ -3956,21 +3987,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
 						&lock->v.new.clientid))
 			goto out;
-		/* create lockowner and lock stateid */
-		fp = open_stp->st_file;
-		strhashval = lock_ownerstr_hashval(fp->fi_inode,
-				open_sop->oo_owner.so_client->cl_clientid.cl_id,
-				&lock->v.new.owner);
-		/* XXX: Do we need to check for duplicate stateowners on
-		 * the same file, or should they just be allowed (and
-		 * create new stateids)? */
-		status = nfserr_jukebox;
-		lock_sop = alloc_init_lock_stateowner(strhashval,
-				open_sop->oo_owner.so_client, open_stp, lock);
-		if (lock_sop == NULL)
-			goto out;
-		lock_stp = alloc_init_lock_stateid(lock_sop, fp, open_stp);
-		if (lock_stp == NULL)
+		status = lookup_or_create_lock_state(cstate, open_stp, lock,
+							&lock_stp, &new_state);
+		if (status)
 			goto out;
 	} else {
 		/* lock (lock owner + lock stateid) already exists */
@@ -3980,10 +3999,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				       NFS4_LOCK_STID, &lock_stp);
 		if (status)
 			goto out;
-		lock_sop = lockowner(lock_stp->st_stateowner);
-		fp = lock_stp->st_file;
 	}
-	/* lock_sop and lock_stp have been created or found */
+	lock_sop = lockowner(lock_stp->st_stateowner);
+	fp = lock_stp->st_file;
 
 	lkflg = setlkflg(lock->lk_type);
 	status = nfs4_check_openmode(lock_stp, lkflg);
@@ -4058,7 +4076,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		break;
 	}
 out:
-	if (status && lock->lk_is_new && lock_sop)
+	if (status && new_state)
 		release_lockowner(lock_sop);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();

commit c22fc496a7699bce5186677443d852526a7073a7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Nov 4 17:08:10 2011 -0400

    nfsd4: cleanup lock clientid handling in sessions case
    
    I'd rather the "ignore clientid in sessions case" rule be enforced in
    just one place.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 47e94e3..49e85b6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3933,10 +3933,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * lock stateid.
 		 */
 		struct nfs4_ol_stateid *open_stp = NULL;
-		
+
+		if (nfsd4_has_session(cstate))
+			/* See rfc 5661 18.10.3: given clientid is ignored: */
+			memcpy(&lock->v.new.clientid,
+				&cstate->session->se_client->cl_clientid,
+				sizeof(clientid_t));
+
 		status = nfserr_stale_clientid;
-		if (!nfsd4_has_session(cstate) &&
-		    STALE_CLIENTID(&lock->lk_new_clientid))
+		if (STALE_CLIENTID(&lock->lk_new_clientid))
 			goto out;
 
 		/* validate and update open stateid and open seqid */
@@ -3948,8 +3953,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		open_sop = openowner(open_stp->st_stateowner);
 		status = nfserr_bad_stateid;
-		if (!nfsd4_has_session(cstate) &&
-			!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
+		if (!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
 						&lock->v.new.clientid))
 			goto out;
 		/* create lockowner and lock stateid */
