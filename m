From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 9 - NFSv4 open share state patch
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-00062A-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1g-0000vc-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:10 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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
	

this open share state patch creates all the structures and hash tables needed 
to create and destroy share state on OPEN.

a struct nfs4_stateowner is introduced. this is currently only used for share 
state, but will also be used as an anchor for byte-range lock state. e.g. it 
will be either an (open)stateowner or a (lock)stateower.

a struct nfs4_stateid is introduced with holds stateid info for openfiles per 
(open)stateowner. this struct will also hold byte-range lock info for 
(lock)stateowners.

ownerstr_hashtbl[] holds nfs4_stateowners hashed by the nfs4_open owner and 
clientid, and is used to lookup nfs4_stateowners on OPEN.

a struct nfs4_file is introduced which holds info on open files with state.

file_hashtbl[] holds nfs4_files, and is used to find a file in order to search 
for conflicting share locks on OPEN. delegation info will hang off the 
nf4_file struct.

i moved nfsd4_process_open1() into nfs4state.c, and added nfs4_process_open2() 
there as well

i've left lease management, state reclaim, and the special replay management 
on sequenceid mutating operations like OPEN for subsequent patches.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |   37 ---
 ./fs/nfsd/nfs4state.c        |  472 ++++++++++++++++++++++++++++++++++++++++++-
 ./fs/nfsd/nfsctl.c           |    1 
 ./fs/nfsd/nfssvc.c           |    2 
 ./include/linux/nfs.h        |    9 
 ./include/linux/nfsd/nfsd.h  |    6 
 ./include/linux/nfsd/state.h |   66 ++++++
 ./include/linux/nfsd/xdr4.h  |    4 
 8 files changed, 561 insertions(+), 36 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-05-20 16:34:37.000000000 +1000
@@ -108,45 +108,25 @@ do_open_lookup(struct svc_rqst *rqstp, s
 	return status;
 }
 
-static int
-nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
-{
-	struct iattr iattr;
-	int status;
-
-	if (open->op_truncate) {
-		iattr.ia_valid = ATTR_SIZE;
-		iattr.ia_size = 0;
-		status = nfsd_setattr(rqstp, current_fh, &iattr, 0, (time_t)0);
-		if (status)
-			return status;
-	}
-
-	memset(&open->op_stateid, 0xff, sizeof(stateid_t));
-	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
-	return 0;
-}
-
 static inline int
 nfsd4_open(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
 	int status;
+	dprintk("NFSD: nfsd4_open filename %.*s\n",open->op_fname.len, open->op_fname.data);
 
 	/* This check required by spec. */
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
-	/*
-	 * For now, we have no state, so we may as well implement an
-	 * even stronger check...
-	 */
-	if (open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
-		return nfserr_notsupp;
-
+	/* check seqid for replay. set nfs4_owner */
+	status = nfsd4_process_open1(open);
+	if (status)
+		return status;
 	/*
 	 * This block of code will (1) set CURRENT_FH to the file being opened,
-	 * creating it if necessary, (2) set open->op_cinfo, (3) set open->op_truncate
-	 * if the file is to be truncated after opening, (4) do permission checking.
+	 * creating it if necessary, (2) set open->op_cinfo, 
+	 * (3) set open->op_truncate if the file is to be truncated 
+	 * after opening, (4) do permission checking.
 	 */
 	status = do_open_lookup(rqstp, current_fh, open);
 	if (status)
@@ -160,7 +140,6 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	status = nfsd4_process_open2(rqstp, current_fh, open);
 	if (status)
 		return status;
-
 	/*
 	 * To finish the open response, we just need to set the rflags.
 	 */

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-05-20 16:34:37.000000000 +1000
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
+#include <linux/mount.h>
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
@@ -51,6 +52,14 @@
 /* Globals */
 time_t boot_time;
 static u32 current_clientid = 1;
+static u32 current_ownerid = 0;
+static u32 current_fileid = 0;
+
+/* debug counters */
+u32 list_add_perfile = 0; 
+u32 list_del_perfile = 0;
+u32 add_perclient = 0;
+u32 del_perclient = 0;
 
 /* Locking:
  *
@@ -73,6 +82,14 @@ opaque_hashval(const void *ptr, int nbyt
 	return x;
 }
 
+/* forward declarations */
+static void release_stateowner(struct nfs4_stateowner *sop);
+static void release_stateid(struct nfs4_stateid *stp);
+
+/* 
+ * SETCLIENTID state 
+ */
+
 /* Hash tables for nfs4_clientid state */
 #define CLIENT_HASH_BITS                 4
 #define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
@@ -138,9 +155,15 @@ free_client(struct nfs4_client *clp)
 static void
 expire_client(struct nfs4_client *clp)
 {
+	struct nfs4_stateowner *sop;
+
 	dprintk("NFSD: expire_client\n");
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
+	while (!list_empty(&clp->cl_perclient)) {
+		sop = list_entry(clp->cl_perclient.next, struct nfs4_stateowner, so_perclient);
+		release_stateowner(sop);
+	}
 	free_client(clp);
 }
 
@@ -152,6 +175,7 @@ create_client(struct xdr_netobj name) {
 		goto out;
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
+	INIT_LIST_HEAD(&clp->cl_perclient);
 out:
 	return clp;
 }
@@ -590,7 +614,442 @@ out:
 	return status;
 }
 
-void
+/* 
+ * Open owner state (share locks)
+ */
+
+/* hash tables for nfs4_stateowner */
+#define OWNER_HASH_BITS              8
+#define OWNER_HASH_SIZE             (1 << OWNER_HASH_BITS)
+#define OWNER_HASH_MASK             (OWNER_HASH_SIZE - 1)
+
+#define ownerstr_hashval(clientid, ownername) \
+        (((clientid) + opaque_hashval((ownername.data), (ownername.len))) & OWNER_HASH_MASK)
+
+static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
+
+/* hash table for nfs4_file */
+#define FILE_HASH_BITS                   8
+#define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
+#define FILE_HASH_MASK                  (FILE_HASH_SIZE - 1)
+
+#define file_hashval(x) \
+        ((unsigned int)((x)->dev + (x)->ino + (x)->generation) & FILE_HASH_MASK)
+
+static struct list_head file_hashtbl[FILE_HASH_SIZE];
+
+/* OPEN Share state helper functions */
+static inline struct nfs4_file *
+alloc_init_file(unsigned int hashval, nfs4_ino_desc_t *ino) {
+	struct nfs4_file *fp;
+	if ((fp = kmalloc(sizeof(struct nfs4_file),GFP_KERNEL))) {
+		INIT_LIST_HEAD(&fp->fi_hash);
+		INIT_LIST_HEAD(&fp->fi_perfile);
+		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
+		memcpy(&fp->fi_ino, ino, sizeof(nfs4_ino_desc_t));
+		fp->fi_id = current_fileid++;
+		return fp;
+	}
+	return (struct nfs4_file *)NULL;
+}
+
+static void
+release_all_files(void)
+{
+	int i;
+	struct nfs4_file *fp;
+
+	for (i=0;i<FILE_HASH_SIZE;i++) {
+		while (!list_empty(&file_hashtbl[i])) {
+			fp = list_entry(file_hashtbl[i].next, struct nfs4_file, fi_hash);
+			/* this should never be more than once... */
+			if(!list_empty(&fp->fi_perfile)) {
+				printk("ERROR: release_all_files: file %p is open, creating dangling state !!!\n",fp);
+			}
+			list_del_init(&fp->fi_hash);
+			kfree(fp);
+		}
+	}
+}
+
+static inline struct nfs4_stateowner *
+alloc_stateowner(struct xdr_netobj *owner)
+{
+	struct nfs4_stateowner *sop;
+
+	if ((sop = kmalloc(sizeof(struct nfs4_stateowner),GFP_KERNEL))) {
+		if((sop->so_owner.data = kmalloc(owner->len, GFP_KERNEL))) {
+			memcpy(sop->so_owner.data, owner->data, owner->len);
+			sop->so_owner.len = owner->len;
+			return sop;
+		} 
+		kfree(sop);
+	}
+	return (struct nfs4_stateowner *)NULL;
+}
+
+/* should use a slab cache */
+static void
+free_stateowner(struct nfs4_stateowner *sop) {
+	if(sop) {
+		kfree(sop->so_owner.data);
+		kfree(sop);
+		sop = NULL;
+	}
+}
+
+static struct nfs4_stateowner *
+alloc_init_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
+	struct nfs4_stateowner *sop;
+
+	if (!(sop = alloc_stateowner(&open->op_owner)))
+		return (struct nfs4_stateowner *)NULL;
+	INIT_LIST_HEAD(&sop->so_strhash);
+	INIT_LIST_HEAD(&sop->so_perclient);
+	INIT_LIST_HEAD(&sop->so_peropenstate);
+	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
+	list_add(&sop->so_perclient, &clp->cl_perclient);
+	add_perclient++;
+	sop->so_id = current_ownerid++;
+	sop->so_client = clp;
+	sop->so_seqid = open->op_seqid;
+	/* until open_confirm is coded, pretend it happened! */
+	sop->so_confirmed = 1;
+	return sop;
+}
+
+static void
+release_stateowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_stateid *stp;
+
+	list_del_init(&sop->so_strhash);
+	list_del_init(&sop->so_perclient);
+	del_perclient++;
+	while (!list_empty(&sop->so_peropenstate)) {
+		stp = list_entry(sop->so_peropenstate.next, 
+			struct nfs4_stateid, st_peropenstate);
+		release_stateid(stp);
+	}
+	free_stateowner(sop);
+}
+
+static inline void
+init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open) {
+
+	INIT_LIST_HEAD(&stp->st_peropenstate);
+	INIT_LIST_HEAD(&stp->st_perfile);
+	list_add(&stp->st_peropenstate, &sop->so_peropenstate);
+	list_add_perfile++;
+	list_add(&stp->st_perfile, &fp->fi_perfile);
+	stp->st_stateowner = sop;
+	stp->st_file = fp;
+	stp->st_stateid.si_boot = boot_time;
+	stp->st_stateid.si_stateownerid = sop->so_id;
+	stp->st_stateid.si_fileid = fp->fi_id;
+	stp->st_stateid.si_generation = 0;
+	stp->st_share_access = open->op_share_access;
+	stp->st_share_deny = open->op_share_deny;
+}
+
+static void
+release_stateid(struct nfs4_stateid *stp) {
+
+	list_del_perfile++;
+	list_del_init(&stp->st_perfile);
+	list_del_init(&stp->st_peropenstate);
+	if(stp->st_vfs_set) {
+		nfsd_close(&stp->st_vfs_file);
+		dput(stp->st_vfs_file.f_dentry);
+		mntput(stp->st_vfs_file.f_vfsmnt);
+	}
+	/* should use a slab cache */
+	kfree(stp);
+	stp = NULL;
+}
+
+static int
+cmp_owner_str(struct nfs4_stateowner *sop, struct nfsd4_open *open) {
+	return ((sop->so_owner.len == open->op_owner.len) && 
+	 !memcmp(sop->so_owner.data, open->op_owner.data, sop->so_owner.len) && 
+	  (sop->so_client->cl_clientid.cl_id == open->op_clientid.cl_id));
+}
+
+/* search ownerstr_hashtbl[] for owner */
+static int
+find_stateowner_str(unsigned int hashval, struct nfsd4_open *open, struct nfs4_stateowner **op) {
+	struct list_head *pos, *next;
+	struct nfs4_stateowner *local = NULL;
+
+	list_for_each_safe(pos, next, &ownerstr_hashtbl[hashval]) {
+		local = list_entry(pos, struct nfs4_stateowner, so_strhash);
+		if(!cmp_owner_str(local, open)) 
+			continue;
+		*op = local;
+		return(1);
+	}
+	return 0;
+}
+
+/* see if clientid is in confirmed hash table */
+static int
+verify_clientid(struct nfs4_client **client, clientid_t *clid) {
+
+	struct list_head *pos, *next;
+	struct nfs4_client *clp;
+	unsigned int idhashval = clientid_hashval(clid->cl_id);
+
+	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+		if (!cmp_clid(&clp->cl_clientid, clid))
+			continue;
+		*client = clp;
+		return 1;
+	}
+	*client = NULL;
+	return 0;
+}
+
+/* search file_hashtbl[] for file */
+static int
+find_file(unsigned int hashval, nfs4_ino_desc_t *ino, struct nfs4_file **fp) {
+	struct list_head *pos, *next;
+	struct nfs4_file *local = NULL;
+
+	list_for_each_safe(pos, next, &file_hashtbl[hashval]) {
+		local = list_entry(pos, struct nfs4_file, fi_hash);
+		if(!memcmp(&local->fi_ino, ino, sizeof(nfs4_ino_desc_t))) {
+			*fp = local;
+			return(1);
+		}
+	}
+	return 0;
+}
+
+static int
+test_share(struct nfs4_stateid *stp, struct nfsd4_open *open) {
+	if ((stp->st_share_access & open->op_share_deny) ||
+	    (stp->st_share_deny & open->op_share_access)) {
+		return 0;
+	}
+	return 1;
+}
+
+static inline void
+nfs4_init_ino(nfs4_ino_desc_t *ino, struct svc_fh *fhp)
+{
+	struct inode *inode;
+	if (!fhp->fh_dentry)
+		BUG();
+	inode = fhp->fh_dentry->d_inode;
+	if (!inode)
+		BUG();
+	ino->dev = inode->i_sb->s_dev;
+	ino->ino = inode->i_ino;
+	ino->generation = inode->i_generation;
+}
+
+static inline int
+nfs4_file_upgrade(struct file *filp, unsigned int share_access)
+{
+int status;
+
+	if (share_access & NFS4_SHARE_ACCESS_WRITE) {
+		status = get_write_access(filp->f_dentry->d_inode);
+		if (!status)
+			filp->f_mode = FMODE_WRITE;
+		else
+			return nfserrno(status);
+	}
+	return nfs_ok;
+}
+
+
+/*
+ * nfsd4_process_open1()
+ * 	lookup stateowner.
+ * 		found:
+ * 			check confirmed 
+ * 				confirmed:
+ * 					check seqid
+ * 				not confirmed:
+ * 					delete owner
+ * 					create new owner
+ * 		notfound:
+ * 			verify clientid
+ * 			create new owner
+ */
+int
+nfsd4_process_open1(struct nfsd4_open *open)
+{
+	int status;
+	clientid_t *clientid = &open->op_clientid;
+	struct nfs4_client *clp = NULL;
+	unsigned int strhashval;
+	struct nfs4_stateowner *sop = NULL;
+
+	status = nfserr_inval;
+	if (!check_name(open->op_owner))
+		goto out;
+
+	status = nfserr_stale_clientid;
+	if (STALE_CLIENTID(&open->op_clientid))
+		goto out;
+
+	down(&client_sema); /* XXX need finer grained locking */
+	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
+	if (find_stateowner_str(strhashval, open, &sop)) {
+		open->op_stateowner = sop;
+		if (open->op_seqid == sop->so_seqid){
+			/* XXX retplay: for now, return bad seqid */
+			status = nfserr_bad_seqid;
+			goto out;
+		}
+		if (sop->so_confirmed) {
+			if (open->op_seqid == sop->so_seqid + 1) { 
+				status = nfs_ok;
+				goto renew;
+			} 
+			status = nfserr_bad_seqid;
+			goto out;
+		}
+		/* If we get here, we received and OPEN for an unconfirmed
+		 * nfs4_stateowner. If seqid's are the same then this 
+		 * is a replay.
+		 * If the sequid's are different, then purge the 
+		 * existing nfs4_stateowner, and instantiate a new one.
+		 */
+		clp = sop->so_client;
+		release_stateowner(sop);
+		goto instantiate_new_owner;
+	} 
+	/* nfs4_stateowner not found. 
+	* verify clientid and instantiate new nfs4_stateowner
+	* if verify fails this is presumably the result of the 
+	* client's lease expiring.
+	*
+	* XXX compare clp->cl_addr with rqstp addr? 
+	*/
+	status = nfserr_expired;
+	if (!verify_clientid(&clp, clientid))
+		goto out;
+instantiate_new_owner:
+	status = nfserr_resource;
+	if (!(sop = alloc_init_stateowner(strhashval, clp, open))) 
+		goto out;
+	open->op_stateowner = sop;
+	status = nfs_ok;
+renew:
+	/* XXX implement LRU and state recovery thread 
+	 * renew will place nfs4_client at end of LRU 
+	 */
+out:
+	up(&client_sema); /*XXX need finer grained locking */
+	return status;
+}
+
+int
+nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+{
+	struct iattr iattr;
+	struct nfs4_stateowner *sop = open->op_stateowner;
+	struct nfs4_file *fp;
+	nfs4_ino_desc_t ino;
+	unsigned int fi_hashval;
+	struct list_head *pos, *next;
+	struct nfs4_stateid *stq, *stp = NULL;
+	int status;
+
+
+	status = nfserr_resource;
+	if (!sop)
+		goto out;
+
+	nfs4_init_ino(&ino, current_fh);
+
+	down(&client_sema); /*XXX need finer grained locking */
+	fi_hashval = file_hashval(&ino);
+	if (find_file(fi_hashval, &ino, &fp)) {
+		/* Search for conflicting share reservations */
+		status = nfserr_share_denied;
+		list_for_each_safe(pos, next, &fp->fi_perfile) {
+		stq = list_entry(pos, struct nfs4_stateid, st_perfile);
+			if(stq->st_stateowner == sop) {
+				stp = stq;
+				continue;
+			}
+			if (!test_share(stq,open))	
+				goto out;
+		}
+	} else {
+	/* No nfs4_file found; allocate and init a new one */
+		status = nfserr_resource;
+		if ((fp = alloc_init_file(fi_hashval, &ino)) == NULL)
+			goto out;
+	}
+
+	if (!stp) {
+		int flags = 0;
+
+		status = nfserr_resource;
+		if ((stp = kmalloc(sizeof(struct nfs4_stateid),
+						GFP_KERNEL)) == NULL)
+			goto out;
+
+		if (open->op_share_access && NFS4_SHARE_ACCESS_WRITE)
+			flags = MAY_WRITE;
+		else
+			flags = MAY_READ;
+		if ((status = nfsd_open(rqstp, current_fh,  S_IFREG,
+			                      flags,
+			                      &stp->st_vfs_file)) != 0)
+			goto out_free;
+
+		dget(stp->st_vfs_file.f_dentry);
+		mntget(stp->st_vfs_file.f_vfsmnt);
+
+		init_stateid(stp, fp, sop, open);
+		stp->st_vfs_set = 1;
+	} else {
+		/* This is an upgrade of an existing OPEN. 
+		 * OR the incoming share with the existing 
+		 * nfs4_stateid share */
+		int share_access = open->op_share_access;
+
+		share_access &= ~(stp->st_share_access);
+
+		/* update the struct file */
+		if ((status = nfs4_file_upgrade(&stp->st_vfs_file, share_access)))
+			goto out;
+		stp->st_share_access |= share_access;
+		stp->st_share_deny |= open->op_share_deny;
+		/* bump the stateid */
+		update_stateid(&stp->st_stateid);
+	}
+	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n\n",
+	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
+	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
+
+	if (open->op_truncate) {
+		iattr.ia_valid = ATTR_SIZE;
+		iattr.ia_size = 0;
+		status = nfsd_setattr(rqstp, current_fh, &iattr, 0, (time_t)0);
+		if (status)
+			goto out;
+	}
+	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
+
+	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
+	status = nfs_ok;
+out:
+	up(&client_sema); /*XXX need finer grained locking */
+	return status;
+out_free:
+	kfree(stp);
+	goto out;
+}
+
+void 
 nfs4_state_init(void)
 {
 	struct timespec 	tv;
@@ -602,6 +1061,12 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
 	}
+	for (i = 0; i < FILE_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&file_hashtbl[i]);
+	}
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
+	}
 	init_MUTEX(&client_sema);
 	tv = CURRENT_TIME;
 	boot_time = tv.tv_sec;
@@ -623,6 +1088,11 @@ __nfs4_state_shutdown(void)
 			expire_client(clp);
 		}
 	}
+	release_all_files();
+	dprintk("NFSD: list_add_perfile %d list_del_perfile %d\n",
+			list_add_perfile, list_del_perfile);
+	dprintk("NFSD: add_perclient %d del_perclient %d\n",
+			add_perclient, del_perclient);
 }
 
 void

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2003-05-20 16:34:37.000000000 +1000
@@ -472,7 +472,6 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
-	nfs4_state_shutdown();
 	unregister_filesystem(&nfsd_fs_type);
 }
 

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2003-05-20 16:34:37.000000000 +1000
@@ -132,6 +132,7 @@ nfsd_svc(unsigned short port, int nrserv
 	if (none_left) {
 		nfsd_serv = NULL;
 		nfsd_racache_shutdown();
+		nfs4_state_shutdown();
 	}
  out:
 	unlock_kernel();
@@ -247,6 +248,7 @@ nfsd(struct svc_rqst *rqstp)
 		}
 		nfsd_serv = NULL;
 	        nfsd_racache_shutdown();	/* release read-ahead cache */
+		nfs4_state_shutdown();
 	}
 	list_del(&me.list);
 	nfsdstats.th_cnt --;

diff ./include/linux/nfs.h~current~ ./include/linux/nfs.h
--- ./include/linux/nfs.h~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./include/linux/nfs.h	2003-05-20 16:34:37.000000000 +1000
@@ -85,9 +85,9 @@
 	NFSERR_NOFILEHANDLE = 10020,	/*       v4 */
 	NFSERR_MINOR_VERS_MISMATCH = 10021,   /* v4 */
 	NFSERR_STALE_CLIENTID = 10022,	/*       v4 */
-	NFSERR_STALE_STATEID = 10023,	/*       v4 */
-	NFSERR_OLD_STATEID = 10024,	/*       v4 */
-	NFSERR_BAD_STATEID = 10025,	/*       v4 */
+	NFSERR_STALE_STATEID = 10023,   /*       v4 */
+	NFSERR_OLD_STATEID = 10024,     /*       v4 */
+	NFSERR_BAD_STATEID = 10025,     /*       v4 */  
 	NFSERR_BAD_SEQID = 10026,	/*       v4 */
 	NFSERR_NOT_SAME = 10027,	/*       v4 */
 	NFSERR_LOCK_RANGE = 10028,	/*       v4 */
@@ -99,7 +99,8 @@
 	NFSERR_RECLAIM_BAD = 10034,	/*       v4 */
 	NFSERR_RECLAIM_CONFLICT = 10035,/*       v4 */
 	NFSERR_BAD_XDR = 10036,		/*       v4 */
-	NFSERR_LOCKS_HELD = 10037	/*       v4 */
+	NFSERR_LOCKS_HELD = 10037,	/*       v4 */
+	NFSERR_REPLAY_ME = 10038	/*       v4 */
 };
 
 /* NFSv2 file types - beware, these are not the same in NFSv3 */

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2003-05-20 16:34:37.000000000 +1000
@@ -170,6 +170,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_serverfault	__constant_htonl(NFSERR_SERVERFAULT)
 #define	nfserr_badtype		__constant_htonl(NFSERR_BADTYPE)
 #define	nfserr_jukebox		__constant_htonl(NFSERR_JUKEBOX)
+#define nfserr_expired          __constant_htonl(NFSERR_EXPIRED)
 #define	nfserr_bad_cookie	__constant_htonl(NFSERR_BAD_COOKIE)
 #define	nfserr_same		__constant_htonl(NFSERR_SAME)
 #define	nfserr_clid_inuse	__constant_htonl(NFSERR_CLID_INUSE)
@@ -177,6 +178,11 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_resource		__constant_htonl(NFSERR_RESOURCE)
 #define	nfserr_nofilehandle	__constant_htonl(NFSERR_NOFILEHANDLE)
 #define	nfserr_minor_vers_mismatch	__constant_htonl(NFSERR_MINOR_VERS_MISMATCH)
+#define nfserr_share_denied	__constant_htonl(NFSERR_SHARE_DENIED)
+#define nfserr_stale_stateid	__constant_htonl(NFSERR_STALE_STATEID)
+#define nfserr_old_stateid	__constant_htonl(NFSERR_OLD_STATEID)
+#define nfserr_bad_stateid	__constant_htonl(NFSERR_BAD_STATEID)
+#define nfserr_bad_seqid	__constant_htonl(NFSERR_BAD_SEQID)
 #define	nfserr_symlink		__constant_htonl(NFSERR_SYMLINK)
 #define	nfserr_not_same		__constant_htonl(NFSERR_NOT_SAME)
 #define	nfserr_readdir_nospc	__constant_htonl(NFSERR_READDIR_NOSPC)

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-05-20 16:34:37.000000000 +1000
@@ -65,10 +65,14 @@ typedef struct {
  *
  * 	o Each nfs4_clients is also hashed by name 
  * 	  (the opaque quantity initially sent by the client to identify itself).
+ * 	  
+ *	o cl_perclient list is used to ensure no dangling stateowner references
+ *	  when we expire the nfs4_client
  */
 struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
 	struct list_head	cl_strhash; 	/* hash by cl_name */
+	struct list_head	cl_perclient; 	/* list: stateowners */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
 	u32			cl_addr; 	/* client ipaddress */
@@ -76,4 +80,66 @@ struct nfs4_client {
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
 };
+
+static inline void
+update_stateid(stateid_t *stateid)
+{
+stateid->si_generation++;
+}
+
+
+/*
+* nfs4_stateowner can either be an open_owner, or (eventually) a lock_owner
+*
+*    o so_peropenstate list is used to ensure no dangling nfs4_stateid
+*              reverences when we release a stateowner.
+*/
+struct nfs4_stateowner {
+	struct list_head        so_strhash;   /* hash by op_name */
+	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
+	struct list_head        so_peropenstate; /* list: nfs4_stateid */
+	u32                     so_id;
+	struct nfs4_client *    so_client;
+	u32                     so_seqid;    
+	struct xdr_netobj       so_owner;     /* open owner name */
+	int                     so_confirmed; /* successful OPEN_CONFIRM? */
+};
+
+typedef struct {
+	u32                     dev; /* super_block->s_dev */
+	unsigned long           ino;
+	u32                     generation;
+} nfs4_ino_desc_t;
+
+/*
+*  nfs4_file: a file opened by some number of (open) nfs4_stateowners.
+*    o fi_perfile list is used to search for conflicting 
+*      share_acces, share_deny on the file.
+*/
+struct nfs4_file {
+	struct list_head        fi_hash;    /* hash by nfs4_ino_desc_t fields */
+	struct list_head        fi_perfile; /* list: nfs4_stateid */
+	nfs4_ino_desc_t         fi_ino;
+	u32                     fi_id;      /* used with stateowner->so_id 
+					     * for openstateid_hashtbl hash */
+};
+
+/*
+* nfs4_stateid can either be an open stateid or (eventually) a lock stateid
+*
+* (open)nfs4_stateid: one per (open)nfs4_stateowner, nfs4_file
+*/
+
+struct nfs4_stateid {
+	struct list_head              st_perfile; /* file_hashtbl[]*/
+	struct list_head              st_peropenstate; /* nfs4_stateowner->so_peropenstate */
+	struct nfs4_stateowner      * st_stateowner;
+	struct nfs4_file            * st_file;
+	stateid_t                     st_stateid;
+	struct file                   st_vfs_file;
+	int                           st_vfs_set;
+	unsigned int                  st_share_access;
+	unsigned int                  st_share_deny;
+};
+
 #endif   /* NFSD4_STATE_H */

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-05-20 16:34:36.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2003-05-20 16:34:37.000000000 +1000
@@ -141,6 +141,7 @@ struct nfsd4_open {
 	struct nfsd4_change_info  op_cinfo; /* response */
 	u32		op_rflags;          /* response */
 	int		op_truncate;        /* used during processing */
+	struct nfs4_stateowner *op_stateowner; /* used during processing */
 
 };
 #define op_iattr	u.iattr
@@ -322,7 +323,8 @@ int nfsd4_encode_fattr(struct svc_fh *fh
 		       struct dentry *dentry, u32 *buffer, int *countp, u32 *bmval);
 extern int nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclid);
 extern int nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm);
-
+extern int nfsd4_process_open1(struct nfsd4_open *open);
+extern int nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open);
 #endif
 
 /*


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
