Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23015 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab0HMVdW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:22 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 45/50] pnfs_submit: cb_layoutrecall
Date: Fri, 13 Aug 2010 17:31:57 -0400
Message-Id: <1281735122-1496-46-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-45-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
 <1281735122-1496-41-git-send-email-andros@netapp.com>
 <1281735122-1496-42-git-send-email-andros@netapp.com>
 <1281735122-1496-43-git-send-email-andros@netapp.com>
 <1281735122-1496-44-git-send-email-andros@netapp.com>
 <1281735122-1496-45-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.h      |   25 ++++
 fs/nfs/callback_proc.c |  328 +++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/callback_xdr.c  |   65 +++++++++-
 fs/nfs/nfs4_fs.h       |    1 +
 4 files changed, 415 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 85a7cfd..ab9b421 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -8,6 +8,8 @@
 #ifndef __LINUX_FS_NFS_CALLBACK_H
 #define __LINUX_FS_NFS_CALLBACK_H
 
+#include <linux/pnfs_xdr.h>
+
 #define NFS4_CALLBACK 0x40000000
 #define NFS4_CALLBACK_XDRSIZE 2048
 #define NFS4_CALLBACK_BUFSIZE (1024 + NFS4_CALLBACK_XDRSIZE)
@@ -72,6 +74,8 @@ struct cb_recallargs {
 
 #if defined(CONFIG_NFS_V4_1)
 
+#include <linux/pnfs_xdr.h>
+
 struct referring_call {
 	uint32_t			rc_sequenceid;
 	uint32_t			rc_slotid;
@@ -111,6 +115,13 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
 
 #define RCA4_TYPE_MASK_RDATA_DLG	0
 #define RCA4_TYPE_MASK_WDATA_DLG	1
+#define RCA4_TYPE_MASK_DIR_DLG         2
+#define RCA4_TYPE_MASK_FILE_LAYOUT     3
+#define RCA4_TYPE_MASK_BLK_LAYOUT      4
+#define RCA4_TYPE_MASK_OBJ_LAYOUT_MIN  8
+#define RCA4_TYPE_MASK_OBJ_LAYOUT_MAX  9
+#define RCA4_TYPE_MASK_OTHER_LAYOUT_MIN 12
+#define RCA4_TYPE_MASK_OTHER_LAYOUT_MAX 15
 
 struct cb_recallanyargs {
 	struct sockaddr	*craa_addr;
@@ -127,6 +138,20 @@ struct cb_recallslotargs {
 extern unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args,
 					  void *dummy);
 
+struct cb_pnfs_layoutrecallargs {
+	struct sockaddr		*cbl_addr;
+	struct nfs_fh		cbl_fh;
+	struct nfs4_pnfs_layout_segment cbl_seg;
+	struct nfs_fsid		cbl_fsid;
+	uint32_t		cbl_recall_type;
+	uint32_t		cbl_layout_type;
+	uint32_t		cbl_layoutchanged;
+	nfs4_stateid		cbl_stateid;
+};
+
+extern unsigned pnfs_cb_layoutrecall(struct cb_pnfs_layoutrecallargs *args,
+				     void *dummy);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c7f0021..e2ea2be 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -8,10 +8,15 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/slab.h>
+#include <linux/kthread.h>
+#include <linux/module.h>
+#include <linux/writeback.h>
+#include <linux/nfs4_pnfs.h>
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
@@ -114,6 +119,292 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
+static bool
+pnfs_is_next_layout_stateid(const struct pnfs_layout_type *lo,
+			    const nfs4_stateid stateid)
+{
+	int seqlock;
+	bool res;
+	u32 oldseqid, newseqid;
+
+	do {
+		seqlock = read_seqbegin(&lo->seqlock);
+		oldseqid = be32_to_cpu(lo->stateid.u.stateid.seqid);
+		newseqid = be32_to_cpu(stateid.u.stateid.seqid);
+		res = !memcmp(lo->stateid.u.stateid.other,
+			      stateid.u.stateid.other,
+			      NFS4_STATEID_OTHER_SIZE);
+		if (res) { /* comparing layout stateids */
+			if (oldseqid == ~0)
+				res = (newseqid == 1);
+			else
+				res = (newseqid == oldseqid + 1);
+		} else { /* open stateid */
+			res = !memcmp(lo->stateid.u.data,
+				      &zero_stateid,
+				      NFS4_STATEID_SIZE);
+			if (res)
+				res = (newseqid == 1);
+		}
+	} while (read_seqretry(&lo->seqlock, seqlock));
+
+	return res;
+}
+
+/*
+ * Retrieve an inode based on layout recall parameters
+ *
+ * Note: caller must iput(inode) to dereference the inode.
+ */
+static struct inode *
+nfs_layoutrecall_find_inode(struct nfs_client *clp,
+			    const struct cb_pnfs_layoutrecallargs *args)
+{
+	struct nfs_inode *nfsi;
+	struct pnfs_layout_type *layout;
+	struct nfs_server *server;
+	struct inode *ino = NULL;
+
+	dprintk("%s: Begin recall_type=%d clp %p\n",
+		__func__, args->cbl_recall_type, clp);
+
+	spin_lock(&clp->cl_lock);
+	list_for_each_entry(layout, &clp->cl_layouts, lo_layouts) {
+		nfsi = PNFS_NFS_INODE(layout);
+		if (!nfsi)
+			continue;
+
+		dprintk("%s: Searching inode=%lu\n",
+			__func__, nfsi->vfs_inode.i_ino);
+
+		if (args->cbl_recall_type == RETURN_FILE) {
+		    if (nfs_compare_fh(&args->cbl_fh, &nfsi->fh))
+			continue;
+		} else if (args->cbl_recall_type == RETURN_FSID) {
+			server = NFS_SERVER(&nfsi->vfs_inode);
+			if (server->fsid.major != args->cbl_fsid.major ||
+			    server->fsid.minor != args->cbl_fsid.minor)
+				continue;
+		}
+
+		/* Make sure client didn't clean up layout without
+		 * telling the server */
+		if (!has_layout(nfsi))
+			continue;
+
+		ino = igrab(&nfsi->vfs_inode);
+		dprintk("%s: Found inode=%p\n", __func__, ino);
+		break;
+	}
+	spin_unlock(&clp->cl_lock);
+	return ino;
+}
+
+struct recall_layout_threadargs {
+	struct inode *inode;
+	struct nfs_client *clp;
+	struct completion started;
+	struct cb_pnfs_layoutrecallargs *rl;
+	int result;
+};
+
+static int pnfs_recall_layout(void *data)
+{
+	struct inode *inode, *ino;
+	struct nfs_client *clp;
+	struct cb_pnfs_layoutrecallargs rl;
+	struct nfs4_pnfs_layoutreturn *lrp;
+	struct recall_layout_threadargs *args =
+		(struct recall_layout_threadargs *)data;
+	int status = 0;
+
+	daemonize("nfsv4-layoutreturn");
+
+	dprintk("%s: recall_type=%d fsid 0x%llx-0x%llx start\n",
+		__func__, args->rl->cbl_recall_type,
+		args->rl->cbl_fsid.major, args->rl->cbl_fsid.minor);
+
+	clp = args->clp;
+	inode = args->inode;
+	rl = *args->rl;
+
+	/* support whole file layouts only */
+	rl.cbl_seg.offset = 0;
+	rl.cbl_seg.length = NFS4_MAX_UINT64;
+
+	if (rl.cbl_recall_type == RETURN_FILE) {
+		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
+						rl.cbl_stateid))
+			status = pnfs_return_layout(inode, &rl.cbl_seg,
+						    &rl.cbl_stateid, RETURN_FILE,
+						    false);
+		else
+			status = cpu_to_be32(NFS4ERR_DELAY);
+		if (status)
+			dprintk("%s RETURN_FILE error: %d\n", __func__, status);
+		else
+			status =  cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
+		args->result = status;
+		complete(&args->started);
+		goto out;
+	}
+
+	status = cpu_to_be32(NFS4_OK);
+	args->result = status;
+	complete(&args->started);
+	args = NULL;
+
+	/* IMPROVEME: This loop is inefficient, running in O(|s_inodes|^2) */
+	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
+		/* FIXME: need to check status on pnfs_return_layout */
+		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE, false);
+		iput(ino);
+	}
+
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (!lrp) {
+		dprintk("%s: allocation failed. Cannot send last LAYOUTRETURN\n",
+			__func__);
+		goto out;
+	}
+
+	/* send final layoutreturn */
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = rl.cbl_layout_type;
+	lrp->args.return_type = rl.cbl_recall_type;
+	lrp->args.lseg = rl.cbl_seg;
+	lrp->args.inode = inode;
+	pnfs4_proc_layoutreturn(lrp, true);
+
+out:
+	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
+	nfs_put_client(clp);
+	module_put_and_exit(0);
+	dprintk("%s: exit status %d\n", __func__, 0);
+	return 0;
+}
+
+/*
+ * Asynchronous layout recall!
+ */
+static int pnfs_async_return_layout(struct nfs_client *clp, struct inode *inode,
+				    struct cb_pnfs_layoutrecallargs *rl)
+{
+	struct recall_layout_threadargs data = {
+		.clp = clp,
+		.inode = inode,
+		.rl = rl,
+	};
+	struct task_struct *t;
+	int status = -EAGAIN;
+
+	dprintk("%s: -->\n", __func__);
+
+	/* FIXME: do not allow two concurrent layout recalls */
+	if (test_and_set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state))
+		return status;
+
+	init_completion(&data.started);
+	__module_get(THIS_MODULE);
+	if (!atomic_inc_not_zero(&clp->cl_count))
+		goto out_put_no_client;
+
+	t = kthread_run(pnfs_recall_layout, &data, "%s", "pnfs_recall_layout");
+	if (IS_ERR(t)) {
+		printk(KERN_INFO "NFS: Layout recall callback thread failed "
+			"for client (clientid %08x/%08x)\n",
+			(unsigned)(clp->cl_clientid >> 32),
+			(unsigned)(clp->cl_clientid));
+		status = PTR_ERR(t);
+		goto out_module_put;
+	}
+	wait_for_completion(&data.started);
+	return data.result;
+out_module_put:
+	nfs_put_client(clp);
+out_put_no_client:
+	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
+	module_put(THIS_MODULE);
+	return status;
+}
+
+static int pnfs_recall_all_layouts(struct nfs_client *clp)
+{
+	struct cb_pnfs_layoutrecallargs rl;
+	struct inode *inode;
+	int status = 0;
+
+	rl.cbl_recall_type = RETURN_ALL;
+	rl.cbl_seg.iomode = IOMODE_ANY;
+	rl.cbl_seg.offset = 0;
+	rl.cbl_seg.length = NFS4_MAX_UINT64;
+
+	/* we need the inode to get the nfs_server struct */
+	inode = nfs_layoutrecall_find_inode(clp, &rl);
+	if (!inode)
+		return status;
+	status = pnfs_async_return_layout(clp, inode, &rl);
+	iput(inode);
+
+	return status;
+}
+
+__be32 pnfs_cb_layoutrecall(struct cb_pnfs_layoutrecallargs *args,
+			    void *dummy)
+{
+	struct nfs_client *clp;
+	struct inode *inode = NULL;
+	__be32 res;
+	int status;
+	unsigned int num_client = 0;
+
+	dprintk("%s: -->\n", __func__);
+
+	res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
+	clp  = nfs_find_client(args->cbl_addr, 4);
+	if (clp == NULL) {
+		dprintk("%s: no client for addr %u.%u.%u.%u\n",
+			__func__, NIPQUAD(args->cbl_addr));
+		goto out;
+	}
+
+	res = cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
+	do {
+		struct nfs_client *prev = clp;
+		num_client++;
+		/* the callback must come from the MDS personality */
+		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+			goto loop;
+		if (args->cbl_recall_type == RETURN_FILE) {
+			inode = nfs_layoutrecall_find_inode(clp, args);
+			if (inode != NULL) {
+				status = pnfs_async_return_layout(clp, inode,
+								  args);
+				if (status)
+					res = cpu_to_be32(NFS4ERR_DELAY);
+				iput(inode);
+			}
+		} else { /* _ALL or _FSID */
+			/* we need the inode to get the nfs_server struct */
+			inode = nfs_layoutrecall_find_inode(clp, args);
+			if (!inode)
+				goto loop;
+			status = pnfs_async_return_layout(clp, inode, args);
+			if (status)
+				res = cpu_to_be32(NFS4ERR_DELAY);
+			iput(inode);
+		}
+loop:
+		clp = nfs_find_client_next(prev);
+		nfs_put_client(prev);
+	} while (clp != NULL);
+
+out:
+	dprintk("%s: exit with status = %d numclient %u\n",
+		__func__, ntohl(res), num_client);
+	return res;
+}
+
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
 {
 	if (delegation == NULL)
@@ -325,13 +616,37 @@ out:
 	return status;
 }
 
+static inline bool
+validate_bitmap_values(const unsigned long *mask)
+{
+	int i;
+
+	if (*mask == 0)
+		return true;
+	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_WDATA_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_DIR_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, mask) ||
+	    test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, mask))
+		return true;
+	for (i = RCA4_TYPE_MASK_OBJ_LAYOUT_MIN;
+	     i <= RCA4_TYPE_MASK_OBJ_LAYOUT_MAX; i++)
+		if (test_bit(i, mask))
+			return true;
+	for (i = RCA4_TYPE_MASK_OTHER_LAYOUT_MIN;
+	     i <= RCA4_TYPE_MASK_OTHER_LAYOUT_MAX; i++)
+		if (test_bit(i, mask))
+			return true;
+	return false;
+}
+
 __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 {
 	struct nfs_client *clp;
 	__be32 status;
 	fmode_t flags = 0;
 
-	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	status = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
 	clp = nfs_find_client(args->craa_addr, 4);
 	if (clp == NULL)
 		goto out;
@@ -339,16 +654,25 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 	dprintk("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
+	status = cpu_to_be32(NFS4ERR_INVAL);
+	if (!validate_bitmap_values((const unsigned long *)
+				    &args->craa_type_mask))
+		return status;
+
+	status = cpu_to_be32(NFS4_OK);
 	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags = FMODE_READ;
 	if (test_bit(RCA4_TYPE_MASK_WDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags |= FMODE_WRITE;
+	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
+		     &args->craa_type_mask))
+		if (pnfs_recall_all_layouts(clp) == -EAGAIN)
+			status = cpu_to_be32(NFS4ERR_DELAY);
 
 	if (flags)
 		nfs_expire_all_delegation_types(clp, flags);
-	status = htonl(NFS4_OK);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 79b0fb7..a3f5279 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -22,6 +22,7 @@
 #define CB_OP_RECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 
 #if defined(CONFIG_NFS_V4_1)
+#define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
@@ -220,6 +221,60 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 
+static __be32 decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
+					    struct xdr_stream *xdr,
+					    struct cb_pnfs_layoutrecallargs *args)
+{
+	__be32 *p;
+	__be32 status = 0;
+
+	args->cbl_addr = svc_addr(rqstp);
+	p = read_buf(xdr, 4 * sizeof(uint32_t));
+	if (unlikely(p == NULL)) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
+
+	args->cbl_layout_type = ntohl(*p++);
+	args->cbl_seg.iomode = ntohl(*p++);
+	args->cbl_layoutchanged = ntohl(*p++);
+	args->cbl_recall_type = ntohl(*p++);
+
+	if (likely(args->cbl_recall_type == RETURN_FILE)) {
+		status = decode_fh(xdr, &args->cbl_fh);
+		if (unlikely(status != 0))
+			goto out;
+
+		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_BADXDR);
+			goto out;
+		}
+		p = xdr_decode_hyper(p, &args->cbl_seg.offset);
+		p = xdr_decode_hyper(p, &args->cbl_seg.length);
+		status = decode_stateid(xdr, &args->cbl_stateid);
+		if (unlikely(status != 0))
+			goto out;
+	} else if (args->cbl_recall_type == RETURN_FSID) {
+		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_BADXDR);
+			goto out;
+		}
+		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
+		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
+	}
+	dprintk("%s: ltype 0x%x iomode %d changed %d recall_type %d "
+		"fsid %llx-%llx fhsize %d\n", __func__,
+		args->cbl_layout_type, args->cbl_seg.iomode,
+		args->cbl_layoutchanged, args->cbl_recall_type,
+		args->cbl_fsid.major, args->cbl_fsid.minor,
+		args->cbl_fh.size);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
+
 static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
@@ -574,12 +629,12 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_SEQUENCE:
 	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALL_SLOT:
+	case OP_CB_LAYOUTRECALL:
 		*op = &callback_ops[op_nr];
 		break;
 
-	case OP_CB_LAYOUTRECALL:
-	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_NOTIFY:
+	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
@@ -739,6 +794,12 @@ static struct callback_op callback_ops[] = {
 		.res_maxsize = CB_OP_RECALL_RES_MAXSZ,
 	},
 #if defined(CONFIG_NFS_V4_1)
+	[OP_CB_LAYOUTRECALL] = {
+		.process_op = (callback_process_op_t)pnfs_cb_layoutrecall,
+		.decode_args =
+			(callback_decode_arg_t)decode_pnfs_layoutrecall_args,
+		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
+	},
 	[OP_CB_SEQUENCE] = {
 		.process_op = (callback_process_op_t)nfs4_callback_sequence,
 		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ef70bef..d6440fc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -46,6 +46,7 @@ enum nfs4_client_state {
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_LAYOUT_RECALL,
 };
 
 enum nfs4_session_state {
-- 
1.6.2.5

