From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 012 of 16] nfsd4: slabify stateids
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006e6-Ag@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tu-5Q
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0004DG-Et
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:23 -0700
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



Allocate stateid's from a slab cache.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:45:18.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:45:52.000000000 +1000
@@ -90,6 +90,7 @@ static DECLARE_MUTEX(client_sema);
 
 kmem_cache_t *stateowner_slab = NULL;
 kmem_cache_t *file_slab = NULL;
+kmem_cache_t *stateid_slab = NULL;
 
 void
 nfs4_lock_state(void)
@@ -1010,6 +1011,7 @@ nfsd4_free_slabs(void)
 {
 	nfsd4_free_slab(&stateowner_slab);
 	nfsd4_free_slab(&file_slab);
+	nfsd4_free_slab(&stateid_slab);
 }
 
 static int
@@ -1023,6 +1025,10 @@ nfsd4_init_slabs(void)
 			sizeof(struct nfs4_file), 0, 0, NULL, NULL);
 	if (file_slab == NULL)
 		goto out_nomem;
+	stateid_slab = kmem_cache_create("nfsd4_stateids",
+			sizeof(struct nfs4_stateid), 0, 0, NULL, NULL);
+	if (stateid_slab == NULL)
+		goto out_nomem;
 	return 0;
 out_nomem:
 	nfsd4_free_slabs();
@@ -1173,7 +1179,7 @@ release_stateid(struct nfs4_stateid *stp
 		vfsclose++;
 	} else if (flags & LOCK_STATE)
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
-	kfree(stp);
+	kmem_cache_free(stateid_slab, stp);
 	stp = NULL;
 }
 
@@ -1606,6 +1612,12 @@ out:
 	return status;
 }
 
+static inline struct nfs4_stateid *
+nfs4_alloc_stateid(void)
+{
+	return kmem_cache_alloc(stateid_slab, GFP_KERNEL);
+}
+
 static int
 nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
 		struct nfs4_delegation *dp,
@@ -1613,7 +1625,7 @@ nfs4_new_open(struct svc_rqst *rqstp, st
 {
 	struct nfs4_stateid *stp;
 
-	stp = kmalloc(sizeof(struct nfs4_stateid), GFP_KERNEL);
+	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
 		return nfserr_resource;
 
@@ -1627,7 +1639,7 @@ nfs4_new_open(struct svc_rqst *rqstp, st
 		if (status) {
 			if (status == nfserr_dropit)
 				status = nfserr_jukebox;
-			kfree(stp);
+			kmem_cache_free(stateid_slab, stp);
 			return status;
 		}
 	}
@@ -2627,8 +2639,8 @@ alloc_init_lock_stateid(struct nfs4_stat
 	struct nfs4_stateid *stp;
 	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
 
-	if ((stp = kmalloc(sizeof(struct nfs4_stateid), 
-					GFP_KERNEL)) == NULL)
+	stp = nfs4_alloc_stateid();
+	if (stp == NULL)
 		goto out;
 	INIT_LIST_HEAD(&stp->st_hash);
 	INIT_LIST_HEAD(&stp->st_perfile);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
