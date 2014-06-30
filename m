Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:57962 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754567AbaF3PvD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:03 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so6472699qae.19
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 021/114] nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
Date: Mon, 30 Jun 2014 11:48:50 -0400
Message-Id: <1404143423-24381-22-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index 993aa196dd9e..0721c77a38c9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -716,7 +716,11 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	struct nfs4_file *fp = stp->st_file;
+
+	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
+	spin_unlock(&fp->fi_lock);
 	list_del(&stp->st_perstateowner);
 }
 
@@ -2809,7 +2813,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
@@ -2818,6 +2821,9 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	set_access(open->op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
 	stp->st_openstp = NULL;
+	spin_lock(&fp->fi_lock);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
+	spin_unlock(&fp->fi_lock);
 }
 
 static void
@@ -2925,6 +2931,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 		return nfs_ok;
 	ret = nfserr_locked;
 	/* Search for conflicting share reservations */
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
 		if (test_deny(deny_type, stp) ||
 		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
@@ -2932,6 +2939,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	}
 	ret = nfs_ok;
 out:
+	spin_unlock(&fp->fi_lock);
 	put_nfs4_file(fp);
 	return ret;
 }
@@ -3163,6 +3171,7 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 	struct nfs4_ol_stateid *local;
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
@@ -3171,9 +3180,12 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
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
 
@@ -4421,7 +4433,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	if (stp == NULL)
 		return NULL;
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4430,6 +4441,9 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
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

