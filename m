From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 11 of 54] nfsd4: allow some reads and writes during the grace period
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00017V-TQ@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrp-00027b-UK
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xro-0007tL-Vr
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
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


Allow READ and WRITE during the grace period on OPEN or LOCK state that has 
been reclaimed, for files for which mandatory locking is not in force.
(Reads and writes to files with mandatory locking must be delayed until
we're sure all the other clients have had a chance to recover locks.)

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |    8 --------
 ./fs/nfsd/nfs4state.c |   27 ++++++++++++++++++++++++---
 2 files changed, 24 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2005-03-07 11:35:10.000000000 +1100
@@ -466,8 +466,6 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 	int status;
 
 	/* no need to check permission - this will be done in nfsd_read() */
-	if (nfs4_in_grace())
-		return nfserr_grace;
 
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
@@ -568,9 +566,6 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 {
 	int status = nfs_ok;
 
-	if (nfs4_in_grace())
-		return nfserr_grace;
-
 	if (!current_fh->fh_dentry)
 		return nfserr_nofilehandle;
 
@@ -606,9 +601,6 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	u32 *p;
 	int status = nfs_ok;
 
-	if (nfs4_in_grace())
-		return nfserr_grace;
-
 	/* no need to check permission - this will be done in nfsd_write() */
 
 	if (write->wr_offset >= OFFSET_MAX)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:10.000000000 +1100
@@ -2015,7 +2015,11 @@ check_special_stateids(svc_fh *current_f
 		return nfserr_bad_stateid;
 	else if (ONE_STATEID(stateid) && (flags & RD_STATE))
 		return nfs_ok;
-	else if (flags & WR_STATE)
+	else if (nfs4_in_grace()) {
+		/* Answer in remaining cases depends on existance of
+		 * conflicting state; so we must wait out the grace period. */
+		return nfserr_grace;
+	} else if (flags & WR_STATE)
 		return nfs4_share_conflict(current_fh,
 				NFS4_SHARE_DENY_WRITE);
 	else /* (flags & RD_STATE) && ZERO_STATEID(stateid) */
@@ -2024,6 +2028,17 @@ check_special_stateids(svc_fh *current_f
 }
 
 /*
+ * Allow READ/WRITE during grace period on recovered state only for files
+ * that are not able to provide mandatory locking.
+ */
+static inline int
+io_during_grace_disallowed(struct inode *inode, int flags)
+{
+	return nfs4_in_grace() && (flags & (RD_STATE | WR_STATE))
+		&& MANDATORY_LOCK(inode);
+}
+
+/*
 * Checks for stateid operations
 */
 int
@@ -2032,12 +2047,16 @@ nfs4_preprocess_stateid_op(struct svc_fh
 	struct nfs4_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	stateid_t *stidp;
+	struct inode *ino = current_fh->fh_dentry->d_inode;
 	int status;
 
 	dprintk("NFSD: preprocess_stateid_op: stateid = (%08x/%08x/%08x/%08x)\n",
 		stateid->si_boot, stateid->si_stateownerid, 
 		stateid->si_fileid, stateid->si_generation); 
 
+	if (io_during_grace_disallowed(ino, flags))
+		return nfserr_grace;
+
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(current_fh, stateid, flags);
 
@@ -2049,16 +2068,18 @@ nfs4_preprocess_stateid_op(struct svc_fh
 	/* BAD STATEID */
 	status = nfserr_bad_stateid;
 	if (!stateid->si_fileid) { /* delegation stateid */
-		struct inode *ino = current_fh->fh_dentry->d_inode;
-
 		if(!(dp = find_delegation_stateid(ino, stateid))) {
 			dprintk("NFSD: delegation stateid not found\n");
+			if (nfs4_in_grace())
+				status = nfserr_grace;
 			goto out;
 		}
 		stidp = &dp->dl_stateid;
 	} else { /* open or lock stateid */
 		if (!(stp = find_stateid(stateid, flags))) {
 			dprintk("NFSD: open or lock stateid not found\n");
+			if (nfs4_in_grace())
+				status = nfserr_grace;
 			goto out;
 		}
 		if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp))


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
