From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 013 of 16] nfsd4: slabify delegations
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006eA-Co@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tz-An
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikM-0000uO-0E
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
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


Allocate delegations from a slab cache.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:45:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:46:03.000000000 +1000
@@ -72,8 +72,6 @@ u32 add_perclient = 0;
 u32 del_perclient = 0;
 u32 vfsopen = 0;
 u32 vfsclose = 0;
-u32 alloc_delegation= 0;
-u32 free_delegation= 0;
 
 /* forward declarations */
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
@@ -91,6 +89,7 @@ static DECLARE_MUTEX(client_sema);
 kmem_cache_t *stateowner_slab = NULL;
 kmem_cache_t *file_slab = NULL;
 kmem_cache_t *stateid_slab = NULL;
+kmem_cache_t *deleg_slab = NULL;
 
 void
 nfs4_lock_state(void)
@@ -138,8 +137,8 @@ alloc_init_deleg(struct nfs4_client *clp
 	struct nfs4_callback *cb = &stp->st_stateowner->so_client->cl_callback;
 
 	dprintk("NFSD alloc_init_deleg\n");
-	if ((dp = kmalloc(sizeof(struct nfs4_delegation),
-		GFP_KERNEL)) == NULL)
+	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
+	if (dp == NULL)
 		return dp;
 	INIT_LIST_HEAD(&dp->dl_del_perfile);
 	INIT_LIST_HEAD(&dp->dl_del_perclnt);
@@ -164,7 +163,6 @@ alloc_init_deleg(struct nfs4_client *clp
 	atomic_set(&dp->dl_count, 1);
 	list_add(&dp->dl_del_perfile, &fp->fi_del_perfile);
 	list_add(&dp->dl_del_perclnt, &clp->cl_del_perclnt);
-	alloc_delegation++;
 	return dp;
 }
 
@@ -173,8 +171,7 @@ nfs4_put_delegation(struct nfs4_delegati
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
 		dprintk("NFSD: freeing dp %p\n",dp);
-		kfree(dp);
-		free_delegation++;
+		kmem_cache_free(deleg_slab, dp);
 	}
 }
 
@@ -1012,6 +1009,7 @@ nfsd4_free_slabs(void)
 	nfsd4_free_slab(&stateowner_slab);
 	nfsd4_free_slab(&file_slab);
 	nfsd4_free_slab(&stateid_slab);
+	nfsd4_free_slab(&deleg_slab);
 }
 
 static int
@@ -1029,6 +1027,10 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfs4_stateid), 0, 0, NULL, NULL);
 	if (stateid_slab == NULL)
 		goto out_nomem;
+	deleg_slab = kmem_cache_create("nfsd4_delegations",
+			sizeof(struct nfs4_delegation), 0, 0, NULL, NULL);
+	if (deleg_slab == NULL)
+		goto out_nomem;
 	return 0;
 out_nomem:
 	nfsd4_free_slabs();
@@ -3312,9 +3314,6 @@ __nfs4_state_shutdown(void)
 			add_perclient, del_perclient);
 	dprintk("NFSD: vfsopen %d vfsclose %d\n",
 			vfsopen, vfsclose);
-	dprintk("NFSD: alloc_delegation %d free_delegation %d\n",
-			alloc_delegation, free_delegation);
-
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
