From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 016 of 16] nfsd4: reference count struct nfs4_file
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006eM-Ik@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikQ-0006V0-Jj
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikP-0004EQ-Iv
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:26 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



Add a struct kref to each nfs4_file and take a reference to it from each
stateid and delegation that refers to it.  The atomicity guarantees are
overkill given that all this stuff is done under the single nfsd4 state lock,
but a) we'd like finer-grained locking some day, and b) this simplifies the
cleanup of the structures a bit, something that has previously been a bit
complicated and bug-prone.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |  100 +++++++++++++++++++++----------------------
 ./include/linux/nfsd/state.h |    1 
 2 files changed, 52 insertions(+), 49 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:46:22.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:47:13.000000000 +1000
@@ -111,7 +111,6 @@ opaque_hashval(const void *ptr, int nbyt
 /* forward declarations */
 static void release_stateowner(struct nfs4_stateowner *sop);
 static void release_stateid(struct nfs4_stateid *stp, int flags);
-static void release_file(struct nfs4_file *fp);
 
 /*
  * Delegation state
@@ -121,6 +120,27 @@ static void release_file(struct nfs4_fil
 spinlock_t recall_lock;
 static struct list_head del_recall_lru;
 
+static void
+free_nfs4_file(struct kref *kref)
+{
+	struct nfs4_file *fp = container_of(kref, struct nfs4_file, fi_ref);
+	list_del(&fp->fi_hash);
+	iput(fp->fi_inode);
+	kmem_cache_free(file_slab, fp);
+}
+
+static inline void
+put_nfs4_file(struct nfs4_file *fi)
+{
+	kref_put(&fi->fi_ref, free_nfs4_file);
+}
+
+static inline void
+get_nfs4_file(struct nfs4_file *fi)
+{
+	kref_get(&fi->fi_ref);
+}
+
 static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_fh *current_fh, u32 type)
 {
@@ -136,6 +156,7 @@ alloc_init_deleg(struct nfs4_client *clp
 	INIT_LIST_HEAD(&dp->dl_del_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
 	dp->dl_client = clp;
+	get_nfs4_file(fp);
 	dp->dl_file = fp;
 	dp->dl_flock = NULL;
 	get_file(stp->st_vfs_file);
@@ -163,6 +184,7 @@ nfs4_put_delegation(struct nfs4_delegati
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
 		dprintk("NFSD: freeing dp %p\n",dp);
+		put_nfs4_file(dp->dl_file);
 		kmem_cache_free(deleg_slab, dp);
 	}
 }
@@ -953,6 +975,7 @@ alloc_init_file(struct inode *ino)
 
 	fp = kmem_cache_alloc(file_slab, GFP_KERNEL);
 	if (fp) {
+		kref_init(&fp->fi_ref);
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_stateids);
 		INIT_LIST_HEAD(&fp->fi_delegations);
@@ -965,24 +988,6 @@ alloc_init_file(struct inode *ino)
 }
 
 static void
-release_all_files(void)
-{
-	int i;
-	struct nfs4_file *fp;
-
-	for (i=0;i<FILE_HASH_SIZE;i++) {
-		while (!list_empty(&file_hashtbl[i])) {
-			fp = list_entry(file_hashtbl[i].next, struct nfs4_file, fi_hash);
-			/* this should never be more than once... */
-			if (!list_empty(&fp->fi_stateids) || !list_empty(&fp->fi_delegations)) {
-				printk("ERROR: release_all_files: file %p is open, creating dangling state !!!\n",fp);
-			}
-			release_file(fp);
-		}
-	}
-}
-
-static void
 nfsd4_free_slab(kmem_cache_t **slab)
 {
 	int status;
@@ -1141,6 +1146,7 @@ init_stateid(struct nfs4_stateid *stp, s
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = sop;
+	get_nfs4_file(fp);
 	stp->st_file = fp;
 	stp->st_stateid.si_boot = boot_time;
 	stp->st_stateid.si_stateownerid = sop->so_id;
@@ -1166,18 +1172,11 @@ release_stateid(struct nfs4_stateid *stp
 		nfsd_close(filp);
 	} else if (flags & LOCK_STATE)
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
+	put_nfs4_file(stp->st_file);
 	kmem_cache_free(stateid_slab, stp);
 	stp = NULL;
 }
 
-static void
-release_file(struct nfs4_file *fp)
-{
-	list_del(&fp->fi_hash);
-	iput(fp->fi_inode);
-	kmem_cache_free(file_slab, fp);
-}	
-
 void
 move_to_close_lru(struct nfs4_stateowner *sop)
 {
@@ -1192,7 +1191,6 @@ void
 release_state_owner(struct nfs4_stateid *stp, int flag)
 {
 	struct nfs4_stateowner *sop = stp->st_stateowner;
-	struct nfs4_file *fp = stp->st_file;
 
 	dprintk("NFSD: release_state_owner\n");
 	release_stateid(stp, flag);
@@ -1203,10 +1201,6 @@ release_state_owner(struct nfs4_stateid 
 	 */
 	if (sop->so_confirmed && list_empty(&sop->so_perfilestate))
 		move_to_close_lru(sop);
-	/* unused nfs4_file's are releseed. XXX slab cache? */
-	if (list_empty(&fp->fi_stateids) && list_empty(&fp->fi_delegations)) {
-		release_file(fp);
-	}
 }
 
 static int
@@ -1236,8 +1230,10 @@ find_file(struct inode *ino)
 	struct nfs4_file *fp;
 
 	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
-		if (fp->fi_inode == ino)
+		if (fp->fi_inode == ino) {
+			get_nfs4_file(fp);
 			return fp;
+		}
 	}
 	return NULL;
 }
@@ -1288,19 +1284,24 @@ nfs4_share_conflict(struct svc_fh *curre
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp;
 	struct nfs4_stateid *stp;
+	int ret;
 
 	dprintk("NFSD: nfs4_share_conflict\n");
 
 	fp = find_file(ino);
-	if (fp) {
+	if (!fp)
+		return nfs_ok;
+	ret = nfserr_share_denied;
 	/* Search for conflicting share reservations */
-		list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
-			if (test_bit(deny_type, &stp->st_deny_bmap) ||
-			    test_bit(NFS4_SHARE_DENY_BOTH, &stp->st_deny_bmap))
-				return nfserr_share_denied;
-		}
+	list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
+		if (test_bit(deny_type, &stp->st_deny_bmap) ||
+		    test_bit(NFS4_SHARE_DENY_BOTH, &stp->st_deny_bmap))
+			goto out;
 	}
-	return nfs_ok;
+	ret = nfs_ok;
+out:
+	put_nfs4_file(fp);
+	return ret;
 }
 
 static inline void
@@ -1829,10 +1830,8 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
 	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
 out:
-	/* take the opportunity to clean up unused state */
-	if (fp && list_empty(&fp->fi_stateids) && list_empty(&fp->fi_delegations))
-		release_file(fp);
-
+	if (fp)
+		put_nfs4_file(fp);
 	/* CLAIM_PREVIOUS has different error returns */
 	nfs4_set_claim_prev(open, &status);
 	/*
@@ -2480,16 +2479,19 @@ find_stateid(stateid_t *stid, int flags)
 static struct nfs4_delegation *
 find_delegation_stateid(struct inode *ino, stateid_t *stid)
 {
-	struct nfs4_file *fp = NULL;
+	struct nfs4_file *fp;
+	struct nfs4_delegation *dl;
 
 	dprintk("NFSD:find_delegation_stateid stateid=(%08x/%08x/%08x/%08x)\n",
                     stid->si_boot, stid->si_stateownerid,
                     stid->si_fileid, stid->si_generation);
 
 	fp = find_file(ino);
-	if (fp)
-		return find_delegation_file(fp, stid);
-	return NULL;
+	if (!fp)
+		return NULL;
+	dl = find_delegation_file(fp, stid);
+	put_nfs4_file(fp);
+	return dl;
 }
 
 /*
@@ -2636,6 +2638,7 @@ alloc_init_lock_stateid(struct nfs4_stat
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
 	stp->st_stateowner = sop;
+	get_nfs4_file(fp);
 	stp->st_file = fp;
 	stp->st_stateid.si_boot = boot_time;
 	stp->st_stateid.si_stateownerid = sop->so_id;
@@ -3287,7 +3290,6 @@ __nfs4_state_shutdown(void)
 		unhash_delegation(dp);
 	}
 
-	release_all_files();
 	cancel_delayed_work(&laundromat_work);
 	flush_scheduled_work();
 	nfs4_init = 0;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-04-08 10:46:22.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-04-08 10:47:13.000000000 +1000
@@ -217,6 +217,7 @@ struct nfs4_stateowner {
 *      share_acces, share_deny on the file.
 */
 struct nfs4_file {
+	struct kref		fi_ref;
 	struct list_head        fi_hash;    /* hash by "struct inode *" */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
