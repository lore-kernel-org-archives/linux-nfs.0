From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 7 - nfsdv4 byte range locking - LOCKU
Date: Tue, 23 Sep 2003 09:33:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aBG-0004ET-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBc-0008Ug-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:44 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBb-0003iA-Lo
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:43 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 23 Sep 2003 09:33:37 +1000
To: Linus Torvalds <torvalds@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

From: "William A.(Andy) Adamson" <andros@citi.umich.edu>


this last locking patch implments the LOCKU operation. these patches pass the 
connectathon lock test suite against the solaris nfsv4 client.

-->Andy

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c        |    3 ++
 ./fs/nfsd/nfs4state.c       |   59 ++++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4xdr.c         |   39 +++++++++++++++++++++++++++++
 ./include/linux/nfsd/xdr4.h |   14 ++++++++++
 4 files changed, 115 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-09-23 09:11:49.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-09-23 09:11:52.000000000 +1000
@@ -687,6 +687,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		case OP_LOCKT:
 			op->status = nfsd4_lockt(rqstp, &current_fh, &op->u.lockt);
 			break;
+		case OP_LOCKU:
+			op->status = nfsd4_locku(rqstp, &current_fh, &op->u.locku);
+			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, &current_fh, &op->u.lookup);
 			break;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-09-23 09:11:49.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-09-23 09:11:52.000000000 +1000
@@ -2033,6 +2033,65 @@ out:
 	return status;
 }
 
+int
+nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_locku *locku)
+{
+	struct nfs4_stateid *stp;
+	struct file *filp = NULL;
+	struct file_lock file_lock;
+	int status;
+						        
+	dprintk("NFSD: nfsd4_locku: start=%Ld length=%Ld\n",
+		locku->lu_offset, locku->lu_length);
+	nfs4_lock_state();
+									        
+	if ((status = nfs4_preprocess_seqid_op(current_fh, 
+					locku->lu_seqid, 
+					&locku->lu_stateid, 
+					CHECK_FH | LOCK_STATE, 
+					&locku->lu_stateowner, &stp)))
+		goto out;
+
+	filp = &stp->st_vfs_file;
+	BUG_ON(!filp);
+	file_lock.fl_type = F_UNLCK;
+	file_lock.fl_owner = (fl_owner_t) locku->lu_stateowner;
+	file_lock.fl_pid = lockownerid_hashval(locku->lu_stateowner->so_id);
+	file_lock.fl_file = filp;
+	file_lock.fl_flags = FL_POSIX; 
+	file_lock.fl_notify = NULL;
+	file_lock.fl_insert = NULL;
+	file_lock.fl_remove = NULL;
+	file_lock.fl_start = locku->lu_offset;
+
+	if ((locku->lu_length == ~(u64)0) || LOFF_OVERFLOW(locku->lu_offset, locku->lu_length))
+		file_lock.fl_end = ~(u64)0;
+	else
+		file_lock.fl_end = locku->lu_offset + locku->lu_length - 1;
+	nfs4_transform_lock_offset(&file_lock);
+
+	/*
+	*  Try to unlock the file in the VFS.
+	*/
+	status = posix_lock_file(filp, &file_lock); 
+	if (status) {
+		printk("NFSD: nfs4_locku: posix_lock_file failed!\n");
+		goto out_nfserr;
+	}
+	/*
+	* OK, unlock succeeded; the only thing left to do is update the stateid.
+	*/
+	update_stateid(&stp->st_stateid);
+	memcpy(&locku->lu_stateid, &stp->st_stateid, sizeof(stateid_t));
+
+out:
+	nfs4_unlock_state();
+	return status;
+
+out_nfserr:
+	status = nfserrno(status);
+	goto out;
+}
 
 /* 
  * Start and stop routines

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-09-23 09:11:49.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-09-23 09:11:52.000000000 +1000
@@ -625,6 +625,24 @@ nfsd4_decode_lockt(struct nfsd4_compound
 }
 
 static int
+nfsd4_decode_locku(struct nfsd4_compoundargs *argp, struct nfsd4_locku *locku)
+{
+	DECODE_HEAD;
+
+	READ_BUF(24 + sizeof(stateid_t));
+	READ32(locku->lu_type);
+	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
+		goto xdr_error;
+	READ32(locku->lu_seqid);
+	READ32(locku->lu_stateid.si_generation);
+	COPYMEM(&locku->lu_stateid.si_opaque, sizeof(stateid_opaque_t));
+	READ64(locku->lu_offset);
+	READ64(locku->lu_length);
+
+	DECODE_TAIL;
+}
+
+static int
 nfsd4_decode_lookup(struct nfsd4_compoundargs *argp, struct nfsd4_lookup *lookup)
 {
 	DECODE_HEAD;
@@ -1052,6 +1070,9 @@ nfsd4_decode_compound(struct nfsd4_compo
 		case OP_LOCKT:
 			op->status = nfsd4_decode_lockt(argp, &op->u.lockt);
 			break;
+		case OP_LOCKU:
+			op->status = nfsd4_decode_locku(argp, &op->u.locku);
+			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_decode_lookup(argp, &op->u.lookup);
 			break;
@@ -1815,6 +1836,21 @@ nfsd4_encode_lockt(struct nfsd4_compound
 		nfsd4_encode_lock_denied(resp, &lockt->lt_denied);
 }
 
+static void
+nfsd4_encode_locku(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_locku *locku)
+{
+	ENCODE_SEQID_OP_HEAD;
+
+	if (!nfserr) {
+		RESERVE_SPACE(sizeof(stateid_t));
+		WRITE32(locku->lu_stateid.si_generation);
+		WRITEMEM(&locku->lu_stateid.si_opaque, sizeof(stateid_opaque_t));
+		ADJUST_ARGS();
+	}
+				        
+	ENCODE_SEQID_OP_TAIL(locku->lu_stateowner);
+}
+
 
 static void
 nfsd4_encode_link(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_link *link)
@@ -2232,6 +2268,9 @@ nfsd4_encode_operation(struct nfsd4_comp
 	case OP_LOCKT:
 		nfsd4_encode_lockt(resp, op->status, &op->u.lockt);
 		break;
+	case OP_LOCKU:
+		nfsd4_encode_locku(resp, op->status, &op->u.locku);
+		break;
 	case OP_LOOKUP:
 		break;
 	case OP_LOOKUPP:

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-09-23 09:11:49.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2003-09-23 09:11:52.000000000 +1000
@@ -173,6 +173,17 @@ struct nfsd4_lockt {
 	struct nfsd4_lock_denied  	lt_denied;
 };
 
+ 
+struct nfsd4_locku {
+	u32             lu_type;
+	u32             lu_seqid;
+	stateid_t       lu_stateid;
+	u64             lu_offset;
+	u64             lu_length;
+	struct nfs4_stateowner  *lu_stateowner;
+};
+
+
 struct nfsd4_lookup {
 	u32		lo_len;             /* request */
 	char *		lo_name;            /* request */
@@ -330,6 +341,7 @@ struct nfsd4_op {
 		struct nfsd4_link		link;
 		struct nfsd4_lock		lock;
 		struct nfsd4_lockt		lockt;
+		struct nfsd4_locku		locku;
 		struct nfsd4_lookup		lookup;
 		struct nfsd4_verify		nverify;
 		struct nfsd4_open		open;
@@ -425,6 +437,8 @@ extern int nfsd4_lock(struct svc_rqst *r
 		struct nfsd4_lock *lock);
 extern int nfsd4_lockt(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
 		struct nfsd4_lockt *lockt);
+extern int nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
+		struct nfsd4_locku *locku);
 #endif
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
