Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:37290 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbaFZTOZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:25 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so3548281qcv.33
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 028/117] nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
Date: Thu, 26 Jun 2014 15:12:08 -0400
Message-Id: <1403810017-16062-29-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Access to this list is currently serialized by the client_mutex. Add
finer grained locking around this list in preparation for its removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a2b4f2cbab42..8793d9ec8311 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -719,7 +719,11 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	struct nfs4_file *fp = stp->st_file;
+
+	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
+	spin_unlock(&fp->fi_lock);
 	list_del(&stp->st_perstateowner);
 }
 
@@ -2812,7 +2816,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
@@ -2821,6 +2824,9 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	set_access(open->op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
 	stp->st_openstp = NULL;
+	spin_lock(&fp->fi_lock);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
+	spin_unlock(&fp->fi_lock);
 }
 
 static void
@@ -2928,6 +2934,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 		return nfs_ok;
 	ret = nfserr_locked;
 	/* Search for conflicting share reservations */
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
 		if (test_deny(deny_type, stp) ||
 		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
@@ -2935,6 +2942,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	}
 	ret = nfs_ok;
 out:
+	spin_unlock(&fp->fi_lock);
 	put_nfs4_file(fp);
 	return ret;
 }
@@ -3134,6 +3142,7 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 	struct nfs4_ol_stateid *local;
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
@@ -3142,9 +3151,12 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 		if (local->st_stateowner == &oo->oo_owner)
 			*stpp = local;
 		/* check for conflicting share reservations */
-		if (!test_share(local, open))
+		if (!test_share(local, open)) {
+			spin_unlock(&fp->fi_lock);
 			return nfserr_share_denied;
+		}
 	}
+	spin_unlock(&fp->fi_lock);
 	return nfs_ok;
 }
 
@@ -4420,7 +4432,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	if (stp == NULL)
 		return NULL;
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4429,6 +4440,9 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
 	list_add(&stp->st_locks, &open_stp->st_locks);
+	spin_lock(&fp->fi_lock);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
+	spin_unlock(&fp->fi_lock);
 	return stp;
 }
 
-- 
1.9.3

