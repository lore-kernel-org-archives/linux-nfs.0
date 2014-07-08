Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:60091 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSEq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:46 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so5546985qcv.33
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 007/100] nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
Date: Tue,  8 Jul 2014 14:02:55 -0400
Message-Id: <1404842668-22521-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index 4b91058169af..c5818e02bc6a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -720,7 +720,11 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	struct nfs4_file *fp = stp->st_file;
+
+	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
+	spin_unlock(&fp->fi_lock);
 	list_del(&stp->st_perstateowner);
 }
 
@@ -2814,7 +2818,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
@@ -2823,6 +2826,9 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	set_access(open->op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
 	stp->st_openstp = NULL;
+	spin_lock(&fp->fi_lock);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
+	spin_unlock(&fp->fi_lock);
 }
 
 static void
@@ -2930,6 +2936,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 		return nfs_ok;
 	ret = nfserr_locked;
 	/* Search for conflicting share reservations */
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
 		if (test_deny(deny_type, stp) ||
 		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
@@ -2937,6 +2944,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	}
 	ret = nfs_ok;
 out:
+	spin_unlock(&fp->fi_lock);
 	put_nfs4_file(fp);
 	return ret;
 }
@@ -3172,6 +3180,7 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 	struct nfs4_ol_stateid *local;
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
@@ -3180,9 +3189,12 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
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
 
@@ -4432,7 +4444,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	if (stp == NULL)
 		return NULL;
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4441,6 +4452,9 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
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

