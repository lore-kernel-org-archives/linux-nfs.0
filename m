From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 23 of 34 - Implement the nfsv4 RELEASE_LOCKOWNER operation.
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006K3-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xl-UF
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf2-0002QG-Br
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:52 -0800
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c        |    4 ++
 ./fs/nfsd/nfs4state.c       |   79 ++++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4xdr.c         |   19 ++++++++++
 ./include/linux/nfs4.h      |    1 
 ./include/linux/nfsd/nfsd.h |    1 
 ./include/linux/nfsd/xdr4.h |    8 ++++
 6 files changed, 112 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:34.000000000 +1100
@@ -728,6 +728,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		   (op->opnum == OP_SETCLIENTID) ||
 		   (op->opnum == OP_SETCLIENTID_CONFIRM) ||
 		   (op->opnum == OP_RENEW) || (op->opnum == OP_RESTOREFH) ||
+		   (op->opnum == OP_RELEASE_LOCKOWNER) || 
 		   (op->opnum == OP_SETATTR))) {
 			op->status = nfserr_nofilehandle;
 			goto encode_op;
@@ -834,6 +835,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		case OP_WRITE:
 			op->status = nfsd4_write(rqstp, &current_fh, &op->u.write);
 			break;
+		case OP_RELEASE_LOCKOWNER:
+			op->status = nfsd4_release_lockowner(rqstp, &op->u.release_lockowner);
+			break;
 		default:
 			BUG_ON(op->status == nfs_ok);
 			break;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:34.000000000 +1100
@@ -43,6 +43,7 @@
 #include <linux/nfsd/cache.h>
 #include <linux/mount.h>
 #include <linux/workqueue.h>
+#include <linux/smp_lock.h>
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
@@ -2137,6 +2138,84 @@ out_nfserr:
 	goto out;
 }
 
+/*
+ * returns
+ * 	1: locks held by lockowner
+ * 	0: no locks held by lockowner
+ */	
+static int
+check_for_locks(struct file *filp, struct nfs4_stateowner *lowner)
+{
+	struct file_lock **flpp;
+	struct inode *inode = filp->f_dentry->d_inode;
+	int status = 0;
+
+	lock_kernel();
+	for (flpp = &inode->i_flock; *flpp != NULL; flpp = &(*flpp)->fl_next) {
+		if ((*flpp)->fl_owner == (fl_owner_t)lowner)
+			status = 1;
+			goto out;
+	}
+out:
+	unlock_kernel();
+	return status;
+}
+
+int
+nfsd4_release_lockowner(struct svc_rqst *rqstp, struct nfsd4_release_lockowner *rlockowner)
+{
+	clientid_t *clid = &rlockowner->rl_clientid;
+	struct list_head *pos, *next;
+	struct nfs4_stateowner *local = NULL;
+	struct xdr_netobj *owner = &rlockowner->rl_owner;
+	int status, i;
+
+	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
+		clid->cl_boot, clid->cl_id);
+
+	/* XXX check for lease expiration */
+
+	status = nfserr_stale_clientid;
+	if (STALE_CLIENTID(clid)) {
+		printk("NFSD: nfsd4_release_lockowner: clientid is stale!\n");
+		return status;
+	}
+
+	nfs4_lock_state();
+
+	/* find the lockowner */
+        status = nfs_ok;
+	for (i=0; i < LOCK_HASH_SIZE; i++) {
+		list_for_each_safe(pos, next, &lock_ownerstr_hashtbl[i]) {
+			local = list_entry(pos, struct nfs4_stateowner, 
+						so_strhash);
+			if(cmp_owner_str(local, owner, clid))
+				break;
+		}
+	}
+	if (local) {
+		struct nfs4_stateid *stp;
+
+		/* check for any locks held by any stateid associated with the 
+		 * (lock) stateowner */
+		status = nfserr_locks_held;
+		list_for_each_safe(pos, next, &local->so_perfilestate) {
+			stp = list_entry(pos, struct nfs4_stateid, 
+					                    st_perfilestate);
+			if(stp->st_vfs_set) {
+				if (check_for_locks(&stp->st_vfs_file, local))
+					goto out;
+			}
+		}
+		/* no locks held by (lock) stateowner */
+		status = nfs_ok;
+		release_stateowner(local);
+	}
+out:
+	nfs4_unlock_state();
+	return status;
+}
+
 /* 
  * Start and stop routines
  */

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:34.000000000 +1100
@@ -993,6 +993,20 @@ nfsd4_decode_write(struct nfsd4_compound
 }
 
 static int
+nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_release_lockowner *rlockowner)
+{
+	DECODE_HEAD;
+
+	READ_BUF(12);	
+	COPYMEM(&rlockowner->rl_clientid, sizeof(clientid_t));
+	READ32(rlockowner->rl_owner.len);
+	READ_BUF(rlockowner->rl_owner.len);
+	READMEM(rlockowner->rl_owner.data, rlockowner->rl_owner.len);
+	
+	DECODE_TAIL;
+}
+
+static int
 nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 {
 	DECODE_HEAD;
@@ -1157,6 +1171,9 @@ nfsd4_decode_compound(struct nfsd4_compo
 		case OP_WRITE:
 			op->status = nfsd4_decode_write(argp, &op->u.write);
 			break;
+		case OP_RELEASE_LOCKOWNER:
+			op->status = nfsd4_decode_release_lockowner(argp, &op->u.release_lockowner);
+			break;
 		default:
 			/*
 			 * According to spec, anything greater than OP_WRITE
@@ -2349,6 +2366,8 @@ nfsd4_encode_operation(struct nfsd4_comp
 	case OP_WRITE:
 		nfsd4_encode_write(resp, op->status, &op->u.write);
 		break;
+	case OP_RELEASE_LOCKOWNER:
+		break;
 	default:
 		break;
 	}

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfs4.h	2004-02-24 10:42:34.000000000 +1100
@@ -86,6 +86,7 @@ enum nfs_opnum4 {
 	OP_SETCLIENTID_CONFIRM = 36,
 	OP_VERIFY = 37,
 	OP_WRITE = 38,
+	OP_RELEASE_LOCKOWNER = 39,
 };
 
 enum nfsstat4 {

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2004-02-24 10:42:34.000000000 +1100
@@ -194,6 +194,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_attrnotsupp	__constant_htonl(NFSERR_ATTRNOTSUPP)
 #define	nfserr_bad_xdr		__constant_htonl(NFSERR_BAD_XDR)
 #define	nfserr_openmode		__constant_htonl(NFSERR_OPENMODE)
+#define	nfserr_locks_held	__constant_htonl(NFSERR_LOCKS_HELD)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2004-02-24 10:42:34.000000000 +1100
@@ -263,6 +263,10 @@ struct nfsd4_readdir {
 	u32 *			offset;
 };
 
+struct nfsd4_release_lockowner {
+	clientid_t        rl_clientid;
+	struct xdr_netobj rl_owner;
+};
 struct nfsd4_readlink {
 	struct svc_rqst *rl_rqstp;          /* request */
 	struct svc_fh *	rl_fhp;             /* request */
@@ -359,6 +363,7 @@ struct nfsd4_op {
 		struct nfsd4_setclientid_confirm setclientid_confirm;
 		struct nfsd4_verify		verify;
 		struct nfsd4_write		write;
+		struct nfsd4_release_lockowner	release_lockowner;
 	} u;
 	struct nfs4_replay *			replay;
 };
@@ -441,6 +446,9 @@ extern int nfsd4_lockt(struct svc_rqst *
 		struct nfsd4_lockt *lockt);
 extern int nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
 		struct nfsd4_locku *locku);
+extern int
+nfsd4_release_lockowner(struct svc_rqst *rqstp, 
+		struct nfsd4_release_lockowner *rlockowner);
 #endif
 
 /*


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
