From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 011 of 16] nfsd4: slabify nfs4_files
Date: Fri, 08 Apr 2005 11:00:17 +1000
Message-ID: <E1DJhr7-0006e2-8m@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006U1-EQ
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikM-0004DS-S2
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


The structures the server uses to keep track of various pieces of nfsv4 state
(open files, outstanding delegations, etc.) are likely to be allocated and
deallocated frequently and seem reasonable candidates for slab caches.

While we're at it, the slab code keeps statistics that help catch leaks and
such, so we may as well take this chance to eliminate some debugging counters
that we've been keeping ourselves.

Start with the struct nfs4_file.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   58 +++++++++++++++++++++++++++++---------------------
 1 files changed, 34 insertions(+), 24 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:41:30.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:45:18.000000000 +1000
@@ -70,8 +70,6 @@ u32 list_add_perfile = 0; 
 u32 list_del_perfile = 0;
 u32 add_perclient = 0;
 u32 del_perclient = 0;
-u32 alloc_file = 0;
-u32 free_file = 0;
 u32 vfsopen = 0;
 u32 vfsclose = 0;
 u32 alloc_delegation= 0;
@@ -90,6 +88,9 @@ static void release_stateid_lockowners(s
  */
 static DECLARE_MUTEX(client_sema);
 
+kmem_cache_t *stateowner_slab = NULL;
+kmem_cache_t *file_slab = NULL;
+
 void
 nfs4_lock_state(void)
 {
@@ -961,14 +962,14 @@ alloc_init_file(struct inode *ino)
 	struct nfs4_file *fp;
 	unsigned int hashval = file_hashval(ino);
 
-	if ((fp = kmalloc(sizeof(struct nfs4_file),GFP_KERNEL))) {
+	fp = kmem_cache_alloc(file_slab, GFP_KERNEL);
+	if (fp) {
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_perfile);
 		INIT_LIST_HEAD(&fp->fi_del_perfile);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
-		alloc_file++;
 		return fp;
 	}
 	return NULL;
@@ -992,29 +993,41 @@ release_all_files(void)
 	}
 }
 
-kmem_cache_t *stateowner_slab = NULL;
-
-static int
-nfsd4_init_slabs(void)
+static void
+nfsd4_free_slab(kmem_cache_t **slab)
 {
-	stateowner_slab = kmem_cache_create("nfsd4_stateowners",
-			sizeof(struct nfs4_stateowner), 0, 0, NULL, NULL);
-	if (stateowner_slab == NULL) {
-		dprintk("nfsd4: out of memory while initializing nfsv4\n");
-		return -ENOMEM;
-	}
-	return 0;
+	int status;
+
+	if (*slab == NULL)
+		return;
+	status = kmem_cache_destroy(*slab);
+	*slab = NULL;
+	WARN_ON(status);
 }
 
 static void
 nfsd4_free_slabs(void)
 {
-	int status = 0;
+	nfsd4_free_slab(&stateowner_slab);
+	nfsd4_free_slab(&file_slab);
+}
 
-	if (stateowner_slab)
-		status = kmem_cache_destroy(stateowner_slab);
-	stateowner_slab = NULL;
-	BUG_ON(status);
+static int
+nfsd4_init_slabs(void)
+{
+	stateowner_slab = kmem_cache_create("nfsd4_stateowners",
+			sizeof(struct nfs4_stateowner), 0, 0, NULL, NULL);
+	if (stateowner_slab == NULL)
+		goto out_nomem;
+	file_slab = kmem_cache_create("nfsd4_files",
+			sizeof(struct nfs4_file), 0, 0, NULL, NULL);
+	if (file_slab == NULL)
+		goto out_nomem;
+	return 0;
+out_nomem:
+	nfsd4_free_slabs();
+	dprintk("nfsd4: out of memory while initializing nfsv4\n");
+	return -ENOMEM;
 }
 
 void
@@ -1167,10 +1180,9 @@ release_stateid(struct nfs4_stateid *stp
 static void
 release_file(struct nfs4_file *fp)
 {
-	free_file++;
 	list_del(&fp->fi_hash);
 	iput(fp->fi_inode);
-	kfree(fp);
+	kmem_cache_free(file_slab, fp);
 }	
 
 void
@@ -3286,8 +3298,6 @@ __nfs4_state_shutdown(void)
 			list_add_perfile, list_del_perfile);
 	dprintk("NFSD: add_perclient %d del_perclient %d\n",
 			add_perclient, del_perclient);
-	dprintk("NFSD: alloc_file %d free_file %d\n",
-			alloc_file, free_file);
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
