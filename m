From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 7 - nfsdv4 byte range locking - prepatation
Date: Tue, 23 Sep 2003 09:33:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aBA-0004E2-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBZ-0008UL-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:41 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBX-0003hZ-DZ
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:39 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 23 Sep 2003 09:33:31 +1000
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


this first patch renames some structures and functions that can be used for 
byte-range locking as well as for the exiting open share locks, and does some 
cleanup.

-->Andy

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |   16 +++----
 ./fs/nfsd/nfs4state.c        |   94 +++++++++++++++++++++----------------------
 ./include/linux/nfsd/state.h |   16 +++----
 3 files changed, 63 insertions(+), 63 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-09-23 09:11:39.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-09-23 09:11:42.000000000 +1000
@@ -355,7 +355,7 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	nfsd4_lock_state();
+	nfs4_lock_state();
 	status = nfs_ok;
 	/* For stateid -1, we don't check share reservations.  */
 	if (ONE_STATEID(&read->rd_stateid)) {
@@ -388,7 +388,7 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 	}
 	status = nfs_ok;
 out:
-	nfsd4_unlock_state();
+	nfs4_unlock_state();
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = current_fh;
 	return status;
@@ -464,7 +464,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 			return status;
 		}
 
-		nfsd4_lock_state();
+		nfs4_lock_state();
 		if ((status = nfs4_preprocess_stateid_op(current_fh, 
 						&setattr->sa_stateid, 
 						CHECK_FH, &stp))) {
@@ -476,11 +476,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 			dprintk("NFSD: nfsd4_setattr: not opened for write!\n");
 			goto out;
 		}
-		nfsd4_unlock_state();
+		nfs4_unlock_state();
 	}
 	return (nfsd_setattr(rqstp, current_fh, &setattr->sa_iattr, 0, (time_t)0));
 out:
-	nfsd4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -497,7 +497,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	nfsd4_lock_state();
+	nfs4_lock_state();
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
 		dprintk("NFSD: nfsd4_write: zero stateid...\n");
 		if ((status = nfs4_share_conflict(current_fh, NFS4_SHARE_DENY_WRITE))) {
@@ -519,7 +519,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	}
 
 zero_stateid:
-	nfsd4_unlock_state();
+	nfs4_unlock_state();
 	write->wr_bytes_written = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
 	p = (u32 *)write->wr_verifier;
@@ -530,7 +530,7 @@ zero_stateid:
 			  write->wr_vec, write->wr_vlen, write->wr_buflen,
 			  &write->wr_how_written));
 out:
-	nfsd4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-09-23 09:11:39.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-09-23 09:11:42.000000000 +1000
@@ -80,13 +80,13 @@ u32 vfsclose = 0;
 static struct semaphore client_sema;
 
 void
-nfsd4_lock_state(void)
+nfs4_lock_state(void)
 {
 	down(&client_sema);
 }
 
 void
-nfsd4_unlock_state(void)
+nfs4_unlock_state(void)
 {
 	up(&client_sema);
 }
@@ -386,7 +386,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	strhashval = clientstr_hashval(clname.data, clname.len);
 
 	conf = NULL;
-	down(&client_sema);
+	nfs4_lock_state();
 	list_for_each_safe(pos, next, &conf_str_hashtbl[strhashval]) {
 		clp = list_entry(pos, struct nfs4_client, cl_strhash);
 		if (!cmp_name(&clp->cl_name, &clname))
@@ -525,7 +525,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	printk(KERN_INFO "NFSD: this client will not receive delegations\n");
 	status = nfs_ok;
 out:
-	up(&client_sema);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -557,7 +557,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	 */
 
 	idhashval = clientid_hashval(clid->cl_id);
-	down(&client_sema);
+	nfs4_lock_state();
 	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
 		clp = list_entry(pos, struct nfs4_client, cl_idhash);
 		if (!cmp_clid(&clp->cl_clientid, clid))
@@ -657,7 +657,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	goto out;
 out:
 	/* XXX if status == nfs_ok, probe callback path */
-	up(&client_sema);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -683,17 +683,17 @@ static struct list_head	ownerstr_hashtbl
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 #define FILE_HASH_MASK                  (FILE_HASH_SIZE - 1)
 /* hash table for (open)nfs4_stateid */
-#define OPENSTATEID_HASH_BITS              10
-#define OPENSTATEID_HASH_SIZE              (1 << OPENSTATEID_HASH_BITS)
-#define OPENSTATEID_HASH_MASK              (OPENSTATEID_HASH_SIZE - 1)
+#define STATEID_HASH_BITS              10
+#define STATEID_HASH_SIZE              (1 << STATEID_HASH_BITS)
+#define STATEID_HASH_MASK              (STATEID_HASH_SIZE - 1)
 
 #define file_hashval(x) \
         hash_ptr(x, FILE_HASH_BITS)
-#define openstateid_hashval(owner_id, file_id)  \
-        (((owner_id) + (file_id)) & OPENSTATEID_HASH_MASK)
+#define stateid_hashval(owner_id, file_id)  \
+        (((owner_id) + (file_id)) & STATEID_HASH_MASK)
 
 static struct list_head file_hashtbl[FILE_HASH_SIZE];
-static struct list_head openstateid_hashtbl[OPENSTATEID_HASH_SIZE];
+static struct list_head stateid_hashtbl[STATEID_HASH_SIZE];
 
 /* OPEN Share state helper functions */
 static inline struct nfs4_file *
@@ -768,7 +768,7 @@ alloc_init_stateowner(unsigned int strha
 	INIT_LIST_HEAD(&sop->so_idhash);
 	INIT_LIST_HEAD(&sop->so_strhash);
 	INIT_LIST_HEAD(&sop->so_perclient);
-	INIT_LIST_HEAD(&sop->so_peropenstate);
+	INIT_LIST_HEAD(&sop->so_perfilestate);
 	list_add(&sop->so_idhash, &ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
@@ -794,9 +794,9 @@ release_stateowner(struct nfs4_stateowne
 	list_del_init(&sop->so_strhash);
 	list_del_init(&sop->so_perclient);
 	del_perclient++;
-	while (!list_empty(&sop->so_peropenstate)) {
-		stp = list_entry(sop->so_peropenstate.next, 
-			struct nfs4_stateid, st_peropenstate);
+	while (!list_empty(&sop->so_perfilestate)) {
+		stp = list_entry(sop->so_perfilestate.next, 
+			struct nfs4_stateid, st_perfilestate);
 		release_stateid(stp);
 	}
 	free_stateowner(sop);
@@ -804,13 +804,13 @@ release_stateowner(struct nfs4_stateowne
 
 static inline void
 init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open) {
-	unsigned int hashval = openstateid_hashval(sop->so_id, fp->fi_id);
+	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
 
 	INIT_LIST_HEAD(&stp->st_hash);
-	INIT_LIST_HEAD(&stp->st_peropenstate);
+	INIT_LIST_HEAD(&stp->st_perfilestate);
 	INIT_LIST_HEAD(&stp->st_perfile);
-	list_add(&stp->st_hash, &openstateid_hashtbl[hashval]);
-	list_add(&stp->st_peropenstate, &sop->so_peropenstate);
+	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
+	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
 	list_add_perfile++;
 	list_add(&stp->st_perfile, &fp->fi_perfile);
 	stp->st_stateowner = sop;
@@ -829,7 +829,7 @@ release_stateid(struct nfs4_stateid *stp
 	list_del_init(&stp->st_hash);
 	list_del_perfile++;
 	list_del_init(&stp->st_perfile);
-	list_del_init(&stp->st_peropenstate);
+	list_del_init(&stp->st_perfilestate);
 	if(stp->st_vfs_set) {
 		nfsd_close(&stp->st_vfs_file);
 		vfsclose++;
@@ -864,7 +864,7 @@ release_open_state(struct nfs4_stateid *
 	 * released by the laundromat service after the lease period
 	 * to enable us to handle CLOSE replay
 	 */
-	if (sop->so_confirmed && list_empty(&sop->so_peropenstate)) {
+	if (sop->so_confirmed && list_empty(&sop->so_perfilestate)) {
 		release_stateowner(sop);
 		cl->cl_stateowner = NULL;
 	}
@@ -883,7 +883,7 @@ cmp_owner_str(struct nfs4_stateowner *so
 
 /* search ownerstr_hashtbl[] for owner */
 static int
-find_stateowner_str(unsigned int hashval, struct nfsd4_open *open, struct nfs4_stateowner **op) {
+find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open, struct nfs4_stateowner **op) {
 	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 
@@ -1020,9 +1020,9 @@ nfsd4_process_open1(struct nfsd4_open *o
 	if (STALE_CLIENTID(&open->op_clientid))
 		goto out;
 
-	down(&client_sema); /* XXX need finer grained locking */
+	nfs4_lock_state();
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
-	if (find_stateowner_str(strhashval, open, &sop)) {
+	if (find_openstateowner_str(strhashval, open, &sop)) {
 		open->op_stateowner = sop;
 		/* check for replay */
 		if (open->op_seqid == sop->so_seqid){
@@ -1078,7 +1078,7 @@ instantiate_new_owner:
 renew:
 	renew_client(sop->so_client);
 out:
-	up(&client_sema); /*XXX need finer grained locking */
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1100,7 +1100,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 
 	ino = current_fh->fh_dentry->d_inode;
 
-	down(&client_sema); /*XXX need finer grained locking */
+	nfs4_lock_state();
 	fi_hashval = file_hashval(ino);
 	if (find_file(fi_hashval, ino, &fp)) {
 		/* Search for conflicting share reservations */
@@ -1186,7 +1186,7 @@ out:
 	if (!open->op_stateowner->so_confirmed)
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
-	up(&client_sema); /*XXX need finer grained locking */
+	nfs4_unlock_state();
 	return status;
 out_free:
 	kfree(stp);
@@ -1204,7 +1204,7 @@ nfsd4_renew(clientid_t *clid)
 	unsigned int idhashval;
 	int status;
 
-	down(&client_sema);
+	nfs4_lock_state();
 	printk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
 	status = nfserr_stale_clientid;
@@ -1234,7 +1234,7 @@ nfsd4_renew(clientid_t *clid)
 	printk("nfsd4_renew: clientid not found!\n");
 	status = nfserr_expired;
 out:
-	up(&client_sema);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1246,7 +1246,7 @@ nfs4_laundromat(void)
 	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
 	time_t t, return_val = NFSD_LEASE_TIME;
 
-	down(&client_sema);
+	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting, examining clients\n");
 	list_for_each_safe(pos, next, &client_lru) {
@@ -1263,7 +1263,7 @@ nfs4_laundromat(void)
 	}
 	if (return_val < NFSD_LAUNDROMAT_MINTIMEOUT)
 		return_val = NFSD_LAUNDROMAT_MINTIMEOUT;
-	up(&client_sema); 
+	nfs4_unlock_state();
 	return return_val;
 }
 
@@ -1277,7 +1277,7 @@ laundromat_main(void *not_used)
 	schedule_delayed_work(&laundromat_work, t*HZ);
 }
 
-/* search openstateid_hashtbl[] for stateid */
+/* search stateid_hashtbl[] for stateid */
 struct nfs4_stateid *
 find_stateid(stateid_t *stid)
 {
@@ -1285,9 +1285,9 @@ find_stateid(stateid_t *stid)
 	struct nfs4_stateid *local = NULL;
 	u32 st_id = stid->si_stateownerid;
 	u32 f_id = stid->si_fileid;
-	unsigned int hashval = openstateid_hashval(st_id, f_id);
+	unsigned int hashval = stateid_hashval(st_id, f_id);
 
-	list_for_each_safe(pos, next, &openstateid_hashtbl[hashval]) {
+	list_for_each_safe(pos, next, &stateid_hashtbl[hashval]) {
 		local = list_entry(pos, struct nfs4_stateid, st_hash);
 		if((local->st_stateid.si_stateownerid == st_id) &&
 		   (local->st_stateid.si_fileid == f_id))
@@ -1298,7 +1298,7 @@ find_stateid(stateid_t *stid)
 
 /* search ownerid_hashtbl[] for stateid owner (stateid->si_stateownerid) */
 struct nfs4_stateowner *
-find_stateowner_id(u32 st_id) {
+find_openstateowner_id(u32 st_id) {
 	struct list_head *pos, *next;
 	struct nfs4_stateowner *local = NULL;
 	unsigned int hashval = ownerid_hashval(st_id);
@@ -1474,7 +1474,7 @@ no_nfs4_stateid:
 	* starting by trying to look up the stateowner.
 	* If stateowner is not found - stateid is bad.
 	*/
-	if (!(sop = find_stateowner_id(stateid->si_stateownerid))) {
+	if (!(sop = find_openstateowner_id(stateid->si_stateownerid))) {
 		printk("NFSD: preprocess_seqid_op: no stateowner or nfs4_stateid!\n");
 		status = nfserr_bad_stateid;
 		goto out;
@@ -1503,7 +1503,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 	oc->oc_stateowner = NULL;
-	down(&client_sema); /* XXX need finer grained locking */
+	nfs4_lock_state();
 
 	if ((status = nfs4_preprocess_seqid_op(current_fh, oc->oc_seqid,
 					&oc->oc_req_stateid,
@@ -1523,7 +1523,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 		         stp->st_stateid.si_generation);
 	status = nfs_ok;
 out:
-	up(&client_sema);
+	nfs4_unlock_state();
 	return status;
 }
 int
@@ -1536,7 +1536,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
-	down(&client_sema); /* XXX need finer grained locking */
+	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(current_fh, od->od_seqid, 
 					&od->od_stateid, 
 					CHECK_FH, &od->od_stateowner, &stp)))
@@ -1561,7 +1561,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
-	up(&client_sema);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1575,7 +1575,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
-	down(&client_sema); /* XXX need finer grained locking */
+	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(current_fh, close->cl_seqid, 
 					&close->cl_stateid, 
 					CHECK_FH, 
@@ -1591,7 +1591,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	/* release_open_state() calls nfsd_close() if needed */
 	release_open_state(stp,close);
 out:
-	up(&client_sema);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1615,8 +1615,8 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
 		INIT_LIST_HEAD(&ownerid_hashtbl[i]);
 	}
-	for (i = 0; i < OPENSTATEID_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&openstateid_hashtbl[i]);
+	for (i = 0; i < STATEID_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&stateid_hashtbl[i]);
 	}
 	memset(&zerostateid, 0, sizeof(stateid_t));
 	memset(&onestateid, ~0, sizeof(stateid_t));
@@ -1665,7 +1665,7 @@ __nfs4_state_shutdown(void)
 void
 nfs4_state_shutdown(void)
 {
-	down(&client_sema);
+	nfs4_lock_state();
 	__nfs4_state_shutdown();
-	up(&client_sema);
+	nfs4_unlock_state();
 }

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-09-23 09:11:39.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-09-23 09:11:42.000000000 +1000
@@ -119,14 +119,14 @@ struct nfs4_replay {
 /*
 * nfs4_stateowner can either be an open_owner, or (eventually) a lock_owner
 *
-*    o so_peropenstate list is used to ensure no dangling nfs4_stateid
+*    o so_perfilestate list is used to ensure no dangling nfs4_stateid
 *              reverences when we release a stateowner.
 */
 struct nfs4_stateowner {
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
-	struct list_head        so_peropenstate; /* list: nfs4_stateid */
+	struct list_head        so_perfilestate; /* list: nfs4_stateid */
 	u32                     so_id;
 	struct nfs4_client *    so_client;
 	u32                     so_seqid;    
@@ -145,7 +145,7 @@ struct nfs4_file {
 	struct list_head        fi_perfile; /* list: nfs4_stateid */
 	struct inode		*fi_inode;
 	u32                     fi_id;      /* used with stateowner->so_id 
-					     * for openstateid_hashtbl hash */
+					     * for stateid_hashtbl hash */
 };
 
 /*
@@ -155,9 +155,9 @@ struct nfs4_file {
 */
 
 struct nfs4_stateid {
-	struct list_head              st_hash; /* openstateid_hashtbl[]*/
-	struct list_head              st_perfile; /* file_hashtbl[]*/
-	struct list_head              st_peropenstate; /* nfs4_stateowner->so_peropenstate */
+	struct list_head              st_hash;
+	struct list_head              st_perfile;
+	struct list_head              st_perfilestate;
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	stateid_t                     st_stateid;
@@ -183,6 +183,6 @@ extern int nfs4_preprocess_stateid_op(st
 		stateid_t *stateid, int flags, struct nfs4_stateid **stpp);
 extern int nfs4_share_conflict(struct svc_fh *current_fh, 
 		unsigned int deny_type);
-extern void nfsd4_lock_state(void);
-extern void nfsd4_unlock_state(void);
+extern void nfs4_lock_state(void);
+extern void nfs4_unlock_state(void);
 #endif   /* NFSD4_STATE_H */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
