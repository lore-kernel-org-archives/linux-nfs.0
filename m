From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 23] Move nfserr_openmode checking from nfsd_read/write into nfs4_preprocess_stateid_op() in preperation for delegation state.
Date: Fri, 17 Dec 2004 16:23:55 +1100
Message-ID: <E1CfAap-0002dQ-32@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbL-00059M-NZ
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:27 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbI-00066h-NP
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:27 -0800
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



Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c         |   40 ++++------------------------------------
 ./fs/nfsd/nfs4state.c        |   42 +++++++++++++++++++++++++++++++++++-------
 ./include/linux/nfsd/state.h |    7 ++++---
 3 files changed, 43 insertions(+), 46 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-12-15 11:44:49.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-12-15 11:44:49.000000000 +1100
@@ -461,23 +461,8 @@ nfsd4_lookup(struct svc_rqst *rqstp, str
 }
 
 static inline int
-access_bits_permit_read(unsigned long access_bmap)
-{
-	return test_bit(NFS4_SHARE_ACCESS_READ, &access_bmap) ||
-		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
-}
-
-static inline int
-access_bits_permit_write(unsigned long access_bmap)
-{
-	return test_bit(NFS4_SHARE_ACCESS_WRITE, &access_bmap) ||
-		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
-}
-
-static inline int
 nfsd4_read(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_read *read)
 {
-	struct nfs4_stateid *stp;
 	int status;
 
 	/* no need to check permission - this will be done in nfsd_read() */
@@ -509,15 +494,10 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 	}
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(current_fh, &read->rd_stateid, 
-					CHECK_FH | RDWR_STATE, &stp))) {
+					CHECK_FH | RD_STATE))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
-	status = nfserr_openmode;
-	if (!access_bits_permit_read(stp->st_access_bmap)) {
-		dprintk("NFSD: nfsd4_read: file not opened for read!\n");
-		goto out;
-	}
 	status = nfs_ok;
 out:
 	nfs4_unlock_state();
@@ -605,7 +585,6 @@ nfsd4_rename(struct svc_rqst *rqstp, str
 static inline int
 nfsd4_setattr(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_setattr *setattr)
 {
-	struct nfs4_stateid *stp;
 	int status = nfs_ok;
 
 	if (nfs4_in_grace())
@@ -626,15 +605,10 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 		nfs4_lock_state();
 		if ((status = nfs4_preprocess_stateid_op(current_fh, 
 						&setattr->sa_stateid, 
-						CHECK_FH | RDWR_STATE, &stp))) {
+						CHECK_FH | WR_STATE))) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			goto out_unlock;
 		}
-		status = nfserr_openmode;
-		if (!access_bits_permit_write(stp->st_access_bmap)) {
-			dprintk("NFSD: nfsd4_setattr: not opened for write!\n");
-			goto out_unlock;
-		}
 		nfs4_unlock_state();
 	}
 	status = nfs_ok;
@@ -654,7 +628,6 @@ out_unlock:
 static inline int
 nfsd4_write(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_write *write)
 {
-	struct nfs4_stateid *stp;
 	stateid_t *stateid = &write->wr_stateid;
 	u32 *p;
 	int status = nfs_ok;
@@ -677,18 +650,13 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 		goto zero_stateid;
 	}
 	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid, 
-					CHECK_FH | RDWR_STATE, &stp))) {
+					CHECK_FH | WR_STATE))) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		goto out;
 	}
 
-	status = nfserr_openmode;
-	if (!access_bits_permit_write(stp->st_access_bmap)) {
-		dprintk("NFSD: nfsd4_write: file not open for write!\n");
-		goto out;
-	}
-
 zero_stateid:
+
 	nfs4_unlock_state();
 	write->wr_bytes_written = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 11:44:49.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 11:44:49.000000000 +1100
@@ -1564,12 +1564,39 @@ STALE_STATEID(stateid_t *stateid)
 	return 1;
 }
 
+static inline int
+access_permit_read(unsigned long access_bmap)
+{
+	return test_bit(NFS4_SHARE_ACCESS_READ, &access_bmap) ||
+		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
+}
+
+static inline int
+access_permit_write(unsigned long access_bmap)
+{
+	return test_bit(NFS4_SHARE_ACCESS_WRITE, &access_bmap) ||
+		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
+}
+
+static
+int check_openmode(struct nfs4_stateid *stp, int flags)
+{
+        int status = nfserr_openmode;
+
+	if ((flags & WR_STATE) && (!access_permit_write(stp->st_access_bmap)))
+                goto out;
+	if ((flags & RD_STATE) && (!access_permit_read(stp->st_access_bmap)))
+                goto out;
+	status = nfs_ok;
+out:
+	return status;
+}
 
 /*
 * Checks for stateid operations
 */
 int
-nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int flags, struct nfs4_stateid **stpp)
+nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int flags)
 {
 	struct nfs4_stateid *stp;
 	int status;
@@ -1578,8 +1605,6 @@ nfs4_preprocess_stateid_op(struct svc_fh
 		stateid->si_boot, stateid->si_stateownerid, 
 		stateid->si_fileid, stateid->si_generation); 
 
-	*stpp = NULL;
-
 	/* STALE STATEID */
 	status = nfserr_stale_stateid;
 	if (STALE_STATEID(stateid)) 
@@ -1611,9 +1636,12 @@ nfs4_preprocess_stateid_op(struct svc_fh
 		dprintk("preprocess_stateid_op: old stateid!\n");
 		goto out;
 	}
-	*stpp = stp;
-	status = nfs_ok;
 	renew_client(stp->st_stateowner->so_client);
+
+        if((status = check_openmode(stp, flags)))
+		goto out;
+
+	status = nfs_ok;
 out:
 	return status;
 }
@@ -1938,7 +1966,7 @@ find_stateid(stateid_t *stid, int flags)
 	unsigned int hashval;
 
 	dprintk("NFSD: find_stateid flags 0x%x\n",flags);
-	if ((flags & LOCK_STATE) || (flags & RDWR_STATE)) {
+	if ((flags & LOCK_STATE) || (flags & RD_STATE) || (flags & WR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
 		list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
 			if ((local->st_stateid.si_stateownerid == st_id) &&
@@ -1946,7 +1974,7 @@ find_stateid(stateid_t *stid, int flags)
 				return local;
 		}
 	} 
-	if ((flags & OPEN_STATE) || (flags & RDWR_STATE)) {
+	if ((flags & OPEN_STATE) || (flags & RD_STATE) || (flags & WR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
 		list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
 			if ((local->st_stateid.si_stateownerid == st_id) &&

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-12-15 11:44:49.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-12-15 11:44:49.000000000 +1100
@@ -231,8 +231,9 @@ struct nfs4_stateid {
 #define CONFIRM                 0x00000002
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
-#define RDWR_STATE              0x00000010
-#define CLOSE_STATE             0x00000020
+#define RD_STATE	        0x00000010
+#define WR_STATE	        0x00000020
+#define CLOSE_STATE             0x00000040
 
 #define seqid_mutating_err(err)                       \
 	(((err) != nfserr_stale_clientid) &&    \
@@ -243,7 +244,7 @@ struct nfs4_stateid {
 extern time_t nfs4_laundromat(void);
 extern int nfsd4_renew(clientid_t *clid);
 extern int nfs4_preprocess_stateid_op(struct svc_fh *current_fh, 
-		stateid_t *stateid, int flags, struct nfs4_stateid **stpp);
+		stateid_t *stateid, int flags);
 extern int nfs4_share_conflict(struct svc_fh *current_fh, 
 		unsigned int deny_type);
 extern void nfs4_lock_state(void);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
