From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 23] Allocate and initialize the delegation structure.
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002dw-4x@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAb3-00058f-Pv
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAb1-0004Al-EZ
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:09 -0800
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


Declare and initialize the recall_lru list.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 56 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 11:55:28.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 12:00:46.000000000 +1100
@@ -57,8 +57,9 @@ static u32 nfs4_reclaim_init = 0;
 time_t boot_time;
 static time_t grace_end = 0;
 static u32 current_clientid = 1;
-static u32 current_ownerid;
-static u32 current_fileid;
+static u32 current_ownerid = 1;
+static u32 current_fileid = 1;
+static u32 current_delegid = 1;
 static u32 nfs4_init;
 stateid_t zerostateid;             /* bits all 0 */
 stateid_t onestateid;              /* bits all 1 */
@@ -75,6 +76,8 @@ u32 free_sowner = 0;
 u32 vfsopen = 0;
 u32 vfsclose = 0;
 u32 alloc_lsowner= 0;
+u32 alloc_delegation= 0;
+u32 free_delegation= 0;
 
 /* forward declarations */
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
@@ -117,6 +120,50 @@ static void release_stateowner(struct nf
 static void release_stateid(struct nfs4_stateid *stp, int flags);
 static void release_file(struct nfs4_file *fp);
 
+/*
+ * Delegation state
+ */
+
+/* recall_lock protects the del_recall_lru */
+spinlock_t recall_lock;
+static struct list_head del_recall_lru;
+
+static struct nfs4_delegation *
+alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp, struct svc_fh *current_fh, u32 type)
+{
+	struct nfs4_delegation *dp;
+
+	dprintk("NFSD alloc_init_deleg\n");
+	if ((dp = kmalloc(sizeof(struct nfs4_delegation),
+		GFP_KERNEL)) == NULL)
+		return dp;
+	INIT_LIST_HEAD(&dp->dl_del_perfile);
+	INIT_LIST_HEAD(&dp->dl_del_perclnt);
+	INIT_LIST_HEAD(&dp->dl_recall_lru);
+	dp->dl_client = clp;
+	dp->dl_file = fp;
+	dp->dl_flock = NULL;
+	dp->dl_stp = NULL;
+	dp->dl_type = type;
+	dp->dl_recall.cbr_dp = NULL;
+	dp->dl_recall.cbr_ident = 0;
+	dp->dl_recall.cbr_trunc = 0;
+	dp->dl_stateid.si_boot = boot_time;
+	dp->dl_stateid.si_stateownerid = current_delegid++;
+	dp->dl_stateid.si_fileid = 0;
+	dp->dl_stateid.si_generation = 0;
+	dp->dl_fhlen = current_fh->fh_handle.fh_size;
+	memcpy(dp->dl_fhval, &current_fh->fh_handle.fh_base,
+		        current_fh->fh_handle.fh_size);
+	dp->dl_time = 0;
+	atomic_set(&dp->dl_state, NFS4_NO_RECALL);
+	atomic_set(&dp->dl_count, 1);
+	atomic_set(&dp->dl_recall_cnt, 0);
+	list_add(&dp->dl_del_perfile, &fp->fi_del_perfile);
+	list_add(&dp->dl_del_perclnt, &clp->cl_del_perclnt);
+	alloc_delegation++;
+	return dp;
+}
 
 /* 
  * SETCLIENTID state 
@@ -248,6 +295,7 @@ create_client(struct xdr_netobj name) {
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_perclient);
+	INIT_LIST_HEAD(&clp->cl_del_perclnt);
 	INIT_LIST_HEAD(&clp->cl_lru);
 out:
 	return clp;
@@ -824,6 +872,7 @@ alloc_init_file(unsigned int hashval, st
 	if ((fp = kmalloc(sizeof(struct nfs4_file),GFP_KERNEL))) {
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_perfile);
+		INIT_LIST_HEAD(&fp->fi_del_perfile);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
@@ -2738,6 +2787,8 @@ nfs4_state_init(void)
 
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
+	INIT_LIST_HEAD(&del_recall_lru);
+	spin_lock_init(&recall_lock);
 	boot_time = get_seconds();
 	grace_time = max(old_lease_time, lease_time);
 	if (reclaim_str_hashtbl_size == 0)
@@ -2799,6 +2850,9 @@ __nfs4_state_shutdown(void)
 			alloc_sowner, alloc_lsowner, free_sowner);
 	dprintk("NFSD: vfsopen %d vfsclose %d\n",
 			vfsopen, vfsclose);
+	dprintk("NFSD: alloc_delegation %d free_delegation %d\n",
+			alloc_delegation, free_delegation);
+
 }
 
 void


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
