From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 45 of 54] nfsd4: store-file-with-deleg
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019j-7j@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000283-Bh
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0005D7-IP
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
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



The only reason we're keeping a pointer to the stateid in the delegation is
so we can get at st_vfs_file.  So we should just keep a pointer to the
struct file instead.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   15 +++++++--------
 ./include/linux/nfsd/state.h |    2 +-
 2 files changed, 8 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:31:26.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:31:46.000000000 +1100
@@ -145,7 +145,7 @@ alloc_init_deleg(struct nfs4_client *clp
 	dp->dl_client = clp;
 	dp->dl_file = fp;
 	dp->dl_flock = NULL;
-	dp->dl_stp = NULL;
+	dp->dl_vfs_file = NULL;
 	dp->dl_type = type;
 	dp->dl_recall.cbr_dp = NULL;
 	dp->dl_recall.cbr_ident = cb->cb_ident;
@@ -198,12 +198,10 @@ nfs4_put_delegation(struct nfs4_delegati
 static void
 nfs4_close_delegation(struct nfs4_delegation *dp)
 {
-	struct file *filp = dp->dl_stp->st_vfs_file;
+	struct file *filp = dp->dl_vfs_file;
 
 	dprintk("NFSD: close_delegation dp %p\n",dp);
-	release_stateid_lockowners(dp->dl_stp);
-	kfree(dp->dl_stp);
-	dp->dl_stp = NULL;
+	dp->dl_vfs_file = NULL;
 	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
 	nfsd_close(filp);
 	vfsclose++;
@@ -214,9 +212,9 @@ static void
 release_delegation(struct nfs4_delegation *dp)
 {
 	/* delayed nfsd_close */
-	if (dp->dl_stp)
+	if (dp->dl_vfs_file)
 		nfs4_close_delegation(dp);
-	} else {
+	else {
 		dprintk("NFSD: release_delegation remove lease dl_flock %p\n",
 			dp->dl_flock);
 		remove_lease(dp->dl_flock);
@@ -1174,7 +1172,8 @@ release_stateid(struct nfs4_stateid *stp
 		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
 			if(cmp_clid(&dp->dl_client->cl_clientid,
 			    &stp->st_stateowner->so_client->cl_clientid)) {
-				dp->dl_stp = stp;
+				dp->dl_vfs_file = stp->st_vfs_file;
+				release_stateid_lockowners(stp);
 				return;
 			}
 		}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 13:30:33.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 13:31:46.000000000 +1100
@@ -91,7 +91,7 @@ struct nfs4_delegation {
 	struct nfs4_client	*dl_client;
 	struct nfs4_file	*dl_file;
 	struct file_lock	*dl_flock;
-	struct nfs4_stateid	*dl_stp;
+	struct file		*dl_vfs_file;
 	u32			dl_type;
 	time_t			dl_time;
 	struct nfs4_cb_recall	dl_recall;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
