Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48598 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab1IZWjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:39:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: use idr for stateid's
Date: Mon, 26 Sep 2011 18:39:38 -0400
Message-Id: <1317076780-22309-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20110926223722.GB22140@fieldses.org>
References: <20110926223722.GB22140@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The idr system is designed exactly for generating id and looking up
integer id's.  Thanks to Trond for pointing it out.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  124 ++++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h     |    1 -
 2 files changed, 73 insertions(+), 52 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cb36c9a..a9e71cd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -32,6 +32,7 @@
 *
 */
 
+#include <linux/idr.h>
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
@@ -49,7 +50,6 @@
 time_t nfsd4_lease = 90;     /* default lease time */
 time_t nfsd4_grace = 90;
 static time_t boot_time;
-static u32 current_stateid = 1;
 static stateid_t zerostateid;             /* bits all 0 */
 static stateid_t onestateid;              /* bits all 1 */
 static u64 current_sessionid = 1;
@@ -149,10 +149,7 @@ static struct list_head	open_ownerstr_hashtbl[OPEN_OWNER_HASH_SIZE];
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 
-/* hash table for (open)nfs4_ol_stateid */
-#define STATEID_HASH_BITS              10
-#define STATEID_HASH_SIZE              (1 << STATEID_HASH_BITS)
-#define STATEID_HASH_MASK              (STATEID_HASH_SIZE - 1)
+struct idr stateids;
 
 static unsigned int file_hashval(struct inode *ino)
 {
@@ -160,13 +157,7 @@ static unsigned int file_hashval(struct inode *ino)
 	return hash_ptr(ino, FILE_HASH_BITS);
 }
 
-static unsigned int stateid_hashval(stateid_t *s)
-{
-	return opaque_hashval(&s->si_opaque, sizeof(stateid_opaque_t)) & STATEID_HASH_MASK;
-}
-
 static struct list_head file_hashtbl[FILE_HASH_SIZE];
-static struct list_head stateid_hashtbl[STATEID_HASH_SIZE];
 
 static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 {
@@ -215,26 +206,52 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 		__nfs4_file_put_access(fp, oflag);
 }
 
-static inline void hash_stid(struct nfs4_stid *stid)
+static inline int get_new_stid(struct nfs4_stid *stid)
 {
-	stateid_t *s = &stid->sc_stateid;
-	unsigned int hashval;
+	static int min_stateid = 0;
+	int new_stid;
+	int error;
+
+	if (!idr_pre_get(&stateids, GFP_KERNEL))
+		return -ENOMEM;
+
+	error = idr_get_new_above(&stateids, stid, min_stateid, &new_stid);
+	/*
+	 * All this code is currently serialized; the preallocation
+	 * above should still be ours:
+	 */
+	BUG_ON(error);
+	/*
+	 * It shouldn't be a problem to reuse an opaque stateid value.
+	 * I don't think it is for 4.1.  But with 4.0 I worry that, for
+	 * example, a stray write retransmission could be accepted by
+	 * the server when it should have been rejected.  Therefore,
+	 * adopt a trick from the sctp code to attempt to maximize the
+	 * amount of time until an id is reused, by ensuring they always
+	 * "increase" (mod INT_MAX):
+	 */
 
-	hashval = stateid_hashval(s);
-	list_add(&stid->sc_hash, &stateid_hashtbl[hashval]);
+	min_stateid = new_stid+1;
+	if (min_stateid == INT_MAX)
+		min_stateid = 0;
+	return new_stid;
 }
 
-static void init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, unsigned char type)
+static inline __be32 init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, unsigned char type)
 {
 	stateid_t *s = &stid->sc_stateid;
+	int new_id;
 
 	stid->sc_type = type;
 	stid->sc_client = cl;
 	s->si_opaque.so_clid = cl->cl_clientid;
-	s->si_opaque.so_id = current_stateid++;
+	new_id = get_new_stid(stid);
+	if (new_id < 0)
+		return nfserr_jukebox;
+	s->si_opaque.so_id = (u32)new_id;
 	/* Will be incremented before return to client: */
 	s->si_generation = 0;
-	hash_stid(stid);
+	return 0;
 }
 
 static struct nfs4_delegation *
@@ -242,6 +259,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_file *fp = stp->st_file;
+	__be32 status;
 
 	dprintk("NFSD alloc_init_deleg\n");
 	/*
@@ -258,11 +276,15 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
 	if (dp == NULL)
 		return dp;
-	init_stid(&dp->dl_stid, clp, NFS4_DELEG_STID);
+	status = init_stid(&dp->dl_stid, clp, NFS4_DELEG_STID);
+	if (status) {
+		kmem_cache_free(deleg_slab, dp);
+		return NULL;
+	}
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
-	 * meaning of seqid 0 isn't really meaningful, really, but let's
-	 * avoid 0 anyway just for consistency and use 1:
+	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
+	 * 0 anyway just for consistency and use 1:
 	 */
 	dp->dl_stid.sc_stateid.si_generation = 1;
 	num_delegations++;
@@ -300,11 +322,16 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	}
 }
 
+static void unhash_stid(struct nfs4_stid *s)
+{
+	idr_remove(&stateids, s->sc_stateid.si_opaque.so_id);
+}
+
 /* Called under the state lock. */
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_stid.sc_hash);
+	unhash_stid(&dp->dl_stid);
 	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_perfile);
@@ -457,7 +484,7 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	struct file *file;
 
 	unhash_generic_stateid(stp);
-	list_del(&stp->st_stid.sc_hash);
+	unhash_stid(&stp->st_stid);
 	file = find_any_file(stp->st_file);
 	if (file)
 		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
@@ -506,7 +533,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	list_del(&stp->st_stid.sc_hash);
+	unhash_stid(&stp->st_stid);
 	free_generic_stateid(stp);
 }
 
@@ -528,7 +555,7 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		list_del_init(&s->st_stid.sc_hash);
+		unhash_stid(&s->st_stid);
 		free_generic_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
@@ -1099,23 +1126,9 @@ static void gen_confirm(struct nfs4_client *clp)
 	*p++ = i++;
 }
 
-static int
-same_stateid(stateid_t *id_one, stateid_t *id_two)
-{
-	return 0 == memcmp(&id_one->si_opaque, &id_two->si_opaque,
-					sizeof(stateid_opaque_t));
-}
-
 static struct nfs4_stid *find_stateid(stateid_t *t)
 {
-	struct nfs4_stid *s;
-	unsigned int hashval;
-
-	hashval = stateid_hashval(t);
-	list_for_each_entry(s, &stateid_hashtbl[hashval], sc_hash)
-		if (same_stateid(&s->sc_stateid, t))
-			return s;
-	return NULL;
+	return idr_find(&stateids, t->si_opaque.so_id);
 }
 
 static struct nfs4_stid *find_stateid_by_type(stateid_t *t, char typemask)
@@ -2342,12 +2355,14 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	return oo;
 }
 
-static inline void
-init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
+static inline __be32 init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 	struct nfs4_client *clp = oo->oo_owner.so_client;
+	__be32 status;
 
-	init_stid(&stp->st_stid, clp, NFS4_OPEN_STID);
+	status = init_stid(&stp->st_stid, clp, NFS4_OPEN_STID);
+	if (status)
+		return status;
 	INIT_LIST_HEAD(&stp->st_lockowners);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
@@ -2360,6 +2375,7 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd
 		  &stp->st_access_bmap);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 	stp->st_openstp = NULL;
+	return nfs_ok;
 }
 
 static void
@@ -2949,7 +2965,11 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfs4_new_open(rqstp, &stp, fp, current_fh, open);
 		if (status)
 			goto out;
-		init_open_stateid(stp, fp, open);
+		status = init_open_stateid(stp, fp, open);
+		if (status) {
+			release_open_stateid(stp);
+			goto out;
+		}
 		status = nfsd4_truncate(rqstp, current_fh, open);
 		if (status) {
 			release_open_stateid(stp);
@@ -3824,11 +3844,16 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 {
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
+	__be32 status;
 
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
-		goto out;
-	init_stid(&stp->st_stid, clp, NFS4_LOCK_STID);
+		return NULL;
+	status = init_stid(&stp->st_stid, clp, NFS4_LOCK_STID);
+	if (status) {
+		free_generic_stateid(stp);
+		return NULL;
+	}
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
@@ -3837,8 +3862,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-
-out:
 	return stp;
 }
 
@@ -4386,8 +4409,7 @@ nfs4_state_init(void)
 	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&open_ownerstr_hashtbl[i]);
 	}
-	for (i = 0; i < STATEID_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&stateid_hashtbl[i]);
+	idr_init(&stateids);
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 70062b7..3ed5f99 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -79,7 +79,6 @@ struct nfs4_stid {
 /* For an open stateid kept around *only* to process close replays: */
 #define NFS4_CLOSED_STID 8
 	unsigned char sc_type;
-	struct list_head sc_hash;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
 };
-- 
1.7.4.1

