From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 5 of 54] nfsd4: create a slab cache for stateowners
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-000177-HZ@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrk-00026P-OE
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:48 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrj-0005C5-RE
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:48 -0800
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



Create a slab cache for nfsv4 stateowners.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |   55 ++++++++++++++++++++++++++++++++++++--------
 ./fs/nfsd/nfssvc.c          |    6 +++-
 ./include/linux/nfsd/nfsd.h |    4 +--
 3 files changed, 52 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:09.000000000 +1100
@@ -985,14 +985,38 @@ release_all_files(void)
 	}
 }
 
-/* should use a slab cache */
+kmem_cache_t *stateowner_slab = NULL;
+
+static int
+nfsd4_init_slabs(void)
+{
+	stateowner_slab = kmem_cache_create("nfsd4_stateowners",
+			sizeof(struct nfs4_stateowner), 0, 0, NULL, NULL);
+	if (stateowner_slab == NULL) {
+		dprintk("nfsd4: out of memory while initializing nfsv4\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void
+nfsd4_free_slabs(void)
+{
+	int status = 0;
+
+	if (stateowner_slab)
+		status = kmem_cache_destroy(stateowner_slab);
+	stateowner_slab = NULL;
+	BUG_ON(status);
+}
+
 void
 nfs4_free_stateowner(struct kref *kref)
 {
 	struct nfs4_stateowner *sop =
 		container_of(kref, struct nfs4_stateowner, so_ref);
 	kfree(sop->so_owner.data);
-	kfree(sop);
+	kmem_cache_free(stateowner_slab, sop);
 	free_sowner++;
 }
 
@@ -1001,14 +1025,14 @@ alloc_stateowner(struct xdr_netobj *owne
 {
 	struct nfs4_stateowner *sop;
 
-	if ((sop = kmalloc(sizeof(struct nfs4_stateowner),GFP_KERNEL))) {
+	if ((sop = kmem_cache_alloc(stateowner_slab, GFP_KERNEL))) {
 		if ((sop->so_owner.data = kmalloc(owner->len, GFP_KERNEL))) {
 			memcpy(sop->so_owner.data, owner->data, owner->len);
 			sop->so_owner.len = owner->len;
 			kref_init(&sop->so_ref);
 			return sop;
 		} 
-		kfree(sop);
+		kmem_cache_free(stateowner_slab, sop);
 	}
 	return NULL;
 }
@@ -3129,14 +3153,12 @@ nfs4_check_open_reclaim(clientid_t *clid
  * Start and stop routines
  */
 
-void 
-nfs4_state_init(void)
+static void
+__nfs4_state_init(void)
 {
 	int i;
 	time_t grace_time;
 
-	if (nfs4_init)
-		return;
 	if (!nfs4_reclaim_init) {
 		for (i = 0; i < CLIENT_HASH_SIZE; i++)
 			INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
@@ -3180,7 +3202,21 @@ nfs4_state_init(void)
 	grace_end = boot_time + grace_time;
 	INIT_WORK(&laundromat_work,laundromat_main, NULL);
 	schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
+}
+
+int
+nfs4_state_init(void)
+{
+	int status;
+
+	if (nfs4_init)
+		return 0;
+	status = nfsd4_init_slabs();
+	if (status)
+		return status;
+	__nfs4_state_init();
 	nfs4_init = 1;
+	return 0;
 }
 
 int
@@ -3253,6 +3289,7 @@ nfs4_state_shutdown(void)
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
+	nfsd4_free_slabs();
 	nfs4_unlock_state();
 }
 
@@ -3305,7 +3342,7 @@ nfs4_reset_lease(time_t leasetime)
 	}
 init_state:
 	__nfs4_state_shutdown();
-	nfs4_state_init();
+	__nfs4_state_init();
 	nfs4_unlock_state();
 }
 

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2005-03-07 11:35:09.000000000 +1100
@@ -94,8 +94,10 @@ nfsd_svc(unsigned short port, int nrserv
 		nrservs = NFSD_MAXSERVS;
 	
 	/* Readahead param cache - will no-op if it already exists */
- 	error =	nfsd_racache_init(2*nrservs);
-	nfs4_state_init();
+	error =	nfsd_racache_init(2*nrservs);
+	if (error<0)
+		goto out;
+	error = nfs4_state_init();
 	if (error<0)
 		goto out;
 	if (!nfsd_serv) {

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2005-03-07 11:35:09.000000000 +1100
@@ -148,12 +148,12 @@ nfsd_set_posix_acl(struct svc_fh *fhp, i
  * NFSv4 State
  */
 #ifdef CONFIG_NFSD_V4
-void nfs4_state_init(void);
+int nfs4_state_init(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
 #else
-static inline void nfs4_state_init(void){}
+static inline int nfs4_state_init(void){}
 static inline void nfs4_state_shutdown(void){}
 static inline time_t nfs4_lease_time(void){return 0;}
 static inline void nfs4_reset_lease(time_t leasetime){}


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
