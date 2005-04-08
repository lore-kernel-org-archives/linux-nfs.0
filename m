From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 014 of 16] nfsd4: remove debugging counters
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006eE-Es@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikP-0006UK-4R
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:25 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikO-0004E3-CW
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


These remaining debugging counters haven't proved that useful.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   25 +------------------------
 1 files changed, 1 insertion(+), 24 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:46:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:46:12.000000000 +1000
@@ -65,14 +65,6 @@ static u32 nfs4_init;
 stateid_t zerostateid;             /* bits all 0 */
 stateid_t onestateid;              /* bits all 1 */
 
-/* debug counters */
-u32 list_add_perfile = 0; 
-u32 list_del_perfile = 0;
-u32 add_perclient = 0;
-u32 del_perclient = 0;
-u32 vfsopen = 0;
-u32 vfsclose = 0;
-
 /* forward declarations */
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
@@ -192,7 +184,6 @@ nfs4_close_delegation(struct nfs4_delega
 	if (dp->dl_flock)
 		setlease(filp, F_UNLCK, &dp->dl_flock);
 	nfsd_close(filp);
-	vfsclose++;
 }
 
 /* Called under the state lock. */
@@ -1083,7 +1074,6 @@ alloc_init_open_stateowner(unsigned int 
 	list_add(&sop->so_idhash, &ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&sop->so_perclient, &clp->cl_perclient);
-	add_perclient++;
 	sop->so_is_open_owner = 1;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;
@@ -1117,10 +1107,8 @@ unhash_stateowner(struct nfs4_stateowner
 
 	list_del(&sop->so_idhash);
 	list_del(&sop->so_strhash);
-	if (sop->so_is_open_owner) {
+	if (sop->so_is_open_owner)
 		list_del(&sop->so_perclient);
-		del_perclient++;
-	}
 	list_del(&sop->so_perlockowner);
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
@@ -1151,7 +1139,6 @@ init_stateid(struct nfs4_stateid *stp, s
 	INIT_LIST_HEAD(&stp->st_perfile);
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
-	list_add_perfile++;
 	list_add(&stp->st_perfile, &fp->fi_perfile);
 	stp->st_stateowner = sop;
 	stp->st_file = fp;
@@ -1171,14 +1158,12 @@ release_stateid(struct nfs4_stateid *stp
 	struct file *filp = stp->st_vfs_file;
 
 	list_del(&stp->st_hash);
-	list_del_perfile++;
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perfilestate);
 	if (flags & OPEN_STATE) {
 		release_stateid_lockowners(stp);
 		stp->st_vfs_file = NULL;
 		nfsd_close(filp);
-		vfsclose++;
 	} else if (flags & LOCK_STATE)
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
 	kmem_cache_free(stateid_slab, stp);
@@ -1645,7 +1630,6 @@ nfs4_new_open(struct svc_rqst *rqstp, st
 			return status;
 		}
 	}
-	vfsopen++;
 	*stpp = stp;
 	return 0;
 }
@@ -2650,7 +2634,6 @@ alloc_init_lock_stateid(struct nfs4_stat
 	INIT_LIST_HEAD(&stp->st_perlockowner); /* not used */
 	list_add(&stp->st_hash, &lockstateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_perfile);
-	list_add_perfile++;
 	list_add(&stp->st_perfilestate, &sop->so_perfilestate);
 	stp->st_stateowner = sop;
 	stp->st_file = fp;
@@ -3308,12 +3291,6 @@ __nfs4_state_shutdown(void)
 	cancel_delayed_work(&laundromat_work);
 	flush_scheduled_work();
 	nfs4_init = 0;
-	dprintk("NFSD: list_add_perfile %d list_del_perfile %d\n",
-			list_add_perfile, list_del_perfile);
-	dprintk("NFSD: add_perclient %d del_perclient %d\n",
-			add_perclient, del_perclient);
-	dprintk("NFSD: vfsopen %d vfsclose %d\n",
-			vfsopen, vfsclose);
 }
 
 void


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
