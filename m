Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:52979 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFZTOu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:50 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so3645035qcz.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 047/117] nfsd: Add locking to protect the state owner lists
Date: Thu, 26 Jun 2014 15:12:27 -0400
Message-Id: <1403810017-16062-48-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change to using the clp->cl_lock for this. For now, there's a lot of
cl_lock thrashing, but in later patches we'll eliminate that and close
the potential races that can occur when releasing the cl_lock while
walking the lists. For now, the client_mutex prevents those races.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 93876dc366cc..a3413cb4ac46 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -885,6 +885,8 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_file *fp = stp->st_stid.sc_file;
 
+	lockdep_assert_held(&stp->st_stateowner->so_client->cl_lock);
+
 	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
 	spin_unlock(&fp->fi_lock);
@@ -918,9 +920,13 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
+	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
+
+	spin_lock(&oo->oo_owner.so_client->cl_lock);
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
+	spin_unlock(&oo->oo_owner.so_client->cl_lock);
 	put_generic_stateid(stp);
 }
 
@@ -964,20 +970,26 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 }
 
 static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
+	__releases(&open_stp->st_stateowner->so_client->cl_lock)
+	__acquires(&open_stp->st_stateowner->so_client->cl_lock)
 {
 	struct nfs4_ol_stateid *stp;
 
 	while (!list_empty(&open_stp->st_locks)) {
 		stp = list_entry(open_stp->st_locks.next,
 				struct nfs4_ol_stateid, st_locks);
+		spin_unlock(&open_stp->st_stateowner->so_client->cl_lock);
 		release_lock_stateid(stp);
+		spin_lock(&open_stp->st_stateowner->so_client->cl_lock);
 	}
 }
 
 static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
+	spin_lock(&stp->st_stateowner->so_client->cl_lock);
 	unhash_generic_stateid(stp);
 	release_open_stateid_locks(stp);
+	spin_unlock(&stp->st_stateowner->so_client->cl_lock);
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
@@ -2987,7 +2999,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
-	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
@@ -2996,9 +3007,12 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	set_access(open->op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
 	stp->st_openstp = NULL;
+	spin_lock(&oo->oo_owner.so_client->cl_lock);
+	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	spin_lock(&fp->fi_lock);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	spin_unlock(&fp->fi_lock);
+	spin_unlock(&oo->oo_owner.so_client->cl_lock);
 }
 
 static void
@@ -4669,6 +4683,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 static struct nfs4_ol_stateid *
 alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
 {
+	struct nfs4_openowner *oo = openowner(open_stp->st_stateowner);
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
 
@@ -4676,7 +4691,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	if (stp == NULL)
 		return NULL;
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
-	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
@@ -4684,10 +4698,13 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
+	spin_lock(&oo->oo_owner.so_client->cl_lock);
 	list_add(&stp->st_locks, &open_stp->st_locks);
+	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	spin_lock(&fp->fi_lock);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	spin_unlock(&fp->fi_lock);
+	spin_unlock(&oo->oo_owner.so_client->cl_lock);
 	return stp;
 }
 
-- 
1.9.3

