From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 10 of 10 - Implement server-side reboot recovery (mostly)
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001R5-NB@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCQ-0007lK-09
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:22 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCP-00007S-2q
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:21 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:15 +1000
To: Andrew Morton <akpm@osdl.org>
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


From: "J. Bruce Fields" <bfields@fieldses.org>

>From Andros: Implement server-side reboot recovery (server now handles open and
lock reclaims).  Not completely to spec: we don't yet store the state in stable
storage that would be required to recover correctly in certain situations.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |  102 +++++++++++++++++++++++++++++++++++++------
 ./fs/nfsd/nfs4state.c        |   53 +++++++++++++++++++---
 ./include/linux/nfsd/nfsd.h  |    3 +
 ./include/linux/nfsd/state.h |    2 
 4 files changed, 140 insertions(+), 20 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-04-08 10:57:10.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-04-08 10:57:18.000000000 +1000
@@ -66,10 +66,31 @@ fh_dup2(struct svc_fh *dst, struct svc_f
 }
 
 static int
+do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+{
+	int accmode, status;
+
+	if (open->op_truncate && 
+		!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
+		return nfserr_inval;
+
+	accmode = MAY_NOP;
+	if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
+		accmode = MAY_READ;
+	if (open->op_share_deny & NFS4_SHARE_ACCESS_WRITE)
+		accmode |= (MAY_WRITE | MAY_TRUNC);
+	accmode |= MAY_OWNER_OVERRIDE;
+
+	status = fh_verify(rqstp, current_fh, S_IFREG, accmode);
+
+	return status;
+}
+
+static int
 do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
 	struct svc_fh resfh;
-	int accmode, status;
+	int status;
 
 	fh_init(&resfh, NFS4_FHSIZE);
 	open->op_truncate = 0;
@@ -92,6 +113,8 @@ do_open_lookup(struct svc_rqst *rqstp, s
 
 	if (!status) {
 		set_change_info(&open->op_cinfo, current_fh);
+
+		/* set reply cache */
 		fh_dup2(current_fh, &resfh);
 		/* XXXJBF: keep a saved svc_fh struct instead?? */
 		open->op_stateowner->so_replay.rp_openfh_len =
@@ -100,19 +123,41 @@ do_open_lookup(struct svc_rqst *rqstp, s
 				&resfh.fh_handle.fh_base,
 				resfh.fh_handle.fh_size);
 
-		accmode = MAY_NOP;
-		if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
-			accmode = MAY_READ;
-		if (open->op_share_deny & NFS4_SHARE_ACCESS_WRITE)
-			accmode |= (MAY_WRITE | MAY_TRUNC);
-		accmode |= MAY_OWNER_OVERRIDE;
-		status = fh_verify(rqstp, current_fh, S_IFREG, accmode);
+		status = do_open_permission(rqstp, current_fh, open);
 	}
 
 	fh_put(&resfh);
 	return status;
 }
 
+static int
+do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+{
+	int status;
+
+	dprintk("NFSD: do_open_fhandle\n");
+
+	/* we don't know the target directory, and therefore can not
+	* set the change info
+	*/
+
+	memset(&open->op_cinfo, 0, sizeof(struct nfsd4_change_info));
+
+	/* set replay cache */
+	open->op_stateowner->so_replay.rp_openfh_len = current_fh->fh_handle.fh_size;
+	memcpy(open->op_stateowner->so_replay.rp_openfh,
+		&current_fh->fh_handle.fh_base,
+		current_fh->fh_handle.fh_size);
+
+	open->op_truncate = (open->op_iattr.ia_valid & ATTR_SIZE) &&
+	!open->op_iattr.ia_size;
+
+	status = do_open_permission(rqstp, current_fh, open);
+
+	return status;
+}
+
+
 /*
  * nfs4_unlock_state() called in encode
  */
@@ -124,6 +169,13 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 		(int)open->op_fname.len, open->op_fname.data,
 		open->op_stateowner);
 
+	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+		return nfserr_grace;
+
+	if (nfs4_in_no_grace() &&
+		           open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+		return nfserr_no_grace;
+
 	/* This check required by spec. */
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
@@ -148,16 +200,30 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	}
 	if (status)
 		return status;
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_NULL) {
 	/*
 	 * This block of code will (1) set CURRENT_FH to the file being opened,
 	 * creating it if necessary, (2) set open->op_cinfo, 
 	 * (3) set open->op_truncate if the file is to be truncated 
 	 * after opening, (4) do permission checking.
 	 */
-	status = do_open_lookup(rqstp, current_fh, open);
-	if (status)
-		return status;
-
+		status = do_open_lookup(rqstp, current_fh, open);
+		if (status)
+			return status;
+	} else if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
+	/*
+	* The CURRENT_FH is already set to the file being opened. This 
+	* block of code will (1) set open->op_cinfo, (2) set 
+	* open->op_truncate if the file is to be truncated after opening, 
+	* (3) do permission checking.
+	*/
+		status = do_open_fhandle(rqstp, current_fh, open);
+		if (status)
+			return status;
+	} else {
+		printk("NFSD: unsupported OPEN claim type\n");
+		return nfserr_inval;
+	}
 	/*
 	 * nfsd4_process_open2() does the actual opening of the file.  If
 	 * successful, it (1) truncates the file if open->op_truncate was
@@ -414,6 +480,8 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 	int status;
 
 	/* no need to check permission - this will be done in nfsd_read() */
+	if (nfs4_in_grace())
+		return nfserr_grace;
 
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
@@ -539,10 +607,13 @@ static inline int
 nfsd4_setattr(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_setattr *setattr)
 {
 	struct nfs4_stateid *stp;
-	int status = nfserr_nofilehandle;
+	int status = nfs_ok;
+
+	if (nfs4_in_grace())
+		return nfserr_grace;
 
 	if (!current_fh->fh_dentry)
-		goto out;
+		return nfserr_nofilehandle;
 
 	status = nfs_ok;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
@@ -581,6 +652,9 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	u32 *p;
 	int status = nfs_ok;
 
+	if (nfs4_in_grace())
+		return nfserr_grace;
+
 	/* no need to check permission - this will be done in nfsd_write() */
 
 	if (write->wr_offset >= OFFSET_MAX)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-04-08 10:57:00.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-04-08 10:57:18.000000000 +1000
@@ -52,6 +52,7 @@
 
 /* Globals */
 time_t boot_time;
+static time_t grace_end = 0;
 static u32 current_clientid = 1;
 static u32 current_ownerid;
 static u32 current_fileid;
@@ -1104,7 +1105,7 @@ nfsd4_process_open1(struct nfsd4_open *o
 
 	status = nfserr_stale_clientid;
 	if (STALE_CLIENTID(&open->op_clientid))
-		goto out;
+		return status;
 
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
 	if (find_openstateowner_str(strhashval, open, &sop)) {
@@ -1125,7 +1126,7 @@ nfsd4_process_open1(struct nfsd4_open *o
 			}
 			/* replay: indicate to calling function */
 			status = NFSERR_REPLAY_ME;
-			goto out;
+			return status;
 		}
 		if (sop->so_confirmed) {
 			if (open->op_seqid == sop->so_seqid + 1) { 
@@ -1163,6 +1164,8 @@ instantiate_new_owner:
 renew:
 	renew_client(sop->so_client);
 out:
+	if (status && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+		status = nfserr_reclaim_bad;
 	return status;
 }
 /*
@@ -1173,7 +1176,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 {
 	struct iattr iattr;
 	struct nfs4_stateowner *sop = open->op_stateowner;
-	struct nfs4_file *fp;
+	struct nfs4_file *fp = NULL;
 	struct inode *ino;
 	unsigned int fi_hashval;
 	struct list_head *pos, *next;
@@ -1182,7 +1185,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 
 	status = nfserr_resource;
 	if (!sop)
-		goto out;
+		return status;
 
 	ino = current_fh->fh_dentry->d_inode;
 
@@ -1274,6 +1277,17 @@ out:
 	if (fp && list_empty(&fp->fi_perfile))
 		release_file(fp);
 
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
+		if (status)
+			status = nfserr_reclaim_bad;
+		else {
+		/* successful reclaim. so_seqid is decremented because
+		* it will be bumped in encode_open  
+		*/
+			open->op_stateowner->so_confirmed = 1;
+			open->op_stateowner->so_seqid--;
+		}
+	}
 	/*
 	* To finish the open response, we just need to set the rflags.
 	*/
@@ -1286,6 +1300,7 @@ out_free:
 	kfree(stp);
 	goto out;
 }
+
 static struct work_struct laundromat_work;
 static void laundromat_main(void *);
 static DECLARE_WORK(laundromat_work, laundromat_main, NULL);
@@ -1983,6 +1998,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		(long long) lock->lk_offset,
 		(long long) lock->lk_length);
 
+	if (nfs4_in_grace() && !lock->lk_reclaim)
+		return nfserr_grace;
+	if (nfs4_in_no_grace() && lock->lk_reclaim)
+		return nfserr_no_grace;
+
 	if (check_lock_length(lock->lk_offset, lock->lk_length))
 		 return nfserr_inval;
 
@@ -2012,8 +2032,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		                        CHECK_FH | OPEN_STATE,
 		                        &open_sop, &open_stp,
 					&lock->v.new.clientid);
-		if (status)
+		if (status) {
+			if (lock->lk_reclaim)
+				status = nfserr_reclaim_bad;
 			goto out;
+		}
 		/* create lockowner and lock stateid */
 		fp = open_stp->st_file;
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
@@ -2148,6 +2171,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	unsigned int strhashval;
 	int status;
 
+	if (nfs4_in_grace())
+		return nfserr_grace;
+
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
@@ -2377,6 +2403,7 @@ void 
 nfs4_state_init(void)
 {
 	int i;
+	time_t start = get_seconds();
 
 	if (nfs4_init)
 		return;
@@ -2407,13 +2434,27 @@ nfs4_state_init(void)
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	init_MUTEX(&client_sema);
-	boot_time = get_seconds();
+	boot_time = start;
+	grace_end = start + NFSD_LEASE_TIME;
 	INIT_WORK(&laundromat_work,laundromat_main, NULL);
 	schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
 	nfs4_init = 1;
 
 }
 
+int
+nfs4_in_grace(void)
+{
+	return time_before(get_seconds(), (unsigned long)grace_end);
+}
+
+int
+nfs4_in_no_grace(void)
+{
+	return (grace_end < get_seconds());
+}
+
+
 static void
 __nfs4_state_shutdown(void)
 {

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-04-08 10:50:13.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2004-04-08 10:57:18.000000000 +1000
@@ -197,6 +197,9 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_locks_held	__constant_htonl(NFSERR_LOCKS_HELD)
 #define	nfserr_op_illegal	__constant_htonl(NFSERR_OP_ILLEGAL)
 #define nfserr_badname		__constant_htonl(NFSERR_BADNAME)
+#define	nfserr_grace		__constant_htonl(NFSERR_GRACE)
+#define	nfserr_no_grace		__constant_htonl(NFSERR_NO_GRACE)
+#define	nfserr_reclaim_bad	__constant_htonl(NFSERR_RECLAIM_BAD)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-04-08 10:56:23.000000000 +1000
+++ ./include/linux/nfsd/state.h	2004-04-08 10:57:18.000000000 +1000
@@ -215,4 +215,6 @@ extern int nfs4_share_conflict(struct sv
 		unsigned int deny_type);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
+extern int nfs4_in_grace(void);
+extern int nfs4_in_no_grace(void);
 #endif   /* NFSD4_STATE_H */


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
