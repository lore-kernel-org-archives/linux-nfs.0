From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 28 of 34 - Enforce open_downgrade requirement
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006Km-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPrt-00074O-VD
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:52:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPrY-0005q4-Bq
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:48 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:50:42 +1100
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


The spec requires that the access and deny bits requested in open_downgrade
represent the union of the bits for some subset of the OPENS for the given
open_owner and file.  Enforce that requirement.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |   20 ++++++-
 ./fs/nfsd/nfs4state.c        |  121 +++++++++++++++++++++++++++++++++++--------
 ./include/linux/nfs4.h       |    1 
 ./include/linux/nfsd/state.h |    8 +-
 4 files changed, 121 insertions(+), 29 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:35.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:36.000000000 +1100
@@ -382,6 +382,20 @@ nfsd4_lookup(struct svc_rqst *rqstp, str
 }
 
 static inline int
+access_bits_permit_read(unsigned long access_bmap)
+{
+	return test_bit(NFS4_SHARE_ACCESS_READ, &access_bmap) ||
+		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
+}
+
+static inline int
+access_bits_permit_write(unsigned long access_bmap)
+{
+	return test_bit(NFS4_SHARE_ACCESS_WRITE, &access_bmap) ||
+		test_bit(NFS4_SHARE_ACCESS_BOTH, &access_bmap);
+}
+
+static inline int
 nfsd4_read(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_read *read)
 {
 	struct nfs4_stateid *stp;
@@ -419,7 +433,7 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 		goto out;
 	}
 	status = nfserr_openmode;
-	if (!(stp->st_share_access & NFS4_SHARE_ACCESS_READ)) {
+	if (!access_bits_permit_read(stp->st_access_bmap)) {
 		dprintk("NFSD: nfsd4_read: file not opened for read!\n");
 		goto out;
 	}
@@ -527,7 +541,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 			goto out;
 		}
 		status = nfserr_openmode;
-		if (!(stp->st_share_access & NFS4_SHARE_ACCESS_WRITE)) {
+		if (!access_bits_permit_write(stp->st_access_bmap)) {
 			dprintk("NFSD: nfsd4_setattr: not opened for write!\n");
 			goto out;
 		}
@@ -568,7 +582,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	}
 
 	status = nfserr_openmode;
-	if (!(stp->st_share_access & NFS4_SHARE_ACCESS_WRITE)) {
+	if (!access_bits_permit_write(stp->st_access_bmap)) {
 		dprintk("NFSD: nfsd4_write: file not open for write!\n");
 		goto out;
 	}

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:35.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:36.000000000 +1100
@@ -843,8 +843,10 @@ init_stateid(struct nfs4_stateid *stp, s
 	stp->st_stateid.si_stateownerid = sop->so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
 	stp->st_stateid.si_generation = 0;
-	stp->st_share_access = open->op_share_access;
-	stp->st_share_deny = open->op_share_deny;
+	stp->st_access_bmap = 0;
+	stp->st_deny_bmap = 0;
+	__set_bit(open->op_share_access, &stp->st_access_bmap);
+	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 }
 
 static void
@@ -961,15 +963,46 @@ find_file(unsigned int hashval, struct i
 	return 0;
 }
 
+#define TEST_ACCESS(x) ((x > 0 || x < 4)?1:0)
+#define TEST_DENY(x) ((x >= 0 || x < 5)?1:0)
+
+void
+set_access(unsigned int *access, unsigned long bmap) {
+	int i;
+
+	*access = 0;
+	for (i = 1; i < 4; i++) {
+		if(test_bit(i, &bmap))
+			*access |= i;
+	}
+}
+
+void
+set_deny(unsigned int *deny, unsigned long bmap) {
+	int i;
+
+	*deny = 0;
+	for (i = 0; i < 4; i++) {
+		if(test_bit(i, &bmap))
+			*deny |= i ;
+	}
+}
+
 static int
 test_share(struct nfs4_stateid *stp, struct nfsd4_open *open) {
-	if ((stp->st_share_access & open->op_share_deny) ||
-	    (stp->st_share_deny & open->op_share_access)) {
+	unsigned int access, deny;
+	
+	set_access(&access, stp->st_access_bmap);
+	set_deny(&deny, stp->st_deny_bmap);
+	if ((access & open->op_share_deny) || (deny & open->op_share_access)) 
 		return 0;
-	}
 	return 1;
 }
 
+/*
+ * Called to check deny when READ with all zero stateid or 
+ * WRITE with all zero or all one stateid
+ */ 
 int
 nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
@@ -986,7 +1019,8 @@ nfs4_share_conflict(struct svc_fh *curre
 	/* Search for conflicting share reservations */
 		list_for_each_safe(pos, next, &fp->fi_perfile) {
 			stp = list_entry(pos, struct nfs4_stateid, st_perfile);
-			if (stp->st_share_deny & deny_type)
+			if (test_bit(deny_type, &stp->st_deny_bmap) ||
+			    test_bit(NFS4_SHARE_DENY_BOTH, &stp->st_deny_bmap))
 				return nfserr_share_denied;
 		}
 	}
@@ -1129,6 +1163,10 @@ nfsd4_process_open2(struct svc_rqst *rqs
 
 	ino = current_fh->fh_dentry->d_inode;
 
+	status = nfserr_inval;
+	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
+		goto out;
+	    
 	nfs4_lock_state();
 	fi_hashval = file_hashval(ino);
 	if (find_file(fi_hashval, ino, &fp)) {
@@ -1180,15 +1218,18 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		/* This is an upgrade of an existing OPEN. 
 		 * OR the incoming share with the existing 
 		 * nfs4_stateid share */
-		int share_access = open->op_share_access;
+		unsigned int share_access;
 
-		share_access &= ~(stp->st_share_access);
+		set_access(&share_access, stp->st_access_bmap);
+		share_access = ~share_access;
+		share_access &= open->op_share_access;
 
 		/* update the struct file */
 		if ((status = nfs4_file_upgrade(&stp->st_vfs_file, share_access)))
 			goto out;
-		stp->st_share_access |= share_access;
-		stp->st_share_deny |= open->op_share_deny;
+		/* remember the open */
+		set_bit(open->op_share_access, &stp->st_access_bmap);
+		set_bit(open->op_share_deny, &stp->st_deny_bmap);
 		/* bump the stateid */
 		update_stateid(&stp->st_stateid);
 	}
@@ -1516,10 +1557,11 @@ check_replay:
 		printk("NFSD: preprocess_seqid_op: retransmission?\n");
 		/* indicate replay to calling function */
 		status = NFSERR_REPLAY_ME;
-	} else 
+	} else  {
 		printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d\n", sop->so_seqid +1, seqid);
 
 		status = nfserr_bad_seqid;
+	}
 	goto out;
 }
 
@@ -1561,16 +1603,48 @@ out:
 	nfs4_unlock_state();
 	return status;
 }
+
+
+/* 
+ * unset all bits in union bitmap (bmap) that
+ * do not exist in share (from successful OPEN_DOWNGRADE)
+ */
+static void
+reset_union_bmap_access(unsigned long access, unsigned long *bmap)
+{
+	int i;
+	for (i = 1; i < 4; i++) {
+		if ((i & access) != i)
+			__clear_bit(i, bmap);
+	}
+}
+
+static void
+reset_union_bmap_deny(unsigned long deny, unsigned long *bmap)
+{
+	int i;
+	for (i = 0; i < 4; i++) {
+		if ((i & deny) != i)
+			__clear_bit(i, bmap);
+	}
+}
+
+
 int
 nfsd4_open_downgrade(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_downgrade *od)
 {
 	int status;
 	struct nfs4_stateid *stp;
+	unsigned int share_access;
 
 	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
+	status = nfserr_inval;
+	if (!TEST_ACCESS(od->od_share_access) || !TEST_DENY(od->od_share_deny))
+		goto out;
+
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(current_fh, od->od_seqid, 
 					&od->od_stateid, 
@@ -1579,20 +1653,23 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 		goto out; 
 
 	status = nfserr_inval;
-	if (od->od_share_access & ~stp->st_share_access) {
-		dprintk("NFSD:access not a subset current=%08x, desired=%08x\n", 
-			stp->st_share_access, od->od_share_access); 
+	if (!test_bit(od->od_share_access, &stp->st_access_bmap)) {
+		dprintk("NFSD:access not a subset current bitmap: 0x%lx, input access=%08x\n", 
+			stp->st_access_bmap, od->od_share_access); 
 		goto out;
 	}
-	if (od->od_share_deny & ~stp->st_share_deny) {
-		dprintk("NFSD:deny not a subset current=%08x, desired=%08x\n", 
-			stp->st_share_deny, od->od_share_deny);
+	if (!test_bit(od->od_share_deny, &stp->st_deny_bmap)) {
+		dprintk("NFSD:deny not a subset current bitmap: 0x%lx, input deny=%08x\n", 
+			stp->st_deny_bmap, od->od_share_deny);
 		goto out;
 	}
+	set_access(&share_access, stp->st_access_bmap);
 	nfs4_file_downgrade(&stp->st_vfs_file, 
-	stp->st_share_access & ~od->od_share_access);
-	stp->st_share_access = od->od_share_access;
-	stp->st_share_deny = od->od_share_deny;
+	                    share_access & ~od->od_share_access);
+
+	reset_union_bmap_access(od->od_share_access, &stp->st_access_bmap);
+	reset_union_bmap_deny(od->od_share_deny, &stp->st_deny_bmap);
+
 	update_stateid(&stp->st_stateid);
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
@@ -1819,8 +1896,8 @@ alloc_init_lock_stateid(struct nfs4_stat
 	stp->st_stateid.si_generation = 0;
 	stp->st_vfs_file = open_stp->st_vfs_file;
 	stp->st_vfs_set = open_stp->st_vfs_set;
-	stp->st_share_access = -1; 
-	stp->st_share_deny = -1;
+	stp->st_access_bmap = open_stp->st_access_bmap;
+	stp->st_deny_bmap = open_stp->st_deny_bmap;
 
 out:
 	return stp;

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2004-02-24 10:42:35.000000000 +1100
+++ ./include/linux/nfs4.h	2004-02-24 10:42:36.000000000 +1100
@@ -37,6 +37,7 @@
 #define NFS4_SHARE_ACCESS_BOTH	0x0003
 #define NFS4_SHARE_DENY_READ	0x0001
 #define NFS4_SHARE_DENY_WRITE	0x0002
+#define NFS4_SHARE_DENY_BOTH	0x0003
 
 #define NFS4_SET_TO_SERVER_TIME	0
 #define NFS4_SET_TO_CLIENT_TIME	1

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-02-24 10:42:36.000000000 +1100
@@ -170,8 +170,8 @@ struct nfs4_file {
 * 	st_perfile: file_hashtbl[] entry.
 * 	st_perfile_state: nfs4_stateowner->so_perfilestate
 *       st_perlockowner: (open stateid) list of lock nfs4_stateowners
-* 	st_share_access: used only for open stateid
-* 	st_share_deny: used only for open stateid
+* 	st_access_bmap: used only for open stateid
+* 	st_deny_bmap: used only for open stateid
 */
 
 struct nfs4_stateid {
@@ -184,8 +184,8 @@ struct nfs4_stateid {
 	stateid_t                     st_stateid;
 	struct file                   st_vfs_file;
 	int                           st_vfs_set;
-	unsigned int                  st_share_access;
-	unsigned int                  st_share_deny;
+	unsigned long                 st_access_bmap;
+	unsigned long                 st_deny_bmap;
 };
 
 /* flags for preprocess_seqid_op() */


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
