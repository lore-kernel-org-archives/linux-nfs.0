Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:59076 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaG2Uej (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:39 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so306309qga.8
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:38 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 06/38] nfsd: do filp_close in sc_free callback for lock stateids
Date: Tue, 29 Jul 2014 16:33:49 -0400
Message-Id: <1406666061-14175-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Releasing locks when we unhash the stateid instead of doing so only when
the stateid is actually released will be problematic in later patches
when we need to protect the unhashing with spinlocks. Move it into the
sc_free operation instead.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e45a45d12954..a99c054da4a6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -502,7 +502,7 @@ out_free:
 	return NULL;
 }
 
-static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
+static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
 {
 	struct nfs4_stid *stid;
 	struct nfs4_ol_stateid *stp;
@@ -907,16 +907,23 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
 	kmem_cache_free(stateid_slab, stid);
 }
 
-static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 {
+	struct nfs4_ol_stateid *stp = openlockstateid(stid);
+	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 	struct file *file;
 
+	file = find_any_file(stp->st_stid.sc_file);
+	if (file)
+		filp_close(file, (fl_owner_t)lo);
+	nfs4_free_ol_stateid(stid);
+}
+
+static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
+{
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_stid.sc_file);
-	if (file)
-		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	nfs4_put_stid(&stp->st_stid);
 }
 
@@ -3287,7 +3294,7 @@ new_owner:
 		return nfserr_jukebox;
 	open->op_openowner = oo;
 alloc_stateid:
-	open->op_stp = nfs4_alloc_stateid(clp);
+	open->op_stp = nfs4_alloc_open_stateid(clp);
 	if (!open->op_stp)
 		return nfserr_jukebox;
 	return nfs_ok;
@@ -4703,17 +4710,20 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
 		struct inode *inode,
 		struct nfs4_ol_stateid *open_stp)
 {
+	struct nfs4_stid *s;
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
 
-	stp = nfs4_alloc_stateid(clp);
-	if (stp == NULL)
+	s = nfs4_alloc_stid(clp, stateid_slab);
+	if (s == NULL)
 		return NULL;
+	stp = openlockstateid(s);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
+	stp->st_stid.sc_free = nfs4_free_lock_stateid;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-- 
1.9.3

