Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34912 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFZTO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:57 -0400
Received: by mail-qg0-f45.google.com with SMTP id 63so3470772qgz.32
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 052/117] nfsd: Add reference counting to lock stateids
Date: Thu, 26 Jun 2014 15:12:32 -0400
Message-Id: <1403810017-16062-53-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_lock() references the lock stateid while it is
manipulating it. Not currently necessary, but will be once the
client_mutex is removed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 42fea991ae0b..29b31a6d749b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4704,6 +4704,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 
 	lockdep_assert_held(&clp->cl_lock);
 
+	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4728,8 +4729,10 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	lockdep_assert_held(&clp->cl_lock);
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
-		if (lst->st_stid.sc_file == fp)
+		if (lst->st_stid.sc_file == fp) {
+			atomic_inc(&lst->st_stid.sc_count);
 			return lst;
+		}
 	}
 	return NULL;
 }
@@ -4824,7 +4827,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
-	struct nfs4_ol_stateid *lock_stp;
+	struct nfs4_ol_stateid *lock_stp = NULL;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
@@ -4878,11 +4881,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
 							&lock_stp, &new_state);
-	} else
+	} else {
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
 				       NFS4_LOCK_STID, &lock_stp, nn);
+		/* FIXME: move into nfs4_preprocess_seqid_op */
+		if (!status)
+			atomic_inc(&lock_stp->st_stid.sc_count);
+	}
 	if (status)
 		goto out;
 	lock_sop = lockowner(lock_stp->st_stateowner);
@@ -4975,6 +4982,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (filp)
 		fput(filp);
+	if (lock_stp)
+		put_generic_stateid(lock_stp);
 	if (status && new_state)
 		release_lockowner_if_empty(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
-- 
1.9.3

