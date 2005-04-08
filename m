From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 015 of 16] nfsd4: rename nfs4_file fields
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006eI-Gn@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikP-0006Ui-9e
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:25 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikO-0004E4-Eo
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:25 -0700
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


Trivial renaming patch:

I can never remember, while looking at various lists relating the nfsd4 state
structures, which are the "heads" and which are items on other lists, or which
structures are actually on the various lists.  The following convention helps
me: given structures foo and bar, with foo containing the head of a list of
bars, use "bars" for the name of the head of the list contained in the struct
foo, and use "per_foo" for the entries in the struct bars.

Go ahead and do this for struct nfs4_file.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   22 +++++++++++-----------
 ./include/linux/nfsd/state.h |    4 ++--
 2 files changed, 13 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:46:12.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:46:22.000000000 +1000
@@ -153,7 +153,7 @@ alloc_init_deleg(struct nfs4_client *clp
 		        current_fh->fh_handle.fh_size);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
-	list_add(&dp->dl_del_perfile, &fp->fi_del_perfile);
+	list_add(&dp->dl_del_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_del_perclnt, &clp->cl_del_perclnt);
 	return dp;
 }
@@ -954,8 +954,8 @@ alloc_init_file(struct inode *ino)
 	fp = kmem_cache_alloc(file_slab, GFP_KERNEL);
 	if (fp) {
 		INIT_LIST_HEAD(&fp->fi_hash);
-		INIT_LIST_HEAD(&fp->fi_perfile);
-		INIT_LIST_HEAD(&fp->fi_del_perfile);
+		INIT_LIST_HEAD(&fp->fi_stateids);
+		INIT_LIST_HEAD(&fp->fi_delegations);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
@@ -974,7 +974,7 @@ release_all_files(void)
 		while (!list_empty(&file_hashtbl[i])) {
 			fp = list_entry(file_hashtbl[i].next, struct nfs4_file, fi_hash);
 			/* this should never be more than once... */
-			if (!list_empty(&fp->fi_perfile) || !list_empty(&fp->fi_del_perfile)) {
+			if (!list_empty(&fp->fi_stateids) || !list_empty(&fp->fi_delegations)) {
 				printk("ERROR: release_all_files: file %p is open, creating dangling state !!!\n",fp);
 			}
 			release_file(fp);
@@ -1139,7 +1139,7 @@ init_stateid(struct nfs4_stateid *stp, s
 	INIT_LIST_HEAD(&stp->st_perfile);
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
-	list_add(&stp->st_perfile, &fp->fi_perfile);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = sop;
 	stp->st_file = fp;
 	stp->st_stateid.si_boot = boot_time;
@@ -1204,7 +1204,7 @@ release_state_owner(struct nfs4_stateid 
 	if (sop->so_confirmed && list_empty(&sop->so_perfilestate))
 		move_to_close_lru(sop);
 	/* unused nfs4_file's are releseed. XXX slab cache? */
-	if (list_empty(&fp->fi_perfile) && list_empty(&fp->fi_del_perfile)) {
+	if (list_empty(&fp->fi_stateids) && list_empty(&fp->fi_delegations)) {
 		release_file(fp);
 	}
 }
@@ -1294,7 +1294,7 @@ nfs4_share_conflict(struct svc_fh *curre
 	fp = find_file(ino);
 	if (fp) {
 	/* Search for conflicting share reservations */
-		list_for_each_entry(stp, &fp->fi_perfile, st_perfile) {
+		list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
 			if (test_bit(deny_type, &stp->st_deny_bmap) ||
 			    test_bit(NFS4_SHARE_DENY_BOTH, &stp->st_deny_bmap))
 				return nfserr_share_denied;
@@ -1545,7 +1545,7 @@ find_delegation_file(struct nfs4_file *f
 {
 	struct nfs4_delegation *dp;
 
-	list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
+	list_for_each_entry(dp, &fp->fi_delegations, dl_del_perfile) {
 		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
 			return dp;
 	}
@@ -1583,7 +1583,7 @@ nfs4_check_open(struct nfs4_file *fp, st
 	int status = nfserr_share_denied;
 	struct nfs4_stateowner *sop = open->op_stateowner;
 
-	list_for_each_entry(local, &fp->fi_perfile, st_perfile) {
+	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
 			continue;
@@ -1830,7 +1830,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
 out:
 	/* take the opportunity to clean up unused state */
-	if (fp && list_empty(&fp->fi_perfile) && list_empty(&fp->fi_del_perfile))
+	if (fp && list_empty(&fp->fi_stateids) && list_empty(&fp->fi_delegations))
 		release_file(fp);
 
 	/* CLAIM_PREVIOUS has different error returns */
@@ -2633,7 +2633,7 @@ alloc_init_lock_stateid(struct nfs4_stat
 	INIT_LIST_HEAD(&stp->st_perfilestate);
 	INIT_LIST_HEAD(&stp->st_perlockowner); /* not used */
 	list_add(&stp->st_hash, &lockstateid_hashtbl[hashval]);
-	list_add(&stp->st_perfile, &fp->fi_perfile);
+	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
 	stp->st_stateowner = sop;
 	stp->st_file = fp;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-04-08 10:46:22.000000000 +1000
@@ -218,8 +218,8 @@ struct nfs4_stateowner {
 */
 struct nfs4_file {
 	struct list_head        fi_hash;    /* hash by "struct inode *" */
-	struct list_head        fi_perfile; /* list: nfs4_stateid */
-	struct list_head	fi_del_perfile; /* list: nfs4_delegation */
+	struct list_head        fi_stateids;
+	struct list_head	fi_delegations;
 	struct inode		*fi_inode;
 	u32                     fi_id;      /* used with stateowner->so_id 
 					     * for stateid_hashtbl hash */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
