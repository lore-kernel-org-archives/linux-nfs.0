Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53248 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/15] nfsd4: cleanup lock/stateowner initialization
Date: Fri, 26 Aug 2011 18:28:27 -0400
Message-Id: <1314397716-18602-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Share some common code, stop doing silly things like initializing a list
head immediately before adding it to a list, etc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  100 ++++++++++++++++++++++++++------------------------
 1 files changed, 52 insertions(+), 48 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d32a1a6..7fb6ddc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2217,51 +2217,61 @@ nfs4_free_stateowner(struct kref *kref)
 	kmem_cache_free(stateowner_slab, sop);
 }
 
-static inline struct nfs4_stateowner *
-alloc_stateowner(struct xdr_netobj *owner)
+static void init_nfs4_replay(struct nfs4_replay *rp)
 {
-	struct nfs4_stateowner *sop;
-
-	if ((sop = kmem_cache_alloc(stateowner_slab, GFP_KERNEL))) {
-		if ((sop->so_owner.data = kmalloc(owner->len, GFP_KERNEL))) {
-			memcpy(sop->so_owner.data, owner->data, owner->len);
-			sop->so_owner.len = owner->len;
-			kref_init(&sop->so_ref);
-			return sop;
-		} 
-		kmem_cache_free(stateowner_slab, sop);
-	}
-	return NULL;
+	rp->rp_status = nfserr_serverfault;
+	rp->rp_buflen = 0;
+	rp->rp_buf = rp->rp_ibuf;
 }
 
-static struct nfs4_stateowner *
-alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
+static inline struct nfs4_stateowner *alloc_stateowner(struct xdr_netobj *owner, struct nfs4_client *clp)
+{
 	struct nfs4_stateowner *sop;
-	struct nfs4_replay *rp;
-	unsigned int idhashval;
 
-	if (!(sop = alloc_stateowner(&open->op_owner)))
+	sop = kmem_cache_alloc(stateowner_slab, GFP_KERNEL);
+	if (!sop)
+		return NULL;
+
+	sop->so_owner.data = kmemdup(owner->data, owner->len, GFP_KERNEL);
+	if (!sop->so_owner.data) {
+		kmem_cache_free(stateowner_slab, sop);
 		return NULL;
-	idhashval = open_ownerid_hashval(current_ownerid);
-	INIT_LIST_HEAD(&sop->so_idhash);
-	INIT_LIST_HEAD(&sop->so_strhash);
+	}
+	sop->so_owner.len = owner->len;
+
+	kref_init(&sop->so_ref);
 	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_stateids);
-	INIT_LIST_HEAD(&sop->so_perstateid);  /* not used */
+	INIT_LIST_HEAD(&sop->so_perstateid);
 	INIT_LIST_HEAD(&sop->so_close_lru);
+	sop->so_id = current_ownerid++;
 	sop->so_time = 0;
+	sop->so_client = clp;
+	init_nfs4_replay(&sop->so_replay);
+	return sop;
+}
+
+static void hash_openowner(struct nfs4_stateowner *sop, struct nfs4_client *clp, unsigned int strhashval)
+{
+	unsigned int idhashval;
+
+	idhashval = open_ownerid_hashval(sop->so_id);
 	list_add(&sop->so_idhash, &open_ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &open_ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_openowners);
+}
+
+static struct nfs4_stateowner *
+alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
+	struct nfs4_stateowner *sop;
+
+	sop = alloc_stateowner(&open->op_owner, clp);
+	if (!sop)
+		return NULL;
 	sop->so_is_open_owner = 1;
-	sop->so_id = current_ownerid++;
-	sop->so_client = clp;
 	sop->so_seqid = open->op_seqid;
 	sop->so_confirmed = 0;
-	rp = &sop->so_replay;
-	rp->rp_status = nfserr_serverfault;
-	rp->rp_buflen = 0;
-	rp->rp_buf = rp->rp_ibuf;
+	hash_openowner(sop, clp, strhashval);
 	return sop;
 }
 
@@ -3904,6 +3914,16 @@ find_lockstateowner_str(struct inode *inode, clientid_t *clid,
 	return NULL;
 }
 
+static void hash_lockowner(struct nfs4_stateowner *sop, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp)
+{
+	unsigned int idhashval;
+
+	idhashval = lockownerid_hashval(sop->so_id);
+	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
+	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
+	list_add(&sop->so_perstateid, &open_stp->st_lockowners);
+}
+
 /*
  * Alloc a lock owner structure.
  * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
@@ -3915,33 +3935,17 @@ find_lockstateowner_str(struct inode *inode, clientid_t *clid,
 static struct nfs4_stateowner *
 alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp, struct nfsd4_lock *lock) {
 	struct nfs4_stateowner *sop;
-	struct nfs4_replay *rp;
-	unsigned int idhashval;
 
-	if (!(sop = alloc_stateowner(&lock->lk_new_owner)))
+	sop = alloc_stateowner(&lock->lk_new_owner, clp);
+	if (!sop)
 		return NULL;
-	idhashval = lockownerid_hashval(current_ownerid);
-	INIT_LIST_HEAD(&sop->so_idhash);
-	INIT_LIST_HEAD(&sop->so_strhash);
-	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_stateids);
-	INIT_LIST_HEAD(&sop->so_perstateid);
-	INIT_LIST_HEAD(&sop->so_close_lru); /* not used */
-	sop->so_time = 0;
-	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
-	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
-	list_add(&sop->so_perstateid, &open_stp->st_lockowners);
 	sop->so_is_open_owner = 0;
-	sop->so_id = current_ownerid++;
-	sop->so_client = clp;
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
 	sop->so_seqid = lock->lk_new_lock_seqid + 1;
 	sop->so_confirmed = 1;
-	rp = &sop->so_replay;
-	rp->rp_status = nfserr_serverfault;
-	rp->rp_buflen = 0;
-	rp->rp_buf = rp->rp_ibuf;
+	hash_lockowner(sop, strhashval, clp, open_stp);
 	return sop;
 }
 
-- 
1.7.4.1

