From: andros@netapp.com
Subject: [PATCH 02/13] SQUASHME pnfs_submit: remove CB_NOTIFY_DEVICEID
Date: Thu, 29 Apr 2010 16:34:40 -0400
Message-ID: <1272573291-8986-3-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757088Ab0D3Qst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:49 -0400
In-Reply-To: <1272573291-8986-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The file layoutdriver submission will not support CB_NOTIFY_DEVICEID

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c    |   68 --------------------------------
 fs/nfs/callback_xdr.c     |   96 +--------------------------------------------
 include/linux/nfs4_pnfs.h |    1 -
 3 files changed, 1 insertions(+), 164 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 5d1bfc9..025f31d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -325,74 +325,6 @@ out:
 	return res;
 }
 
-/* Remove all devices for each superblock for nfs_client.  This may try
- * to remove the same device multple times if they are
- * shared across superblocks in the layout driver, but the
- * layout drive should be able to handle this */
-static __be32 pnfs_devicenotify_client(struct nfs_client *clp,
-				       struct cb_pnfs_devicenotifyargs *args)
-{
-	struct nfs_server *server;
-	__be32 res = 0, res2 = 0;
-	int i, num_sb = 0;
-	struct layoutdriver_io_operations *ops;
-	uint32_t type;
-
-	dprintk("%s: --> clp %p\n", __func__, clp);
-
-	list_for_each_entry(server, &clp->cl_superblocks, client_link) {
-		ops = server->pnfs_curr_ld->ld_io_ops;
-		num_sb++;
-		for (i = 0; i < args->ndevs; i++) {
-			struct cb_pnfs_devicenotifyitem *dev = &args->devs[i];
-			type = dev->cbd_notify_type;
-			if (type == NOTIFY_DEVICEID4_DELETE &&
-			    PNFS_EXISTS_LDIO_OP(server, device_delete))
-				res = ops->device_delete(server->pnfs_mountid,
-							 &dev->cbd_dev_id);
-			else if (type == NOTIFY_DEVICEID4_CHANGE)
-				printk(KERN_ERR "%s: NOTIFY_DEVICEID4_CHANGE "
-					"not supported\n", __func__);
-			if (res)
-				res2 = res;
-		}
-	}
-	dprintk("%s: exit with status = %d numsb %u\n",
-		__func__, ntohl(res2), num_sb);
-	return res2;
-}
-
-__be32 pnfs_cb_devicenotify(struct cb_pnfs_devicenotifyargs *args,
-			    void *dummy)
-{
-	struct nfs_client *clp;
-	__be32 res = 0;
-	unsigned int num_client = 0;
-
-	dprintk("%s: -->\n", __func__);
-
-	res = __constant_htonl(NFS4ERR_INVAL);
-	clp = nfs_find_client(args->addr, 4);
-	if (clp == NULL) {
-		dprintk("%s: no client for addr %u.%u.%u.%u\n",
-			__func__, NIPQUAD(args->addr));
-		goto out;
-	}
-
-	do {
-		struct nfs_client *prev = clp;
-		num_client++;
-		res = pnfs_devicenotify_client(clp, args);
-		clp = nfs_find_client_next(prev);
-		nfs_put_client(prev);
-	} while (clp != NULL);
-
-out:
-	dprintk("%s: exit with status = %d numclient %u\n",
-		__func__, ntohl(res), num_client);
-	return res;
-}
-
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
 {
 	if (delegation == NULL)
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 11a596a..1856181 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -23,7 +23,6 @@
 
 #if defined(CONFIG_NFS_V4_1)
 #define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
-#define CB_OP_DEVICENOTIFY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
@@ -268,93 +267,6 @@ out:
 	return status;
 }
 
-static __be32 decode_pnfs_devicenotify_args(struct svc_rqst *rqstp,
-					    struct xdr_stream *xdr,
-					    struct cb_pnfs_devicenotifyargs *args)
-{
-	__be32 *p;
-	__be32 status = 0;
-	u32 tmp;
-	int n, i;
-	args->ndevs = 0;
-
-	args->addr = svc_addr(rqstp);
-
-	/* Num of device notifications */
-	p = read_buf(xdr, sizeof(uint32_t));
-	if (unlikely(p == NULL)) {
-		status = htonl(NFS4ERR_RESOURCE);
-		goto out;
-	}
-	n = ntohl(*p++);
-	if (n <= 0)
-		goto out;
-
-	/* XXX: need to possibly return error in this case */
-	if (n > NFS4_DEV_NOTIFY_MAXENTRIES) {
-		dprintk("%s: Processing (%d) notifications out of (%d)\n",
-			__func__, NFS4_DEV_NOTIFY_MAXENTRIES, n);
-		n = NFS4_DEV_NOTIFY_MAXENTRIES;
-	}
-
-	/* Decode each dev notification */
-	for (i = 0; i < n; i++) {
-		struct cb_pnfs_devicenotifyitem *dev = &args->devs[i];
-
-		p = read_buf(xdr, (4 * sizeof(uint32_t))
-			     + NFS4_PNFS_DEVICEID4_SIZE);
-		if (unlikely(p == NULL)) {
-			status = htonl(NFS4ERR_RESOURCE);
-			goto out;
-		}
-
-		tmp = ntohl(*p++);	/* bitmap size */
-		if (tmp != 1) {
-			status = htonl(NFS4ERR_INVAL);
-			goto out;
-		}
-		dev->cbd_notify_type = ntohl(*p++);
-		if (dev->cbd_notify_type != NOTIFY_DEVICEID4_CHANGE &&
-		    dev->cbd_notify_type != NOTIFY_DEVICEID4_DELETE) {
-			status = htonl(NFS4ERR_INVAL);
-			goto out;
-		}
-
-		tmp = ntohl(*p++);	/* opaque size */
-		if (((dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) &&
-		     (tmp != NFS4_PNFS_DEVICEID4_SIZE + 8)) ||
-		    ((dev->cbd_notify_type == NOTIFY_DEVICEID4_DELETE) &&
-		     (tmp != NFS4_PNFS_DEVICEID4_SIZE + 4))) {
-			status = htonl(NFS4ERR_INVAL);
-			goto out;
-		}
-		dev->cbd_layout_type = ntohl(*p++);
-		memcpy(dev->cbd_dev_id.data, p, NFS4_PNFS_DEVICEID4_SIZE);
-		p += XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE);
-
-		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
-			p = read_buf(xdr, sizeof(uint32_t));
-			if (unlikely(p == NULL)) {
-				status = htonl(NFS4ERR_DELAY);
-				goto out;
-			}
-			dev->cbd_immediate = ntohl(*p++);
-		} else {
-			dev->cbd_immediate = 0;
-		}
-
-		args->ndevs++;
-
-		dprintk("%s: type %d layout 0x%x immediate %d\n",
-			__func__, dev->cbd_notify_type, dev->cbd_layout_type,
-			dev->cbd_immediate);
-	}
-out:
-	dprintk("%s: status %d ndevs %d\n",
-		__func__, ntohl(status), args->ndevs);
-	return status;
-}
-
 static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
@@ -710,11 +622,11 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_LAYOUTRECALL:
-	case OP_CB_NOTIFY_DEVICEID:
 		*op = &callback_ops[op_nr];
 		break;
 
 	case OP_CB_NOTIFY:
+	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
@@ -880,12 +792,6 @@ static struct callback_op callback_ops[] = {
 			(callback_decode_arg_t)decode_pnfs_layoutrecall_args,
 		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
 	},
-	[OP_CB_NOTIFY_DEVICEID] = {
-		.process_op = (callback_process_op_t)pnfs_cb_devicenotify,
-		.decode_args =
-			(callback_decode_arg_t)decode_pnfs_devicenotify_args,
-		.res_maxsize = CB_OP_DEVICENOTIFY_RES_MAXSZ,
-	},
 	[OP_CB_SEQUENCE] = {
 		.process_op = (callback_process_op_t)nfs4_callback_sequence,
 		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index ae2f7ed..b2bec02 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -183,7 +183,6 @@ struct layoutdriver_io_operations {
 	 */
 	struct pnfs_mount_type * (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
 	int (*uninitialize_mountpoint) (struct pnfs_mount_type *mountid);
-	int (*device_delete) (struct pnfs_mount_type *mountid, struct pnfs_deviceid *dev_id);
 };
 
 enum layoutdriver_policy_flags {
-- 
1.6.6

