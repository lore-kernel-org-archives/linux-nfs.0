From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 54] nfsd4: remove stateowner debug counters
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00017B-JX@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrl-00026S-GU
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrj-0005C4-OZ
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
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



Get rid of these debug counters.  Since they're no longer necessarily
incremented under state lock, we'd need to convert them to atomic_t to
guarantee them correct.  It doesn't seem worth it.

Also, the debug checks in kmem_cache_destroy() should be sufficient for at
least one of the purposes the debugging counters existed for--we'll get a
dump_stack() if there are still stateowners left when we shut down.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    8 --------
 1 files changed, 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:09.000000000 +1100
@@ -72,11 +72,8 @@ u32 add_perclient = 0;
 u32 del_perclient = 0;
 u32 alloc_file = 0;
 u32 free_file = 0;
-u32 alloc_sowner = 0;
-u32 free_sowner = 0;
 u32 vfsopen = 0;
 u32 vfsclose = 0;
-u32 alloc_lsowner= 0;
 u32 alloc_delegation= 0;
 u32 free_delegation= 0;
 
@@ -1017,7 +1014,6 @@ nfs4_free_stateowner(struct kref *kref)
 		container_of(kref, struct nfs4_stateowner, so_ref);
 	kfree(sop->so_owner.data);
 	kmem_cache_free(stateowner_slab, sop);
-	free_sowner++;
 }
 
 static inline struct nfs4_stateowner *
@@ -1066,7 +1062,6 @@ alloc_init_open_stateowner(unsigned int 
 	rp->rp_status = NFSERR_SERVERFAULT;
 	rp->rp_buflen = 0;
 	rp->rp_buf = rp->rp_ibuf;
-	alloc_sowner++;
 	return sop;
 }
 
@@ -2589,7 +2584,6 @@ alloc_init_lock_stateowner(unsigned int 
 	rp->rp_status = NFSERR_SERVERFAULT;
 	rp->rp_buflen = 0;
 	rp->rp_buf = rp->rp_ibuf;
-	alloc_lsowner++;
 	return sop;
 }
 
@@ -3274,8 +3268,6 @@ __nfs4_state_shutdown(void)
 			add_perclient, del_perclient);
 	dprintk("NFSD: alloc_file %d free_file %d\n",
 			alloc_file, free_file);
-	dprintk("NFSD: alloc_sowner %d alloc_lsowner %d free_sowner %d\n",
-			alloc_sowner, alloc_lsowner, free_sowner);
 	dprintk("NFSD: vfsopen %d vfsclose %d\n",
 			vfsopen, vfsclose);
 	dprintk("NFSD: alloc_delegation %d free_delegation %d\n",


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
