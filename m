Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33831 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaDRSpY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:24 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so1905304iec.29
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 12/70] NFSd: Add fine grained protection for the nfs4_file->fi_stateids list
Date: Fri, 18 Apr 2014 14:44:06 -0400
Message-Id: <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 21 ++++++++++++++++++---
 fs/nfsd/state.h     |  1 +
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3656980b5d19..f77cc9206373 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -623,7 +623,11 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	struct nfs4_file *fp = stp->st_file;
+
+	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
+	spin_unlock(&fp->fi_lock);
 	list_del(&stp->st_perstateowner);
 }
 
@@ -2530,6 +2534,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	unsigned int hashval = file_hashval(ino);
 
 	atomic_set(&fp->fi_ref, 1);
+	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
 	fp->fi_inode = igrab(ino);
@@ -2650,7 +2655,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_lockowners);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
@@ -2659,6 +2663,9 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	set_access(open->op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
 	stp->st_openstp = NULL;
+	spin_lock(&fp->fi_lock);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
+	spin_unlock(&fp->fi_lock);
 }
 
 static void
@@ -2740,6 +2747,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 		return nfs_ok;
 	ret = nfserr_locked;
 	/* Search for conflicting share reservations */
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
 		if (test_deny(deny_type, stp) ||
 		    test_deny(NFS4_SHARE_DENY_BOTH, stp))
@@ -2747,6 +2755,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 	}
 	ret = nfs_ok;
 out:
+	spin_unlock(&fp->fi_lock);
 	put_nfs4_file(fp);
 	return ret;
 }
@@ -2943,6 +2952,7 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 	struct nfs4_ol_stateid *local;
 	struct nfs4_openowner *oo = open->op_openowner;
 
+	spin_lock(&fp->fi_lock);
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
@@ -2951,9 +2961,12 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
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
 
@@ -4256,7 +4269,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	if (stp == NULL)
 		return NULL;
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
-	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4264,6 +4276,9 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
+	spin_lock(&fp->fi_lock);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
+	spin_unlock(&fp->fi_lock);
 	return stp;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 02c5a203c738..83d9721d9644 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -383,6 +383,7 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
 /* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
 struct nfs4_file {
 	atomic_t		fi_ref;
+	spinlock_t		fi_lock;
 	struct hlist_node       fi_hash;    /* hash by "struct inode *" */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;
-- 
1.9.0

