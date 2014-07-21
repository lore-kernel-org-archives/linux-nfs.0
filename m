Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:59405 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbaGUPDM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:12 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so5472231qgd.14
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:10 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 08/40] nfsd: Add locking to protect the state owner lists
Date: Mon, 21 Jul 2014 11:02:20 -0400
Message-Id: <1405954972-28904-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
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
index cedf86a3b9b7..c61f9475f1c6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -897,6 +897,8 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_file *fp = stp->st_stid.sc_file;
 
+	lockdep_assert_held(&stp->st_stateowner->so_client->cl_lock);
+
 	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
 	spin_unlock(&fp->fi_lock);
@@ -930,9 +932,13 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 
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
 
@@ -976,20 +982,26 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
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
@@ -3001,7 +3013,6 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	INIT_LIST_HEAD(&stp->st_locks);
-	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
@@ -3010,9 +3021,12 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
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
@@ -4716,6 +4730,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 static struct nfs4_ol_stateid *
 alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
 {
+	struct nfs4_openowner *oo = openowner(open_stp->st_stateowner);
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
 
@@ -4723,7 +4738,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	if (stp == NULL)
 		return NULL;
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
-	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
@@ -4731,10 +4745,13 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
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

