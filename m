From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 023 of 28] nfsd4: rename state list fields
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006ir-PK@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3V-0005xt-5T
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:21 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3T-0005Oz-MZ
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:21 -0700
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

Already done for struct nfs4_file; go ahead and do it for the other nfsd4 state
structures.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   78 +++++++++++++++++++++----------------------
 ./include/linux/nfsd/state.h |   18 ++++-----
 2 files changed, 48 insertions(+), 48 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:05.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:06.000000000 +1000
@@ -154,8 +154,8 @@ alloc_init_deleg(struct nfs4_client *clp
 	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
 	if (dp == NULL)
 		return dp;
-	INIT_LIST_HEAD(&dp->dl_del_perfile);
-	INIT_LIST_HEAD(&dp->dl_del_perclnt);
+	INIT_LIST_HEAD(&dp->dl_perfile);
+	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
 	dp->dl_client = clp;
 	get_nfs4_file(fp);
@@ -176,8 +176,8 @@ alloc_init_deleg(struct nfs4_client *clp
 		        current_fh->fh_handle.fh_size);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
-	list_add(&dp->dl_del_perfile, &fp->fi_delegations);
-	list_add(&dp->dl_del_perclnt, &clp->cl_del_perclnt);
+	list_add(&dp->dl_perfile, &fp->fi_delegations);
+	list_add(&dp->dl_perclnt, &clp->cl_delegations);
 	return dp;
 }
 
@@ -214,8 +214,8 @@ nfs4_close_delegation(struct nfs4_delega
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_del_perfile);
-	list_del_init(&dp->dl_del_perclnt);
+	list_del_init(&dp->dl_perfile);
+	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&recall_lock);
@@ -345,11 +345,11 @@ expire_client(struct nfs4_client *clp)
 
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
-	while (!list_empty(&clp->cl_del_perclnt)) {
-		dp = list_entry(clp->cl_del_perclnt.next, struct nfs4_delegation, dl_del_perclnt);
+	while (!list_empty(&clp->cl_delegations)) {
+		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
 		dprintk("NFSD: expire client. dp %p, fp %p\n", dp,
 				dp->dl_flock);
-		list_del_init(&dp->dl_del_perclnt);
+		list_del_init(&dp->dl_perclnt);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);
@@ -361,8 +361,8 @@ expire_client(struct nfs4_client *clp)
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
 	list_del(&clp->cl_lru);
-	while (!list_empty(&clp->cl_perclient)) {
-		sop = list_entry(clp->cl_perclient.next, struct nfs4_stateowner, so_perclient);
+	while (!list_empty(&clp->cl_openowners)) {
+		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_stateowner(sop);
 	}
 	put_nfs4_client(clp);
@@ -380,8 +380,8 @@ create_client(struct xdr_netobj name, ch
 	clp->cl_callback.cb_parsed = 0;
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
-	INIT_LIST_HEAD(&clp->cl_perclient);
-	INIT_LIST_HEAD(&clp->cl_del_perclnt);
+	INIT_LIST_HEAD(&clp->cl_openowners);
+	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_lru);
 out:
 	return clp;
@@ -1074,13 +1074,13 @@ alloc_init_open_stateowner(unsigned int 
 	INIT_LIST_HEAD(&sop->so_idhash);
 	INIT_LIST_HEAD(&sop->so_strhash);
 	INIT_LIST_HEAD(&sop->so_perclient);
-	INIT_LIST_HEAD(&sop->so_perfilestate);
-	INIT_LIST_HEAD(&sop->so_perlockowner);  /* not used */
+	INIT_LIST_HEAD(&sop->so_stateids);
+	INIT_LIST_HEAD(&sop->so_perstateid);  /* not used */
 	INIT_LIST_HEAD(&sop->so_close_lru);
 	sop->so_time = 0;
 	list_add(&sop->so_idhash, &ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
-	list_add(&sop->so_perclient, &clp->cl_perclient);
+	list_add(&sop->so_perclient, &clp->cl_openowners);
 	sop->so_is_open_owner = 1;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;
@@ -1098,10 +1098,10 @@ release_stateid_lockowners(struct nfs4_s
 {
 	struct nfs4_stateowner *lock_sop;
 
-	while (!list_empty(&open_stp->st_perlockowner)) {
-		lock_sop = list_entry(open_stp->st_perlockowner.next,
-				struct nfs4_stateowner, so_perlockowner);
-		/* list_del(&open_stp->st_perlockowner);  */
+	while (!list_empty(&open_stp->st_lockowners)) {
+		lock_sop = list_entry(open_stp->st_lockowners.next,
+				struct nfs4_stateowner, so_perstateid);
+		/* list_del(&open_stp->st_lockowners);  */
 		BUG_ON(lock_sop->so_is_open_owner);
 		release_stateowner(lock_sop);
 	}
@@ -1116,10 +1116,10 @@ unhash_stateowner(struct nfs4_stateowner
 	list_del(&sop->so_strhash);
 	if (sop->so_is_open_owner)
 		list_del(&sop->so_perclient);
-	list_del(&sop->so_perlockowner);
-	while (!list_empty(&sop->so_perfilestate)) {
-		stp = list_entry(sop->so_perfilestate.next, 
-			struct nfs4_stateid, st_perfilestate);
+	list_del(&sop->so_perstateid);
+	while (!list_empty(&sop->so_stateids)) {
+		stp = list_entry(sop->so_stateids.next,
+			struct nfs4_stateid, st_perstateowner);
 		if (sop->so_is_open_owner)
 			release_stateid(stp, OPEN_STATE);
 		else
@@ -1141,11 +1141,11 @@ init_stateid(struct nfs4_stateid *stp, s
 	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
 
 	INIT_LIST_HEAD(&stp->st_hash);
-	INIT_LIST_HEAD(&stp->st_perfilestate);
-	INIT_LIST_HEAD(&stp->st_perlockowner);
+	INIT_LIST_HEAD(&stp->st_perstateowner);
+	INIT_LIST_HEAD(&stp->st_lockowners);
 	INIT_LIST_HEAD(&stp->st_perfile);
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
-	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
+	list_add(&stp->st_perstateowner, &sop->so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_stateowner = sop;
 	get_nfs4_file(fp);
@@ -1167,7 +1167,7 @@ release_stateid(struct nfs4_stateid *stp
 
 	list_del(&stp->st_hash);
 	list_del(&stp->st_perfile);
-	list_del(&stp->st_perfilestate);
+	list_del(&stp->st_perstateowner);
 	if (flags & OPEN_STATE) {
 		release_stateid_lockowners(stp);
 		stp->st_vfs_file = NULL;
@@ -1201,7 +1201,7 @@ release_state_owner(struct nfs4_stateid 
 	 * released by the laundromat service after the lease period
 	 * to enable us to handle CLOSE replay
 	 */
-	if (sop->so_confirmed && list_empty(&sop->so_perfilestate))
+	if (sop->so_confirmed && list_empty(&sop->so_stateids))
 		move_to_close_lru(sop);
 }
 
@@ -1548,7 +1548,7 @@ find_delegation_file(struct nfs4_file *f
 {
 	struct nfs4_delegation *dp;
 
-	list_for_each_entry(dp, &fp->fi_delegations, dl_del_perfile) {
+	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
 		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
 			return dp;
 	}
@@ -1892,7 +1892,7 @@ nfsd4_renew(clientid_t *clid)
 	}
 	renew_client(clp);
 	status = nfserr_cb_path_down;
-	if (!list_empty(&clp->cl_del_perclnt)
+	if (!list_empty(&clp->cl_delegations)
 			&& !atomic_read(&clp->cl_callback.cb_set))
 		goto out;
 	status = nfs_ok;
@@ -2634,13 +2634,13 @@ alloc_init_lock_stateowner(unsigned int 
 	INIT_LIST_HEAD(&sop->so_idhash);
 	INIT_LIST_HEAD(&sop->so_strhash);
 	INIT_LIST_HEAD(&sop->so_perclient);
-	INIT_LIST_HEAD(&sop->so_perfilestate);
-	INIT_LIST_HEAD(&sop->so_perlockowner);
+	INIT_LIST_HEAD(&sop->so_stateids);
+	INIT_LIST_HEAD(&sop->so_perstateid);
 	INIT_LIST_HEAD(&sop->so_close_lru); /* not used */
 	sop->so_time = 0;
 	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
-	list_add(&sop->so_perlockowner, &open_stp->st_perlockowner);
+	list_add(&sop->so_perstateid, &open_stp->st_lockowners);
 	sop->so_is_open_owner = 0;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;
@@ -2664,11 +2664,11 @@ alloc_init_lock_stateid(struct nfs4_stat
 		goto out;
 	INIT_LIST_HEAD(&stp->st_hash);
 	INIT_LIST_HEAD(&stp->st_perfile);
-	INIT_LIST_HEAD(&stp->st_perfilestate);
-	INIT_LIST_HEAD(&stp->st_perlockowner); /* not used */
+	INIT_LIST_HEAD(&stp->st_perstateowner);
+	INIT_LIST_HEAD(&stp->st_lockowners); /* not used */
 	list_add(&stp->st_hash, &lockstateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
-	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
+	list_add(&stp->st_perstateowner, &sop->so_stateids);
 	stp->st_stateowner = sop;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
@@ -3081,8 +3081,8 @@ nfsd4_release_lockowner(struct svc_rqst 
 		/* check for any locks held by any stateid
 		 * associated with the (lock) stateowner */
 		status = nfserr_locks_held;
-		list_for_each_entry(stp, &local->so_perfilestate,
-				st_perfilestate) {
+		list_for_each_entry(stp, &local->so_stateids,
+				st_perstateowner) {
 			if (check_for_locks(stp->st_vfs_file, local))
 				goto out;
 		}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-05-31 14:21:03.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-05-31 14:21:06.000000000 +1000
@@ -72,8 +72,8 @@ struct nfs4_cb_recall {
 };
 
 struct nfs4_delegation {
-	struct list_head	dl_del_perfile; /* nfs4_file->fi_del_perfile */
-	struct list_head	dl_del_perclnt; /* nfs4_client->cl_del_perclnt*/
+	struct list_head	dl_perfile;
+	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
 	atomic_t		dl_count;       /* ref count */
 	struct nfs4_client	*dl_client;
@@ -119,8 +119,8 @@ struct nfs4_callback {
 struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
 	struct list_head	cl_strhash; 	/* hash by cl_name */
-	struct list_head	cl_perclient; 	/* list: stateowners */
-	struct list_head	cl_del_perclnt; /* list: delegations */
+	struct list_head	cl_openowners;
+	struct list_head	cl_delegations;
 	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
 	char                    cl_recdir[HEXDIR_LEN]; /* recovery dir */
@@ -195,9 +195,9 @@ struct nfs4_stateowner {
 	struct kref		so_ref;
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
-	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
-	struct list_head        so_perfilestate; /* list: nfs4_stateid */
-	struct list_head        so_perlockowner; /* nfs4_stateid->st_perlockowner */
+	struct list_head        so_perclient;
+	struct list_head        so_stateids;
+	struct list_head        so_perstateid; /* for lockowners only */
 	struct list_head	so_close_lru; /* tail queue */
 	time_t			so_time; /* time of placement on so_close_lru */
 	int			so_is_open_owner; /* 1=openowner,0=lockowner */
@@ -240,8 +240,8 @@ struct nfs4_file {
 struct nfs4_stateid {
 	struct list_head              st_hash; 
 	struct list_head              st_perfile;
-	struct list_head              st_perfilestate; 
-	struct list_head              st_perlockowner;
+	struct list_head              st_perstateowner;
+	struct list_head              st_lockowners;
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	stateid_t                     st_stateid;


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
