From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 44 of 54] nfsd4: reorganize release_deleg
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019g-6v@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrq-00027w-RN
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0005Cx-5k
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
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



Just separate part of release_deleg into a separate function.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:30:33.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:31:26.000000000 +1100
@@ -80,7 +80,6 @@ u32 free_delegation= 0;
 /* forward declarations */
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
-static void release_delegation(struct nfs4_delegation *dp);
 static void release_stateid_lockowners(struct nfs4_stateid *open_stp);
 
 /* Locking:
@@ -197,19 +196,26 @@ nfs4_put_delegation(struct nfs4_delegati
  */
 
 static void
+nfs4_close_delegation(struct nfs4_delegation *dp)
+{
+	struct file *filp = dp->dl_stp->st_vfs_file;
+
+	dprintk("NFSD: close_delegation dp %p\n",dp);
+	release_stateid_lockowners(dp->dl_stp);
+	kfree(dp->dl_stp);
+	dp->dl_stp = NULL;
+	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+	nfsd_close(filp);
+	vfsclose++;
+}
+
+/* Called under the state lock. */
+static void
 release_delegation(struct nfs4_delegation *dp)
 {
 	/* delayed nfsd_close */
-	if (dp->dl_stp) {
-		struct file *filp = dp->dl_stp->st_vfs_file;
-
-		dprintk("NFSD: release_delegation CLOSE\n");
-		release_stateid_lockowners(dp->dl_stp);
-		kfree(dp->dl_stp);
-		dp->dl_stp = NULL;
-		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
-		nfsd_close(filp);
-		vfsclose++;
+	if (dp->dl_stp)
+		nfs4_close_delegation(dp);
 	} else {
 		dprintk("NFSD: release_delegation remove lease dl_flock %p\n",
 			dp->dl_flock);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
