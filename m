From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 20 of 34 - unlock-on-close fix
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Jc-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xk-Tx
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf2-0002QH-Pw
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:52 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:43 +1100
To: Andrew Morton <akpm@osdl.org>
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


add the bookeeping necessary to remove all locks held by an nfsv4 lockowner
upon CLOSE, or upon state expiration. calls locks_remove_posix().

replace list_del_init() with list_del on nfsv4 state structures that are
being reaped.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c        |   46 +++++++++++++++++++++++++++++++------------
 ./include/linux/nfsd/state.h |    5 ++++
 2 files changed, 39 insertions(+), 12 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:34.000000000 +1100
@@ -771,6 +771,7 @@ alloc_init_open_stateowner(unsigned int 
 	INIT_LIST_HEAD(&sop->so_strhash);
 	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_perfilestate);
+	INIT_LIST_HEAD(&sop->so_perlockowner);  /* not used */
 	list_add(&sop->so_idhash, &ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
@@ -789,13 +790,28 @@ alloc_init_open_stateowner(unsigned int 
 }
 
 static void
+release_stateid_lockowner(struct nfs4_stateid *open_stp)
+{
+	struct nfs4_stateowner *lock_sop;	
+	
+	while (!list_empty(&open_stp->st_perlockowner)) {
+		lock_sop = list_entry(open_stp->st_perlockowner.next,
+				struct nfs4_stateowner, so_perlockowner);
+		/* list_del(&open_stp->st_perlockowner);  */
+		BUG_ON(lock_sop->so_is_open_owner);
+		release_stateowner(lock_sop);
+	}
+}
+
+static void
 release_stateowner(struct nfs4_stateowner *sop)
 {
 	struct nfs4_stateid *stp;
 
-	list_del_init(&sop->so_idhash);
-	list_del_init(&sop->so_strhash);
-	list_del_init(&sop->so_perclient);
+	list_del(&sop->so_idhash);
+	list_del(&sop->so_strhash);
+	list_del(&sop->so_perclient);
+	list_del(&sop->so_perlockowner);
 	del_perclient++;
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
@@ -814,6 +830,7 @@ init_stateid(struct nfs4_stateid *stp, s
 
 	INIT_LIST_HEAD(&stp->st_hash);
 	INIT_LIST_HEAD(&stp->st_perfilestate);
+	INIT_LIST_HEAD(&stp->st_perlockowner);
 	INIT_LIST_HEAD(&stp->st_perfile);
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
@@ -832,17 +849,21 @@ init_stateid(struct nfs4_stateid *stp, s
 static void
 release_stateid(struct nfs4_stateid *stp, int flags) {
 
-	list_del_init(&stp->st_hash);
+	list_del(&stp->st_hash);
 	list_del_perfile++;
-	list_del_init(&stp->st_perfile);
-	list_del_init(&stp->st_perfilestate);
+	list_del(&stp->st_perfile);
+	list_del(&stp->st_perfilestate);
 	if((stp->st_vfs_set) && (flags & OPEN_STATE)) {
+		release_stateid_lockowner(stp);
 		nfsd_close(&stp->st_vfs_file);
 		vfsclose++;
 		dput(stp->st_vfs_file.f_dentry);
 		mntput(stp->st_vfs_file.f_vfsmnt);
+	} else if ((stp->st_vfs_set) && (flags & LOCK_STATE)) {
+		struct file *filp = &stp->st_vfs_file;
+
+		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
 	}
-	/* should use a slab cache */
 	kfree(stp);
 	stp = NULL;
 }
@@ -851,7 +872,7 @@ static void
 release_file(struct nfs4_file *fp)
 {
 	free_file++;
-	list_del_init(&fp->fi_hash);
+	list_del(&fp->fi_hash);
 	iput(fp->fi_inode);
 	kfree(fp);
 }	
@@ -1722,7 +1743,7 @@ find_lockstateowner_str(unsigned int has
  */
 
 static struct nfs4_stateowner *
-alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_lock *lock) {
+alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp, struct nfsd4_lock *lock) {
 	struct nfs4_stateowner *sop;
 	struct nfs4_replay *rp;
 	unsigned int idhashval;
@@ -1734,9 +1755,11 @@ alloc_init_lock_stateowner(unsigned int 
 	INIT_LIST_HEAD(&sop->so_strhash);
 	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_perfilestate);
+	INIT_LIST_HEAD(&sop->so_perlockowner);
 	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
+	list_add(&sop->so_perlockowner, &open_stp->st_perlockowner);
 	add_perclient++;
 	sop->so_is_open_owner = 0;
 	sop->so_id = current_ownerid++;
@@ -1760,10 +1783,10 @@ alloc_init_lock_stateid(struct nfs4_stat
 	if ((stp = kmalloc(sizeof(struct nfs4_stateid), 
 					GFP_KERNEL)) == NULL)
 		goto out;
-
 	INIT_LIST_HEAD(&stp->st_hash);
 	INIT_LIST_HEAD(&stp->st_perfile);
 	INIT_LIST_HEAD(&stp->st_perfilestate);
+	INIT_LIST_HEAD(&stp->st_perlockowner); /* not used */
 	list_add(&stp->st_hash, &lockstateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_perfile);
 	list_add_perfile++;
@@ -1852,8 +1875,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 					&lock->v.new.clientid, &lock_sop))
 			goto out;
 		status = nfserr_resource;
-		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, 
-						open_sop->so_client, lock)))
+		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, open_sop->so_client, open_stp, lock)))
 			goto out;
 		if ((lock_stp = alloc_init_lock_stateid(lock->lk_stateowner, 
 						fp, open_stp)) == NULL)

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-02-24 10:42:34.000000000 +1100
@@ -130,12 +130,15 @@ struct nfs4_replay {
 *    so_perfilestate: heads the list of nfs4_stateid (either open or lock) 
 *         and is used to ensure no dangling nfs4_stateid references when we 
 *         release a stateowner.
+*    so_perlockowner: (open) nfs4_stateid->st_perlockowner entry - used when 
+*         close is called to reap associated byte-range locks
 */
 struct nfs4_stateowner {
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
 	struct list_head        so_perfilestate; /* list: nfs4_stateid */
+	struct list_head        so_perlockowner; /* nfs4_stateid->st_perlockowner */
 	int			so_is_open_owner; /* 1=openowner,0=lockowner */
 	u32                     so_id;
 	struct nfs4_client *    so_client;
@@ -166,6 +169,7 @@ struct nfs4_file {
 * 	st_hash: stateid_hashtbl[] entry or lockstateid_hashtbl entry
 * 	st_perfile: file_hashtbl[] entry.
 * 	st_perfile_state: nfs4_stateowner->so_perfilestate
+*       st_perlockowner: (open stateid) list of lock nfs4_stateowners
 * 	st_share_access: used only for open stateid
 * 	st_share_deny: used only for open stateid
 */
@@ -174,6 +178,7 @@ struct nfs4_stateid {
 	struct list_head              st_hash; 
 	struct list_head              st_perfile;
 	struct list_head              st_perfilestate; 
+	struct list_head              st_perlockowner;
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	stateid_t                     st_stateid;


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
