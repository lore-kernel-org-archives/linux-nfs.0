From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 10 of 54] nfsd4: move special stateid processing
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00017R-QD@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrm-00026Y-F7
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrk-0007sg-Nf
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
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



Move special stateid processing to nfs4_preprocess_stateid_op().  Also make
stateid processing for setattr the same as that for write.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |   38 +-------------------------------------
 ./fs/nfsd/nfs4state.c |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 37 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2005-03-07 11:35:10.000000000 +1100
@@ -473,25 +473,6 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	status = nfs_ok;
-	/* For stateid -1, we don't check share reservations.  */
-	if (ONE_STATEID(&read->rd_stateid)) {
-		dprintk("NFSD: nfsd4_read: -1 stateid...\n");
-		goto out;
-	}
-	/*
-	* For stateid 0, the client doesn't have to have the file open, but
-	* we still check for share reservation conflicts. 
-	*/
-	if (ZERO_STATEID(&read->rd_stateid)) {
-		dprintk("NFSD: nfsd4_read: zero stateid...\n");
-		if ((status = nfs4_share_conflict(current_fh, NFS4_SHARE_DENY_READ))) {
-			dprintk("NFSD: nfsd4_read: conflicting share reservation!\n");
-			goto out;
-		}
-		status = nfs_ok;
-		goto out;
-	}
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(current_fh, &read->rd_stateid, 
 					CHECK_FH | RD_STATE))) {
@@ -595,13 +576,6 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 
 	status = nfs_ok;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
-
-		status = nfserr_bad_stateid;
-		if (ZERO_STATEID(&setattr->sa_stateid) || ONE_STATEID(&setattr->sa_stateid)) {
-			dprintk("NFSD: nfsd4_setattr: magic stateid!\n");
-			goto out;
-		}
-
 		nfs4_lock_state();
 		if ((status = nfs4_preprocess_stateid_op(current_fh, 
 						&setattr->sa_stateid, 
@@ -641,23 +615,13 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
-		dprintk("NFSD: nfsd4_write: zero stateid...\n");
-		if ((status = nfs4_share_conflict(current_fh, NFS4_SHARE_DENY_WRITE))) {
-			dprintk("NFSD: nfsd4_write: conflicting share reservation!\n");
-			goto out;
-		}
-		goto zero_stateid;
-	}
 	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid, 
 					CHECK_FH | WR_STATE))) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		goto out;
 	}
-
-zero_stateid:
-
 	nfs4_unlock_state();
+
 	write->wr_bytes_written = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
 	p = (u32 *)write->wr_verifier.data;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:10.000000000 +1100
@@ -2007,6 +2007,22 @@ out:
 	return status;
 }
 
+static inline int
+check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
+{
+	/* Trying to call delegreturn with a special stateid? Yuch: */
+	if (!(flags & (RD_STATE | WR_STATE)))
+		return nfserr_bad_stateid;
+	else if (ONE_STATEID(stateid) && (flags & RD_STATE))
+		return nfs_ok;
+	else if (flags & WR_STATE)
+		return nfs4_share_conflict(current_fh,
+				NFS4_SHARE_DENY_WRITE);
+	else /* (flags & RD_STATE) && ZERO_STATEID(stateid) */
+		return nfs4_share_conflict(current_fh,
+				NFS4_SHARE_DENY_READ);
+}
+
 /*
 * Checks for stateid operations
 */
@@ -2022,6 +2038,9 @@ nfs4_preprocess_stateid_op(struct svc_fh
 		stateid->si_boot, stateid->si_stateownerid, 
 		stateid->si_fileid, stateid->si_generation); 
 
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+		return check_special_stateids(current_fh, stateid, flags);
+
 	/* STALE STATEID */
 	status = nfserr_stale_stateid;
 	if (STALE_STATEID(stateid)) 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
