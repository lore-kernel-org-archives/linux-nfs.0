From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 20 of 23] Add checking of delegation stateids to nfs4_preprocess_stateid_op.
Date: Fri, 17 Dec 2004 16:23:57 +1100
Message-ID: <E1CfAar-0002ee-A8@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAc1-0005BR-QI
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAby-0004GK-9F
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:09 -0800
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


Call release_delegation on delegreturn (DELEG_RET).

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   62 ++++++++++++++++++++++++++-----------------
 ./include/linux/nfsd/state.h |    1 
 2 files changed, 39 insertions(+), 24 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:51.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:51.000000000 +1100
@@ -1943,7 +1943,7 @@ access_permit_write(unsigned long access
 }
 
 static
-int check_openmode(struct nfs4_stateid *stp, int flags)
+int nfs4_check_openmode(struct nfs4_stateid *stp, int flags)
 {
         int status = nfserr_openmode;
 
@@ -1976,7 +1976,9 @@ out:
 int
 nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int flags)
 {
-	struct nfs4_stateid *stp;
+	struct nfs4_stateid *stp = NULL;
+	struct nfs4_delegation *dp = NULL;
+	stateid_t *stidp;
 	int status;
 
 	dprintk("NFSD: preprocess_stateid_op: stateid = (%08x/%08x/%08x/%08x)\n",
@@ -1990,35 +1992,47 @@ nfs4_preprocess_stateid_op(struct svc_fh
 
 	/* BAD STATEID */
 	status = nfserr_bad_stateid;
-	if (!(stp = find_stateid(stateid, flags))) {
-		dprintk("NFSD: preprocess_stateid_op: no open stateid!\n");
-		goto out;
-	}
-	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
-		dprintk("NFSD: preprocess_stateid_op: fh-stateid mismatch!\n");
-		stp->st_vfs_set = 0;
-		goto out;
-	}
-	if (!stp->st_stateowner->so_confirmed) {
-		dprintk("preprocess_stateid_op: lockowner not confirmed yet!\n");
-		goto out;
+	if (!stateid->si_fileid) { /* delegation stateid */
+		struct inode *ino = current_fh->fh_dentry->d_inode;
+
+		if(!(dp = find_delegation_stateid(ino, stateid))) {
+			dprintk("NFSD: delegation stateid not found\n");
+			goto out;
+		}
+		stidp = &dp->dl_stateid;
+	} else { /* open or lock stateid */
+		if (!(stp = find_stateid(stateid, flags))) {
+			dprintk("NFSD: open or lock stateid not found\n");
+			goto out;
+		}
+		if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp))
+			goto out;
+		if (!stp->st_stateowner->so_confirmed)
+			goto out;
+		stidp = &stp->st_stateid;
 	}
-	if (stateid->si_generation > stp->st_stateid.si_generation) {
-		dprintk("preprocess_stateid_op: future stateid?!\n");
+	if (stateid->si_generation > stidp->si_generation)
 		goto out;
-	}
 
 	/* OLD STATEID */
 	status = nfserr_old_stateid;
-	if (stateid->si_generation < stp->st_stateid.si_generation) {
-		dprintk("preprocess_stateid_op: old stateid!\n");
+	if (stateid->si_generation < stidp->si_generation)
 		goto out;
+	if (stp) {
+		if ((status = nfs4_check_openmode(stp,flags)))
+			goto out;
+		renew_client(stp->st_stateowner->so_client);
+	} else if (dp) {
+		if ((status = nfs4_check_delegmode(dp, flags)))
+			goto out;
+		renew_client(dp->dl_client);
+		if (flags & DELEG_RET) {
+			atomic_set(&dp->dl_state,NFS4_RECALL_COMPLETE);
+			spin_lock(&recall_lock);
+			release_delegation(dp);
+			spin_unlock(&recall_lock);
+		}
 	}
-	renew_client(stp->st_stateowner->so_client);
-
-        if((status = check_openmode(stp, flags)))
-		goto out;
-
 	status = nfs_ok;
 out:
 	return status;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-12-15 13:37:21.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-12-15 13:37:51.000000000 +1100
@@ -271,6 +271,7 @@ struct nfs4_stateid {
 #define RD_STATE	        0x00000010
 #define WR_STATE	        0x00000020
 #define CLOSE_STATE             0x00000040
+#define DELEG_RET               0x00000080
 
 #define seqid_mutating_err(err)                       \
 	(((err) != nfserr_stale_clientid) &&    \


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
