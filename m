From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 20 of 54] nfsd4: miscellaneous delegation fixes
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-000185-OG@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsE-0002Am-Hy
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:18 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsD-0005GV-QT
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:18 -0800
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



Don't hand out a delegation to a client that already has one.

Minor simplification and reformatting.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   31 +++++++++----------------------
 1 files changed, 9 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:56.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:56.000000000 +1100
@@ -1514,22 +1514,6 @@ out:
 }
 
 static int
-nfs4_deleg_conflict(u32 share, u32 dtype)
-{
-	return (((share & NFS4_SHARE_ACCESS_WRITE) &&
-		dtype == NFS4_OPEN_DELEGATE_READ) ||
-		((share & NFS4_SHARE_ACCESS_READ) &&
-		dtype == NFS4_OPEN_DELEGATE_WRITE));
-}
-
-/*
- * nfs4_check_deleg_recall()
- *
- * Test any delegation that is currently within an incompleted recalled
- * state, and return NFSERR_DELAY for conflicting open share.
- * flag is set to DONT_DELEGATE for shares that match the deleg type.
- */
-static int
 nfs4_check_deleg_recall(struct nfs4_file *fp, struct nfsd4_open *op, int *flag)
 {
 	struct nfs4_delegation *dp;
@@ -1538,13 +1522,16 @@ nfs4_check_deleg_recall(struct nfs4_file
 	list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
 		dprintk("NFSD: found delegation %p with dl_state %d\n",
 		 	                 dp, atomic_read(&dp->dl_state));
-		if (atomic_read(&dp->dl_state) == NFS4_RECALL_IN_PROGRESS) {
-			if(nfs4_deleg_conflict(op->op_share_access, dp->dl_type))
-				status = nfserr_jukebox;
-			else
-				*flag = NFS4_OPEN_DELEGATE_NONE;
+		if (op->op_share_access & NFS4_SHARE_ACCESS_WRITE
+			|| op->op_stateowner->so_client == dp->dl_client
+			|| atomic_read(&dp->dl_state) != NFS4_NO_RECALL) {
+			*flag = NFS4_OPEN_DELEGATE_NONE;
+			goto out;
 		}
 	}
+out:
+	dprintk("NFSD: nfs4_check_deleg_recall returns %d with flag %d\n",
+		status, *flag);
 	return status;
 }
 
@@ -1718,7 +1705,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	unsigned int fi_hashval;
 	struct nfs4_stateid *stp = NULL;
-	int status, delegflag = 0;
+	int status, delegflag = -1;
 
 	status = nfserr_inval;
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
