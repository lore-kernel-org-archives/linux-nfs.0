From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 7 - nfsd byte range locking - LOCK
Date: Tue, 23 Sep 2003 09:33:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aBC-0004EB-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBc-0008Uf-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:44 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBa-0003ht-3t
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:42 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 23 Sep 2003 09:33:35 +1000
To: Linus Torvalds <torvalds@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

From: "William A.(Andy) Adamson" <andros@citi.umich.edu>

this patch implements the nfsv4 LOCK operation.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |    9 
 ./fs/nfsd/nfs4state.c        |  460 ++++++++++++++++++++++++++++++++++++++-----
 ./fs/nfsd/nfs4xdr.c          |   80 +++++++
 ./include/linux/nfs4.h       |    9 
 ./include/linux/nfsd/nfsd.h  |    2 
 ./include/linux/nfsd/state.h |   27 ++
 ./include/linux/nfsd/xdr4.h  |   54 +++++
 7 files changed, 581 insertions(+), 60 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-09-23 09:11:42.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-09-23 09:11:47.000000000 +1000
@@ -377,7 +377,7 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 	}
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(current_fh, &read->rd_stateid, 
-					CHECK_FH, &stp))) {
+					CHECK_FH | RDWR_STATE, &stp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -467,7 +467,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 		nfs4_lock_state();
 		if ((status = nfs4_preprocess_stateid_op(current_fh, 
 						&setattr->sa_stateid, 
-						CHECK_FH, &stp))) {
+						CHECK_FH | RDWR_STATE, &stp))) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			goto out;
 		}
@@ -507,7 +507,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 		goto zero_stateid;
 	}
 	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid, 
-					CHECK_FH, &stp))) {
+					CHECK_FH | RDWR_STATE, &stp))) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		goto out;
 	}
@@ -681,6 +681,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		case OP_LINK:
 			op->status = nfsd4_link(rqstp, &current_fh, &save_fh, &op->u.link);
 			break;
+		case OP_LOCK:
+			op->status = nfsd4_lock(rqstp, &current_fh, &op->u.lock);
+			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, &current_fh, &op->u.lookup);
 			break;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-09-23 09:11:42.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-09-23 09:11:47.000000000 +1000
@@ -38,7 +38,6 @@
 #include <linux/major.h>
 #include <linux/slab.h>
 
-
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
@@ -70,6 +69,10 @@ u32 alloc_sowner = 0;
 u32 free_sowner = 0;
 u32 vfsopen = 0;
 u32 vfsclose = 0;
+u32 alloc_lsowner= 0;
+
+/* forward declarations */
+struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 
 /* Locking:
  *
@@ -106,7 +109,7 @@ opaque_hashval(const void *ptr, int nbyt
 
 /* forward declarations */
 static void release_stateowner(struct nfs4_stateowner *sop);
-static void release_stateid(struct nfs4_stateid *stp);
+static void release_stateid(struct nfs4_stateid *stp, int flags);
 static void release_file(struct nfs4_file *fp);
 
 
@@ -757,7 +760,7 @@ free_stateowner(struct nfs4_stateowner *
 }
 
 static struct nfs4_stateowner *
-alloc_init_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
+alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
 	struct nfs4_stateowner *sop;
 	struct nfs4_replay *rp;
 	unsigned int idhashval;
@@ -773,6 +776,7 @@ alloc_init_stateowner(unsigned int strha
 	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
 	add_perclient++;
+	sop->so_is_open_owner = 1;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;
 	sop->so_seqid = open->op_seqid;
@@ -797,7 +801,10 @@ release_stateowner(struct nfs4_stateowne
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
 			struct nfs4_stateid, st_perfilestate);
-		release_stateid(stp);
+		if(sop->so_is_open_owner)
+			release_stateid(stp, OPEN_STATE);
+		else
+			release_stateid(stp, LOCK_STATE);
 	}
 	free_stateowner(sop);
 }
@@ -824,13 +831,13 @@ init_stateid(struct nfs4_stateid *stp, s
 }
 
 static void
-release_stateid(struct nfs4_stateid *stp) {
+release_stateid(struct nfs4_stateid *stp, int flags) {
 
 	list_del_init(&stp->st_hash);
 	list_del_perfile++;
 	list_del_init(&stp->st_perfile);
 	list_del_init(&stp->st_perfilestate);
-	if(stp->st_vfs_set) {
+	if((stp->st_vfs_set) && (flags & OPEN_STATE)) {
 		nfsd_close(&stp->st_vfs_file);
 		vfsclose++;
 		dput(stp->st_vfs_file.f_dentry);
@@ -851,13 +858,14 @@ release_file(struct nfs4_file *fp)
 }	
 
 void
-release_open_state(struct nfs4_stateid *stp, struct nfsd4_close *cl)
+release_state_owner(struct nfs4_stateid *stp, struct nfs4_stateowner **sopp,
+		int flag)
 {
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	struct nfs4_file *fp = stp->st_file;
 
-	dprintk("NFSD: release_open_state\n");
-	release_stateid(stp);
+	dprintk("NFSD: release_state_owner\n");
+	release_stateid(stp, flag);
 	/*
 	 * release unused nfs4_stateowners.
 	 * XXX will need to be placed  on an  open_stateid_lru list to be
@@ -866,7 +874,7 @@ release_open_state(struct nfs4_stateid *
 	 */
 	if (sop->so_confirmed && list_empty(&sop->so_perfilestate)) {
 		release_stateowner(sop);
-		cl->cl_stateowner = NULL;
+		*sopp = NULL;
 	}
 	/* unused nfs4_file's are releseed. XXX slab cache? */
 	if (list_empty(&fp->fi_perfile)) {
@@ -875,10 +883,10 @@ release_open_state(struct nfs4_stateid *
 }
 
 static int
-cmp_owner_str(struct nfs4_stateowner *sop, struct nfsd4_open *open) {
-	return ((sop->so_owner.len == open->op_owner.len) && 
-	 !memcmp(sop->so_owner.data, open->op_owner.data, sop->so_owner.len) && 
-	  (sop->so_client->cl_clientid.cl_id == open->op_clientid.cl_id));
+cmp_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner, clientid_t *clid) {
+	return ((sop->so_owner.len == owner->len) && 
+	 !memcmp(sop->so_owner.data, owner->data, owner->len) && 
+	  (sop->so_client->cl_clientid.cl_id == clid->cl_id));
 }
 
 /* search ownerstr_hashtbl[] for owner */
@@ -889,7 +897,7 @@ find_openstateowner_str(unsigned int has
 
 	list_for_each_safe(pos, next, &ownerstr_hashtbl[hashval]) {
 		local = list_entry(pos, struct nfs4_stateowner, so_strhash);
-		if(!cmp_owner_str(local, open)) 
+		if(!cmp_owner_str(local, &open->op_owner, &open->op_clientid)) 
 			continue;
 		*op = local;
 		return(1);
@@ -1071,7 +1079,7 @@ nfsd4_process_open1(struct nfsd4_open *o
 		goto out;
 instantiate_new_owner:
 	status = nfserr_resource;
-	if (!(sop = alloc_init_stateowner(strhashval, clp, open))) 
+	if (!(sop = alloc_init_open_stateowner(strhashval, clp, open))) 
 		goto out;
 	open->op_stateowner = sop;
 	status = nfs_ok;
@@ -1205,7 +1213,7 @@ nfsd4_renew(clientid_t *clid)
 	int status;
 
 	nfs4_lock_state();
-	printk("process_renew(%08x/%08x): starting\n", 
+	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = nfserr_stale_clientid;
 	if (STALE_CLIENTID(clid))
@@ -1231,7 +1239,7 @@ nfsd4_renew(clientid_t *clid)
 	* Presumably this is because the client took too long to 
 	* RENEW, so return NFS4ERR_EXPIRED.
 	*/
-	printk("nfsd4_renew: clientid not found!\n");
+	dprintk("nfsd4_renew: clientid not found!\n");
 	status = nfserr_expired;
 out:
 	nfs4_unlock_state();
@@ -1277,25 +1285,6 @@ laundromat_main(void *not_used)
 	schedule_delayed_work(&laundromat_work, t*HZ);
 }
 
-/* search stateid_hashtbl[] for stateid */
-struct nfs4_stateid *
-find_stateid(stateid_t *stid)
-{
-	struct list_head *pos, *next;
-	struct nfs4_stateid *local = NULL;
-	u32 st_id = stid->si_stateownerid;
-	u32 f_id = stid->si_fileid;
-	unsigned int hashval = stateid_hashval(st_id, f_id);
-
-	list_for_each_safe(pos, next, &stateid_hashtbl[hashval]) {
-		local = list_entry(pos, struct nfs4_stateid, st_hash);
-		if((local->st_stateid.si_stateownerid == st_id) &&
-		   (local->st_stateid.si_fileid == f_id))
-			return local;
-	}
-	return NULL;
-}
-
 /* search ownerid_hashtbl[] for stateid owner (stateid->si_stateownerid) */
 struct nfs4_stateowner *
 find_openstateowner_id(u32 st_id) {
@@ -1338,7 +1327,7 @@ nfs4_preprocess_stateid_op(struct svc_fh
 	struct nfs4_stateid *stp;
 	int status;
 
-	dprintk("NFSD: preprocess_stateid_op:stateid = (%08x/%08x/%08x/%08x)\n",
+	dprintk("NFSD: preprocess_stateid_op: stateid = (%08x/%08x/%08x/%08x)\n",
 		stateid->si_boot, stateid->si_stateownerid, 
 		stateid->si_fileid, stateid->si_generation); 
 
@@ -1351,27 +1340,27 @@ nfs4_preprocess_stateid_op(struct svc_fh
 
 	/* BAD STATEID */
 	status = nfserr_bad_stateid;
-	if (!(stp = find_stateid(stateid))) {
-		dprintk("NFSD: process stateid: no open stateid!\n");
+	if (!(stp = find_stateid(stateid, flags))) {
+		dprintk("NFSD: preprocess_stateid_op: no open stateid!\n");
 		goto out;
 	}
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
-		dprintk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
+		dprintk("NFSD: preprocess_stateid_op: fh-stateid mismatch!\n");
 		goto out;
 	}
 	if (!stp->st_stateowner->so_confirmed) {
-		dprintk("process_stateid: lockowner not confirmed yet!\n");
+		dprintk("preprocess_stateid_op: lockowner not confirmed yet!\n");
 		goto out;
 	}
 	if (stateid->si_generation > stp->st_stateid.si_generation) {
-		dprintk("process_stateid: future stateid?!\n");
+		dprintk("preprocess_stateid_op: future stateid?!\n");
 		goto out;
 	}
 
 	/* OLD STATEID */
 	status = nfserr_old_stateid;
 	if (stateid->si_generation < stp->st_stateid.si_generation) {
-		dprintk("process_stateid: old stateid!\n");
+		dprintk("preprocess_stateid_op: old stateid!\n");
 		goto out;
 	}
 	*stpp = stp;
@@ -1418,7 +1407,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 	* this might be a retransmitted CLOSE which has arrived after 
 	* the openfile has been released.
 	*/
-	if (!(stp = find_stateid(stateid)))
+	if (!(stp = find_stateid(stateid, flags)))
 		goto no_nfs4_stateid;
 
 	status = nfserr_bad_stateid;
@@ -1507,7 +1496,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 
 	if ((status = nfs4_preprocess_seqid_op(current_fh, oc->oc_seqid,
 					&oc->oc_req_stateid,
-					CHECK_FH | CONFIRM,
+					CHECK_FH | CONFIRM | OPEN_STATE,
 					&oc->oc_stateowner, &stp)))
 		goto out; 
 
@@ -1539,7 +1528,8 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(current_fh, od->od_seqid, 
 					&od->od_stateid, 
-					CHECK_FH, &od->od_stateowner, &stp)))
+					CHECK_FH | OPEN_STATE, 
+					&od->od_stateowner, &stp)))
 		goto out; 
 
 	status = nfserr_inval;
@@ -1578,7 +1568,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(current_fh, close->cl_seqid, 
 					&close->cl_stateid, 
-					CHECK_FH, 
+					CHECK_FH | OPEN_STATE, 
 					&close->cl_stateowner, &stp)))
 		goto out; 
 	/*
@@ -1588,13 +1578,374 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	update_stateid(&stp->st_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
 
-	/* release_open_state() calls nfsd_close() if needed */
-	release_open_state(stp,close);
+	/* release_state_owner() calls nfsd_close() if needed */
+	release_state_owner(stp, &close->cl_stateowner, OPEN_STATE);
+out:
+	nfs4_unlock_state();
+	return status;
+}
+
+/* 
+ * Lock owner state (byte-range locks)
+ */
+#define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
+#define LOCK_HASH_BITS              8
+#define LOCK_HASH_SIZE             (1 << LOCK_HASH_BITS)
+#define LOCK_HASH_MASK             (LOCK_HASH_SIZE - 1)
+
+#define lockownerid_hashval(id) \
+        ((id) & LOCK_HASH_MASK)
+#define lock_ownerstr_hashval(x, clientid, ownername) \
+        ((file_hashval(x) + (clientid) + opaque_hashval((ownername.data), (ownername.len))) & LOCK_HASH_MASK)
+
+static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
+static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
+static struct list_head lockstateid_hashtbl[STATEID_HASH_SIZE];
+
+struct nfs4_stateid *
+find_stateid(stateid_t *stid, int flags)
+{
+	struct list_head *pos, *next;
+	struct nfs4_stateid *local = NULL;
+	u32 st_id = stid->si_stateownerid;
+	u32 f_id = stid->si_fileid;
+	unsigned int hashval;
+
+	dprintk("NFSD: find_stateid flags 0x%x\n",flags);
+	if ((flags & LOCK_STATE) || (flags & RDWR_STATE)) {
+		hashval = stateid_hashval(st_id, f_id);
+		list_for_each_safe(pos, next, &lockstateid_hashtbl[hashval]) {
+			local = list_entry(pos, struct nfs4_stateid, st_hash);
+			if((local->st_stateid.si_stateownerid == st_id) &&
+			   (local->st_stateid.si_fileid == f_id))
+				return local;
+		}
+	} 
+	if ((flags & OPEN_STATE) || (flags & RDWR_STATE)) {
+		hashval = stateid_hashval(st_id, f_id);
+		list_for_each_safe(pos, next, &stateid_hashtbl[hashval]) {
+			local = list_entry(pos, struct nfs4_stateid, st_hash);
+			if((local->st_stateid.si_stateownerid == st_id) &&
+			   (local->st_stateid.si_fileid == f_id))
+				return local;
+		}
+	} else
+		printk("NFSD: find_stateid: ERROR: no state flag\n");
+	return NULL;
+}
+
+
+/*
+ * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
+ * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
+ * byte, because of sign extension problems.  Since NFSv4 calls for 64-bit
+ * locking, this prevents us from being completely protocol-compliant.  The
+ * real solution to this problem is to start using unsigned file offsets in
+ * the VFS, but this is a very deep change!
+ */
+static inline void
+nfs4_transform_lock_offset(struct file_lock *lock)
+{
+	if (lock->fl_start < 0)
+		lock->fl_start = OFFSET_MAX;
+	if (lock->fl_end < 0)
+		lock->fl_end = OFFSET_MAX;
+}
+
+int
+nfs4_verify_lock_stateowner(struct nfs4_stateowner *sop, unsigned int hashval)
+{
+	struct list_head *pos, *next;
+	struct nfs4_stateowner *local = NULL;
+	int status = 0;
+			        
+	if (hashval >= LOCK_HASH_SIZE)
+		goto out;
+	list_for_each_safe(pos, next, &lock_ownerid_hashtbl[hashval]) {
+		local = list_entry(pos, struct nfs4_stateowner, so_idhash);
+		if (local == sop) {
+			status = 1;
+			goto out;
+		}
+	}
+out:
+	return status;
+}
+
+
+static inline void
+nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
+{
+	struct nfs4_stateowner *sop = (struct nfs4_stateowner *) fl->fl_owner;
+
+	deny->ld_sop = NULL;
+	if (nfs4_verify_lock_stateowner(sop, fl->fl_pid))
+		deny->ld_sop = sop;
+	deny->ld_start = fl->fl_start;
+	deny->ld_length = ~(u64)0;
+	if (fl->fl_end != ~(u64)0)
+		deny->ld_length = fl->fl_end - fl->fl_start + 1;        
+	deny->ld_type = NFS4_READ_LT;
+	if (fl->fl_type != F_RDLCK)
+		deny->ld_type = NFS4_WRITE_LT;
+}
+
+
+static int
+find_lockstateowner_str(unsigned int hashval, struct xdr_netobj *owner, clientid_t *clid, struct nfs4_stateowner **op) {
+	struct list_head *pos, *next;
+	struct nfs4_stateowner *local = NULL;
+
+	list_for_each_safe(pos, next, &lock_ownerstr_hashtbl[hashval]) {
+		local = list_entry(pos, struct nfs4_stateowner, so_strhash);
+		if(!cmp_owner_str(local, owner, clid)) 
+			continue;
+		*op = local;
+		return(1);
+	}
+	*op = NULL;
+	return 0;
+}
+
+/*
+ * Alloc a lock owner structure.
+ * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
+ * occured. 
+ *
+ * strhashval = lock_ownerstr_hashval 
+ * so_seqid = lock->lk_new_lock_seqid - 1: it gets bumped in encode 
+ */
+
+static struct nfs4_stateowner *
+alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_lock *lock) {
+	struct nfs4_stateowner *sop;
+	struct nfs4_replay *rp;
+	unsigned int idhashval;
+
+	if (!(sop = alloc_stateowner(&lock->lk_new_owner)))
+		return (struct nfs4_stateowner *)NULL;
+	idhashval = lockownerid_hashval(current_ownerid);
+	INIT_LIST_HEAD(&sop->so_idhash);
+	INIT_LIST_HEAD(&sop->so_strhash);
+	INIT_LIST_HEAD(&sop->so_perclient);
+	INIT_LIST_HEAD(&sop->so_perfilestate);
+	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
+	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
+	list_add(&sop->so_perclient, &clp->cl_perclient);
+	add_perclient++;
+	sop->so_is_open_owner = 0;
+	sop->so_id = current_ownerid++;
+	sop->so_client = clp;
+	sop->so_seqid = lock->lk_new_lock_seqid - 1;
+	sop->so_confirmed = 1;
+	rp = &sop->so_replay;
+	rp->rp_status = NFSERR_SERVERFAULT;
+	rp->rp_buflen = 0;
+	rp->rp_buf = rp->rp_ibuf;
+	alloc_lsowner++;
+	return sop;
+}
+
+struct nfs4_stateid *
+alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struct nfs4_stateid *open_stp)
+{
+	struct nfs4_stateid *stp;
+	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
+
+	if ((stp = kmalloc(sizeof(struct nfs4_stateid), 
+					GFP_KERNEL)) == NULL)
+		goto out;
+
+	INIT_LIST_HEAD(&stp->st_hash);
+	INIT_LIST_HEAD(&stp->st_perfile);
+	INIT_LIST_HEAD(&stp->st_perfilestate);
+	list_add(&stp->st_hash, &lockstateid_hashtbl[hashval]);
+	list_add(&stp->st_perfile, &fp->fi_perfile);
+	list_add_perfile++;
+	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
+	stp->st_stateowner = sop;
+	stp->st_file = fp;
+	stp->st_stateid.si_boot = boot_time;
+	stp->st_stateid.si_stateownerid = sop->so_id;
+	stp->st_stateid.si_fileid = fp->fi_id;
+	stp->st_stateid.si_generation = 0;
+	stp->st_vfs_file = open_stp->st_vfs_file;
+	stp->st_vfs_set = open_stp->st_vfs_set;
+	stp->st_share_access = -1; 
+	stp->st_share_deny = -1;
+
+out:
+	return stp;
+}
+
+/*
+ *  LOCK operation 
+ */
+int
+nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock)
+{
+	struct nfs4_stateowner *lock_sop = NULL, *open_sop = NULL;
+	struct nfs4_stateid *lock_stp;
+	struct file *filp;
+	struct file_lock file_lock;
+	struct file_lock *conflock;
+	int status = 0;
+	unsigned int strhashval;
+
+	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
+		lock->lk_offset, lock->lk_length);
+
+	lock->lk_stateowner = NULL;
+	nfs4_lock_state();
+
+	if (lock->lk_is_new) {
+	/*
+	 * Client indicates that this is a new lockowner.
+	 * Use open owner and open stateid to create lock owner and lock 
+	 * stateid.
+	 */
+		struct nfs4_stateid *open_stp = NULL;
+		struct nfs4_file *fp;
+		
+		status = nfserr_stale_clientid;
+		if (STALE_CLIENTID(&lock->lk_new_clientid)) {
+			printk("NFSD: nfsd4_lock: clientid is stale!\n");
+			goto out;
+		}
+		/* validate and update open stateid and open seqid */
+		status = nfs4_preprocess_seqid_op(current_fh, 
+				        lock->lk_new_open_seqid,
+		                        &lock->lk_new_open_stateid,
+		                        CHECK_FH | OPEN_STATE,
+		                        &open_sop, &open_stp);
+		if (status)
+			goto out;
+		/* create lockowner and lock stateid */
+		fp = open_stp->st_file;
+		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
+				open_sop->so_client->cl_clientid.cl_id, 
+				lock->v.new.owner);
+
+		/* 
+		 * If we already have this lock owner, the client is in 
+		 * error (or our bookeeping is wrong!) 
+		 * for asking for a 'new lock'.
+		 */
+		status = nfserr_bad_stateid;
+		if (find_lockstateowner_str(strhashval, &lock->v.new.owner,
+					&lock->v.new.clientid, &lock_sop))
+			goto out;
+		status = nfserr_resource;
+		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, 
+						open_sop->so_client, lock)))
+			goto out;
+		if ((lock_stp = alloc_init_lock_stateid(lock->lk_stateowner, 
+						fp, open_stp)) == NULL)
+			goto out;
+		/* bump the open seqid used to create the lock */
+		open_sop->so_seqid++;
+	} else {
+		/* lock (lock owner + lock stateid) already exists */
+		status = nfs4_preprocess_seqid_op(current_fh,
+				       lock->lk_old_lock_seqid, 
+				       &lock->lk_old_lock_stateid, 
+				       CHECK_FH | LOCK_STATE, 
+				       &lock->lk_stateowner, &lock_stp);
+		if (status)
+			goto out;
+	}
+	/* lock->lk_stateowner and lock_stp have been created or found */
+	filp = &lock_stp->st_vfs_file;
+
+	if ((status = fh_verify(rqstp, current_fh, S_IFREG, MAY_LOCK))) {
+		printk("NFSD: nfsd4_lock: permission denied!\n");
+		goto out;
+	}
+
+	switch (lock->lk_type) {
+		case NFS4_READ_LT:
+		case NFS4_READW_LT:
+			file_lock.fl_type = F_RDLCK;
+		break;
+		case NFS4_WRITE_LT:
+		case NFS4_WRITEW_LT:
+			file_lock.fl_type = F_WRLCK;
+		break;
+		default:
+			status = nfserr_inval;
+		goto out;
+	}
+	file_lock.fl_owner = (fl_owner_t) lock->lk_stateowner;
+	file_lock.fl_pid = lockownerid_hashval(lock->lk_stateowner->so_id);
+	file_lock.fl_file = filp;
+	file_lock.fl_flags = FL_POSIX;
+	file_lock.fl_notify = NULL;
+	file_lock.fl_insert = NULL;
+	file_lock.fl_remove = NULL;
+
+	file_lock.fl_start = lock->lk_offset;
+	if ((lock->lk_length == ~(u64)0) || 
+			LOFF_OVERFLOW(lock->lk_offset, lock->lk_length))
+		file_lock.fl_end = ~(u64)0;
+	else
+		file_lock.fl_end = lock->lk_offset + lock->lk_length - 1;
+	nfs4_transform_lock_offset(&file_lock);
+
+	/*
+	* Try to lock the file in the VFS.
+	* Note: locks.c uses the BKL to protect the inode's lock list.
+	*/
+
+	status = posix_lock_file(filp, &file_lock);
+	dprintk("NFSD: nfsd4_lock: posix_test_lock passed. posix_lock_file status %d\n",status);
+	switch (-status) {
+	case 0: /* success! */
+		update_stateid(&lock_stp->st_stateid);
+		memcpy(&lock->lk_resp_stateid, &lock_stp->st_stateid, 
+				sizeof(stateid_t));
+		goto out;
+	case (EAGAIN):
+		goto conflicting_lock;
+	case (EDEADLK):
+		status = nfserr_deadlock;
+	default:        
+		dprintk("NFSD: nfsd4_lock: posix_lock_file() failed! status %d\n",status);
+		goto out_destroy_new_stateid;
+	}
+
+conflicting_lock:
+	dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
+	status = nfserr_denied;
+	/* XXX There is a race here. Future patch needed to provide 
+	 * an atomic posix_lock_and_test_file
+	 */
+	if (!(conflock = posix_test_lock(filp, &file_lock))) {
+		status = nfserr_serverfault;
+		goto out;
+	}
+	nfs4_set_lock_denied(conflock, &lock->lk_denied);
+
+out_destroy_new_stateid:
+	if (lock->lk_is_new) {
+		dprintk("NFSD: nfsd4_lock: destroy new stateid!\n");
+	/*
+	* An error encountered after instantiation of the new
+	* stateid has forced us to destroy it.
+	*/
+		if (!seqid_mutating_err(status))
+			open_sop->so_seqid--;
+
+		release_state_owner(lock_stp, &lock->lk_stateowner, LOCK_STATE);
+	}
 out:
 	nfs4_unlock_state();
 	return status;
 }
 
+/* 
+ * Start and stop routines
+ */
+
 void 
 nfs4_state_init(void)
 {
@@ -1617,6 +1968,11 @@ nfs4_state_init(void)
 	}
 	for (i = 0; i < STATEID_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&stateid_hashtbl[i]);
+		INIT_LIST_HEAD(&lockstateid_hashtbl[i]);
+	}
+	for (i = 0; i < LOCK_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&lock_ownerid_hashtbl[i]);
+		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
 	memset(&zerostateid, 0, sizeof(stateid_t));
 	memset(&onestateid, ~0, sizeof(stateid_t));
@@ -1656,8 +2012,8 @@ __nfs4_state_shutdown(void)
 			add_perclient, del_perclient);
 	dprintk("NFSD: alloc_file %d free_file %d\n",
 			alloc_file, free_file);
-	dprintk("NFSD: alloc_sowner %d free_sowner %d\n",
-			alloc_sowner, free_sowner);
+	dprintk("NFSD: alloc_sowner %d alloc_lsowner %d free_sowner %d\n",
+			alloc_sowner, alloc_lsowner, free_sowner);
 	dprintk("NFSD: vfsopen %d vfsclose %d\n",
 			vfsopen, vfsclose);
 }

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-09-23 09:11:39.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-09-23 09:11:47.000000000 +1000
@@ -568,6 +568,44 @@ nfsd4_decode_link(struct nfsd4_compounda
 }
 
 static int
+nfsd4_decode_lock(struct nfsd4_compoundargs *argp, struct nfsd4_lock *lock)
+{
+	DECODE_HEAD;
+
+	/*
+	* type, reclaim(boolean), offset, length, new_lock_owner(boolean)
+	*/
+	READ_BUF(28);
+	READ32(lock->lk_type);
+	if ((lock->lk_type < NFS4_READ_LT) || (lock->lk_type > NFS4_WRITEW_LT))
+		goto xdr_error;
+	READ32(lock->lk_reclaim);
+	READ64(lock->lk_offset);
+	READ64(lock->lk_length);
+	READ32(lock->lk_is_new);
+
+	if (lock->lk_is_new) {
+		READ_BUF(36);
+		READ32(lock->lk_new_open_seqid);
+		READ32(lock->lk_new_open_stateid.si_generation);
+
+		COPYMEM(&lock->lk_new_open_stateid.si_opaque, sizeof(stateid_opaque_t));
+		READ32(lock->lk_new_lock_seqid);
+		COPYMEM(&lock->lk_new_clientid, sizeof(clientid_t));
+		READ32(lock->lk_new_owner.len);
+		READ_BUF(lock->lk_new_owner.len);
+		READMEM(lock->lk_new_owner.data, lock->lk_new_owner.len);
+	} else {
+		READ_BUF(20);
+		READ32(lock->lk_old_lock_stateid.si_generation);
+		COPYMEM(&lock->lk_old_lock_stateid.si_opaque, sizeof(stateid_opaque_t));
+		READ32(lock->lk_old_lock_seqid);
+	}
+
+	DECODE_TAIL;
+}
+
+static int
 nfsd4_decode_lookup(struct nfsd4_compoundargs *argp, struct nfsd4_lookup *lookup)
 {
 	DECODE_HEAD;
@@ -989,6 +1027,9 @@ nfsd4_decode_compound(struct nfsd4_compo
 		case OP_LINK:
 			op->status = nfsd4_decode_link(argp, &op->u.link);
 			break;
+		case OP_LOCK:
+			op->status = nfsd4_decode_lock(argp, &op->u.lock);
+			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_decode_lookup(argp, &op->u.lookup);
 			break;
@@ -1709,6 +1750,42 @@ nfsd4_encode_getfh(struct nfsd4_compound
 	}
 }
 
+/*
+* Including all fields other than the name, a LOCK4denied structure requires
+*   8(clientid) + 4(namelen) + 8(offset) + 8(length) + 4(type) = 32 bytes.
+*/
+static void
+nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denied *ld)
+{
+	ENCODE_HEAD;
+
+	RESERVE_SPACE(32 + XDR_LEN(ld->ld_sop->so_owner.len));
+	WRITE64(ld->ld_start);
+	WRITE64(ld->ld_length);
+	WRITE32(ld->ld_type);
+	WRITEMEM(&ld->ld_sop->so_client->cl_clientid, 8);
+	WRITE32(ld->ld_sop->so_owner.len);
+	WRITEMEM(ld->ld_sop->so_owner.data, ld->ld_sop->so_owner.len);
+	ADJUST_ARGS();
+}
+
+static void
+nfsd4_encode_lock(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_lock *lock)
+{
+
+	ENCODE_SEQID_OP_HEAD;
+
+	if (!nfserr) {
+		RESERVE_SPACE(4 + sizeof(stateid_t));
+		WRITE32(lock->lk_resp_stateid.si_generation);
+		WRITEMEM(&lock->lk_resp_stateid.si_opaque, sizeof(stateid_opaque_t));
+		ADJUST_ARGS();
+	} else if (nfserr == nfserr_denied)
+		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
+
+	ENCODE_SEQID_OP_TAIL(lock->lk_stateowner);
+}
+
 static void
 nfsd4_encode_link(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_link *link)
 {
@@ -2119,6 +2196,9 @@ nfsd4_encode_operation(struct nfsd4_comp
 	case OP_LINK:
 		nfsd4_encode_link(resp, op->status, &op->u.link);
 		break;
+	case OP_LOCK:
+		nfsd4_encode_lock(resp, op->status, &op->u.lock);
+		break;
 	case OP_LOOKUP:
 		break;
 	case OP_LOOKUPP:

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2003-09-23 09:08:06.000000000 +1000
+++ ./include/linux/nfs4.h	2003-09-23 09:11:47.000000000 +1000
@@ -134,6 +134,15 @@ enum open_delegation_type4 {
 	NFS4_OPEN_DELEGATE_WRITE = 2
 };
 
+enum lock_type4 {
+	NFS4_UNLOCK_LT = 0,
+	NFS4_READ_LT = 1,
+	NFS4_WRITE_LT = 2,
+	NFS4_READW_LT = 3,
+	NFS4_WRITEW_LT = 4
+};
+
+
 /* Mandatory Attributes */
 #define FATTR4_WORD0_SUPPORTED_ATTRS    (1)
 #define FATTR4_WORD0_TYPE               (1 << 1)

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2003-09-23 09:08:06.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2003-09-23 09:11:47.000000000 +1000
@@ -172,6 +172,8 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_serverfault	__constant_htonl(NFSERR_SERVERFAULT)
 #define	nfserr_badtype		__constant_htonl(NFSERR_BADTYPE)
 #define	nfserr_jukebox		__constant_htonl(NFSERR_JUKEBOX)
+#define	nfserr_denied		__constant_htonl(NFSERR_DENIED)
+#define	nfserr_deadlock		__constant_htonl(NFSERR_DEADLOCK)
 #define nfserr_expired          __constant_htonl(NFSERR_EXPIRED)
 #define	nfserr_bad_cookie	__constant_htonl(NFSERR_BAD_COOKIE)
 #define	nfserr_same		__constant_htonl(NFSERR_SAME)

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-09-23 09:11:42.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-09-23 09:11:47.000000000 +1000
@@ -117,16 +117,24 @@ struct nfs4_replay {
 };
 
 /*
-* nfs4_stateowner can either be an open_owner, or (eventually) a lock_owner
+* nfs4_stateowner can either be an open_owner, or a lock_owner
 *
-*    o so_perfilestate list is used to ensure no dangling nfs4_stateid
-*              reverences when we release a stateowner.
+*    so_idhash:  stateid_hashtbl[] for open owner, lockstateid_hashtbl[]
+*         for lock_owner
+*    so_strhash: ownerstr_hashtbl[] for open_owner, lock_ownerstr_hashtbl[]
+*         for lock_owner
+*    so_perclient: nfs4_client->cl_perclient entry - used when nfs4_client
+*         struct is reaped.
+*    so_perfilestate: heads the list of nfs4_stateid (either open or lock) 
+*         and is used to ensure no dangling nfs4_stateid references when we 
+*         release a stateowner.
 */
 struct nfs4_stateowner {
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
 	struct list_head        so_perfilestate; /* list: nfs4_stateid */
+	int			so_is_open_owner; /* 1=openowner,0=lockowner */
 	u32                     so_id;
 	struct nfs4_client *    so_client;
 	u32                     so_seqid;    
@@ -152,12 +160,18 @@ struct nfs4_file {
 * nfs4_stateid can either be an open stateid or (eventually) a lock stateid
 *
 * (open)nfs4_stateid: one per (open)nfs4_stateowner, nfs4_file
+*
+* 	st_hash: stateid_hashtbl[] entry or lockstateid_hashtbl entry
+* 	st_perfile: file_hashtbl[] entry.
+* 	st_perfile_state: nfs4_stateowner->so_perfilestate
+* 	st_share_access: used only for open stateid
+* 	st_share_deny: used only for open stateid
 */
 
 struct nfs4_stateid {
-	struct list_head              st_hash;
+	struct list_head              st_hash; 
 	struct list_head              st_perfile;
-	struct list_head              st_perfilestate;
+	struct list_head              st_perfilestate; 
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	stateid_t                     st_stateid;
@@ -170,6 +184,9 @@ struct nfs4_stateid {
 /* flags for preprocess_seqid_op() */
 #define CHECK_FH                0x00000001
 #define CONFIRM                 0x00000002
+#define OPEN_STATE              0x00000004
+#define LOCK_STATE              0x00000008
+#define RDWR_STATE              0x00000010
 
 #define seqid_mutating_err(err)                       \
 	(((err) != nfserr_stale_clientid) &&    \

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-09-23 09:11:39.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2003-09-23 09:11:47.000000000 +1000
@@ -40,6 +40,7 @@
 #define _LINUX_NFSD_XDR4_H
 
 #define NFSD4_MAX_TAGLEN	128
+#define XDR_LEN(n)                     (((n) + 3) & ~3)
 
 typedef u32 delegation_zero_t;
 typedef u32 delegation_boot_t;
@@ -111,6 +112,56 @@ struct nfsd4_link {
 	struct nfsd4_change_info  li_cinfo; /* response */
 };
 
+struct nfsd4_lock_denied {
+	struct nfs4_stateowner   *ld_sop;
+	u64             ld_start;
+	u64             ld_length;
+	u32             ld_type;
+};
+
+struct nfsd4_lock {
+	/* request */
+	u32             lk_type;
+	u32             lk_reclaim;         /* boolean */
+	u64             lk_offset;
+	u64             lk_length;
+	u32             lk_is_new;
+	union {
+		struct {
+			u32             open_seqid;
+			stateid_t       open_stateid;
+			u32             lock_seqid;
+			clientid_t      clientid;
+			struct xdr_netobj owner;
+		} new;
+		struct {
+			stateid_t       lock_stateid;
+			u32             lock_seqid;
+		} old;
+	} v;
+
+	/* response */
+	union {
+		struct {
+			stateid_t               stateid;
+		} ok;
+		struct nfsd4_lock_denied        denied;
+	} u;
+
+	struct nfs4_stateowner *lk_stateowner;
+};
+#define lk_new_open_seqid       v.new.open_seqid
+#define lk_new_open_stateid     v.new.open_stateid
+#define lk_new_lock_seqid       v.new.lock_seqid
+#define lk_new_clientid         v.new.clientid
+#define lk_new_owner            v.new.owner
+#define lk_old_lock_stateid     v.old.lock_stateid
+#define lk_old_lock_seqid       v.old.lock_seqid
+
+#define lk_rflags       u.ok.rflags
+#define lk_resp_stateid u.ok.stateid
+#define lk_denied       u.denied
+
 struct nfsd4_lookup {
 	u32		lo_len;             /* request */
 	char *		lo_name;            /* request */
@@ -266,6 +317,7 @@ struct nfsd4_op {
 		struct nfsd4_getattr		getattr;
 		struct svc_fh *			getfh;
 		struct nfsd4_link		link;
+		struct nfsd4_lock		lock;
 		struct nfsd4_lookup		lookup;
 		struct nfsd4_verify		nverify;
 		struct nfsd4_open		open;
@@ -357,6 +409,8 @@ extern  int nfsd4_close(struct svc_rqst 
 		struct nfsd4_close *close);
 extern int nfsd4_open_downgrade(struct svc_rqst *rqstp, 
 		struct svc_fh *current_fh, struct nfsd4_open_downgrade *od);
+extern int nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
+		struct nfsd4_lock *lock);
 #endif
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
