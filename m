From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 7 - nfsdv4 byte range locking - LOCKT
Date: Tue, 23 Sep 2003 09:33:20 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aBE-0004EK-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBd-0008Ur-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:45 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBc-0003iG-6y
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:44 -0700
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

this patch implements the LOCKT operation.

-->Andy

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c        |    3 +
 ./fs/nfsd/nfs4state.c       |   92 ++++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4xdr.c         |   33 +++++++++++++++
 ./include/linux/nfsd/xdr4.h |   14 ++++++
 4 files changed, 142 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-09-23 09:11:47.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-09-23 09:11:49.000000000 +1000
@@ -684,6 +684,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		case OP_LOCK:
 			op->status = nfsd4_lock(rqstp, &current_fh, &op->u.lock);
 			break;
+		case OP_LOCKT:
+			op->status = nfsd4_lockt(rqstp, &current_fh, &op->u.lockt);
+			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, &current_fh, &op->u.lookup);
 			break;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-09-23 09:11:47.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-09-23 09:11:49.000000000 +1000
@@ -1942,6 +1942,98 @@ out:
 	return status;
 }
 
+/*
+ * LOCKT operation
+ */
+int
+nfsd4_lockt(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lockt *lockt)
+{
+	struct inode *inode;
+	struct nfs4_stateowner *sop;
+	struct file file;
+	struct file_lock file_lock;
+	struct file_lock *conflicting_lock;
+	unsigned int strhashval;
+	int status;
+
+	lockt->lt_stateowner = NULL;
+	nfs4_lock_state();
+
+	status = nfserr_stale_clientid;
+	if (STALE_CLIENTID(&lockt->lt_clientid)) {
+		printk("NFSD: nfsd4_lockt: clientid is stale!\n");
+		goto out;
+	}
+
+	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0))) {
+		printk("NFSD: nfsd4_lockt: fh_verify() failed!\n");
+		goto out;
+	}
+
+	inode = current_fh->fh_dentry->d_inode;
+	switch (lockt->lt_type) {
+		case NFS4_READ_LT:
+		case NFS4_READW_LT:
+			file_lock.fl_type = F_RDLCK;
+		break;
+		case NFS4_WRITE_LT:
+		case NFS4_WRITEW_LT:
+			file_lock.fl_type = F_WRLCK;
+		break;
+		default:
+			printk("NFSD: nfs4_lockt: bad lock type!\n");
+			status = nfserr_inval;
+		goto out;
+	}
+
+	strhashval = lock_ownerstr_hashval(inode, 
+			lockt->lt_clientid.cl_id, lockt->lt_owner);
+
+	if (find_lockstateowner_str(strhashval, &lockt->lt_owner, 
+					&lockt->lt_clientid, 
+					&lockt->lt_stateowner)) {
+		printk("NFSD: nsfd4_lockt: lookup_lockowner() failed!\n");
+		goto out;
+	}
+
+	sop = lockt->lt_stateowner;
+	if (sop) {
+		file_lock.fl_owner = (fl_owner_t) sop;
+		file_lock.fl_pid = lockownerid_hashval(sop->so_id);
+	} else {
+		file_lock.fl_owner = NULL;
+		file_lock.fl_pid = 0;
+	}
+	file_lock.fl_flags = FL_POSIX;
+
+	file_lock.fl_start = lockt->lt_offset;
+	if ((lockt->lt_length == ~(u64)0) || LOFF_OVERFLOW(lockt->lt_offset, lockt->lt_length))
+		file_lock.fl_end = ~(u64)0;
+	else
+		file_lock.fl_end = lockt->lt_offset + lockt->lt_length - 1;
+
+	nfs4_transform_lock_offset(&file_lock);
+
+	/* posix_test_lock uses the struct file _only_ to resolve the inode.
+	 * since LOCKT doesn't require an OPEN, and therefore a struct
+	 * file may not exist, pass posix_test_lock a struct file with
+	 * only the dentry:inode set.
+	 */
+	memset(&file, 0, sizeof (struct file));
+	file.f_dentry = current_fh->fh_dentry;
+
+	status = nfs_ok;
+	conflicting_lock = posix_test_lock(&file, &file_lock);
+	if (conflicting_lock) {
+		status = nfserr_denied;
+		nfs4_set_lock_denied(conflicting_lock, &lockt->lt_denied);
+	}
+out:
+	nfs4_unlock_state();
+	return status;
+}
+
+
 /* 
  * Start and stop routines
  */

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-09-23 09:11:47.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-09-23 09:11:49.000000000 +1000
@@ -606,6 +606,25 @@ nfsd4_decode_lock(struct nfsd4_compounda
 }
 
 static int
+nfsd4_decode_lockt(struct nfsd4_compoundargs *argp, struct nfsd4_lockt *lockt)
+{
+	DECODE_HEAD;
+		        
+	READ_BUF(32);
+	READ32(lockt->lt_type);
+	if((lockt->lt_type < NFS4_READ_LT) || (lockt->lt_type > NFS4_WRITEW_LT))
+		goto xdr_error;
+	READ64(lockt->lt_offset);
+	READ64(lockt->lt_length);
+	COPYMEM(&lockt->lt_clientid, 8);
+	READ32(lockt->lt_owner.len);
+	READ_BUF(lockt->lt_owner.len);
+	READMEM(lockt->lt_owner.data, lockt->lt_owner.len);
+
+	DECODE_TAIL;
+}
+
+static int
 nfsd4_decode_lookup(struct nfsd4_compoundargs *argp, struct nfsd4_lookup *lookup)
 {
 	DECODE_HEAD;
@@ -1030,6 +1049,9 @@ nfsd4_decode_compound(struct nfsd4_compo
 		case OP_LOCK:
 			op->status = nfsd4_decode_lock(argp, &op->u.lock);
 			break;
+		case OP_LOCKT:
+			op->status = nfsd4_decode_lockt(argp, &op->u.lockt);
+			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_decode_lookup(argp, &op->u.lookup);
 			break;
@@ -1787,6 +1809,14 @@ nfsd4_encode_lock(struct nfsd4_compoundr
 }
 
 static void
+nfsd4_encode_lockt(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_lockt *lockt)
+{
+	if (nfserr == nfserr_denied)
+		nfsd4_encode_lock_denied(resp, &lockt->lt_denied);
+}
+
+
+static void
 nfsd4_encode_link(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_link *link)
 {
 	ENCODE_HEAD;
@@ -2199,6 +2229,9 @@ nfsd4_encode_operation(struct nfsd4_comp
 	case OP_LOCK:
 		nfsd4_encode_lock(resp, op->status, &op->u.lock);
 		break;
+	case OP_LOCKT:
+		nfsd4_encode_lockt(resp, op->status, &op->u.lockt);
+		break;
 	case OP_LOOKUP:
 		break;
 	case OP_LOOKUPP:

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-09-23 09:11:47.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2003-09-23 09:11:49.000000000 +1000
@@ -162,6 +162,17 @@ struct nfsd4_lock {
 #define lk_resp_stateid u.ok.stateid
 #define lk_denied       u.denied
 
+
+struct nfsd4_lockt {
+	u32				lt_type;
+	clientid_t			lt_clientid;
+	struct xdr_netobj		lt_owner;
+	u64				lt_offset;
+	u64				lt_length;
+	struct nfs4_stateowner * 	lt_stateowner;
+	struct nfsd4_lock_denied  	lt_denied;
+};
+
 struct nfsd4_lookup {
 	u32		lo_len;             /* request */
 	char *		lo_name;            /* request */
@@ -318,6 +329,7 @@ struct nfsd4_op {
 		struct svc_fh *			getfh;
 		struct nfsd4_link		link;
 		struct nfsd4_lock		lock;
+		struct nfsd4_lockt		lockt;
 		struct nfsd4_lookup		lookup;
 		struct nfsd4_verify		nverify;
 		struct nfsd4_open		open;
@@ -411,6 +423,8 @@ extern int nfsd4_open_downgrade(struct s
 		struct svc_fh *current_fh, struct nfsd4_open_downgrade *od);
 extern int nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
 		struct nfsd4_lock *lock);
+extern int nfsd4_lockt(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
+		struct nfsd4_lockt *lockt);
 #endif
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
