From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 28 of 54] nfsd4: simplify find functions
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018b-6q@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrs-000289-7w
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrr-0005DE-5n
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
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



Fix "find" functions that use return value redundantly.  Calculate hashes on
demand.  Miscellaneous kernel style.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   83 +++++++++++++++++++++++++-------------------------
 1 files changed, 43 insertions(+), 40 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:58.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:59.000000000 +1100
@@ -968,8 +968,11 @@ static struct list_head stateid_hashtbl[
 
 /* OPEN Share state helper functions */
 static inline struct nfs4_file *
-alloc_init_file(unsigned int hashval, struct inode *ino) {
+alloc_init_file(struct inode *ino)
+{
 	struct nfs4_file *fp;
+	unsigned int hashval = file_hashval(ino);
+
 	if ((fp = kmalloc(sizeof(struct nfs4_file),GFP_KERNEL))) {
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_perfile);
@@ -1246,17 +1249,17 @@ find_openstateowner_str(unsigned int has
 }
 
 /* search file_hashtbl[] for file */
-static int
-find_file(unsigned int hashval, struct inode *ino, struct nfs4_file **fp) {
-	struct nfs4_file *local = NULL;
+static struct nfs4_file *
+find_file(struct inode *ino)
+{
+	unsigned int hashval = file_hashval(ino);
+	struct nfs4_file *fp;
 
-	list_for_each_entry(local, &file_hashtbl[hashval], fi_hash) {
-		if (local->fi_inode == ino) {
-			*fp = local;
-			return(1);
-		}
+	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
+		if (fp->fi_inode == ino)
+			return fp;
 	}
-	return 0;
+	return NULL;
 }
 
 #define TEST_ACCESS(x) ((x > 0 || x < 4)?1:0)
@@ -1303,14 +1306,13 @@ int
 nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
 	struct inode *ino = current_fh->fh_dentry->d_inode;
-	unsigned int fi_hashval;
 	struct nfs4_file *fp;
 	struct nfs4_stateid *stp;
 
 	dprintk("NFSD: nfs4_share_conflict\n");
 
-	fi_hashval = file_hashval(ino);
-	if (find_file(fi_hashval, ino, &fp)) {
+	fp = find_file(ino);
+	if (fp) {
 	/* Search for conflicting share reservations */
 		list_for_each_entry(stp, &fp->fi_perfile, st_perfile) {
 			if (test_bit(deny_type, &stp->st_deny_bmap) ||
@@ -1706,7 +1708,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_stateowner *sop = open->op_stateowner;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
-	unsigned int fi_hashval;
 	struct nfs4_stateid *stp = NULL;
 	int status, delegflag = -1;
 
@@ -1718,15 +1719,16 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	 * and check for delegations in the process of being recalled.
 	 * If not found, create the nfs4_file struct
 	 */
-	fi_hashval = file_hashval(ino);
-	if (find_file(fi_hashval, ino, &fp)) {
+	fp = find_file(ino);
+	if (fp) {
 		if ((status = nfs4_check_open(fp, sop, open, &stp)))
 			goto out;
 		if ((status = nfs4_check_deleg_recall(fp, open, &delegflag)))
 			goto out;
 	} else {
 		status = nfserr_resource;
-		if ((fp = alloc_init_file(fi_hashval, ino)) == NULL)
+		fp = alloc_init_file(ino);
+		if (fp == NULL)
 			goto out;
 	}
 
@@ -2391,8 +2393,15 @@ out:
 
 #define lockownerid_hashval(id) \
         ((id) & LOCK_HASH_MASK)
-#define lock_ownerstr_hashval(x, clientid, ownername) \
-        ((file_hashval(x) + (clientid) + opaque_hashval((ownername.data), (ownername.len))) & LOCK_HASH_MASK)
+
+static inline unsigned int
+lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
+		struct xdr_netobj *ownername)
+{
+	return (file_hashval(inode) + cl_id
+			+ opaque_hashval(ownername->data, ownername->len))
+		& LOCK_HASH_MASK;
+}
 
 static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
@@ -2433,15 +2442,14 @@ find_delegation_stateid(struct inode *in
 	struct nfs4_delegation *dp = NULL;
 	struct nfs4_file *fp = NULL;
 	u32 st_id;
-	unsigned int fi_hashval;
 
 	dprintk("NFSD:find_delegation_stateid stateid=(%08x/%08x/%08x/%08x)\n",
                     stid->si_boot, stid->si_stateownerid,
                     stid->si_fileid, stid->si_generation);
 
 	st_id = stid->si_stateownerid;
-	fi_hashval = file_hashval(ino);
-	if (find_file(fi_hashval, ino, &fp)) {
+	fp = find_file(ino);
+	if (fp) {
 		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
 			if(dp->dl_stateid.si_stateownerid == st_id) {
 				dprintk("NFSD: find_delegation dp %p\n",dp);
@@ -2525,18 +2533,18 @@ find_lockstateowner(struct xdr_netobj *o
 	return NULL;
 }
 
-static int
-find_lockstateowner_str(unsigned int hashval, struct xdr_netobj *owner, clientid_t *clid, struct nfs4_stateowner **op) {
-	struct nfs4_stateowner *local = NULL;
+static struct nfs4_stateowner *
+find_lockstateowner_str(struct inode *inode, clientid_t *clid,
+		struct xdr_netobj *owner)
+{
+	unsigned int hashval = lock_ownerstr_hashval(inode, clid->cl_id, owner);
+	struct nfs4_stateowner *op;
 
-	list_for_each_entry(local, &lock_ownerstr_hashtbl[hashval], so_strhash) {
-		if (!cmp_owner_str(local, owner, clid))
-			continue;
-		*op = local;
-		return(1);
+	list_for_each_entry(op, &lock_ownerstr_hashtbl[hashval], so_strhash) {
+		if (cmp_owner_str(op, owner, clid))
+			return op;
 	}
-	*op = NULL;
-	return 0;
+	return NULL;
 }
 
 /*
@@ -2684,7 +2692,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		fp = open_stp->st_file;
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
 				open_sop->so_client->cl_clientid.cl_id, 
-				lock->v.new.owner);
+				&lock->v.new.owner);
 		/* 
 		 * If we already have this lock owner, the client is in 
 		 * error (or our bookeeping is wrong!) 
@@ -2816,7 +2824,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	struct file file;
 	struct file_lock file_lock;
 	struct file_lock *conflicting_lock;
-	unsigned int strhashval;
 	int status;
 
 	if (nfs4_in_grace())
@@ -2858,12 +2865,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 		goto out;
 	}
 
-	strhashval = lock_ownerstr_hashval(inode, 
-			lockt->lt_clientid.cl_id, lockt->lt_owner);
-
-	find_lockstateowner_str(strhashval, &lockt->lt_owner,
-					&lockt->lt_clientid, 
-					&lockt->lt_stateowner);
+	lockt->lt_stateowner = find_lockstateowner_str(inode,
+			&lockt->lt_clientid, &lockt->lt_owner);
 	if (lockt->lt_stateowner)
 		file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
 	file_lock.fl_pid = current->tgid;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
