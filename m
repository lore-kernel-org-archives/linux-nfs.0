From: andros@netapp.com
Subject: [PATCH 1/5] pnfs_post_submit: restore CB_NOTIFY_DEVICEID
Date: Fri, 30 Apr 2010 14:27:08 -0400
Message-ID: <1272652032-2496-2-git-send-email-andros@netapp.com>
References: <1272652032-2496-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933867Ab0D3S1o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 14:27:44 -0400
In-Reply-To: <1272652032-2496-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Reverts "pnfs_submit: remove CB_NOTIFY_DEVICEID"
and replaces "pnfs_submit: remove filelayout CB_NOTIFY_DEVICE support"

With the generic device id cache, there is no need for a per layout driver
delete_deviceid function.

Note: This functionlaity is incomplete as all layout segments referring to
the 'to be removed device id' need to be reaped, and all in flight I/O drained.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c    |   53 ++++++++++++++++++++++++
 fs/nfs/callback_xdr.c     |   97 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.c             |   16 ++++++-
 include/linux/nfs4_pnfs.h |    2 +
 4 files changed, 165 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 025f31d..ebf86df 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -325,6 +325,59 @@ out:
 	return res;
 }
 
+/* Remove the deviceid(s) from the nfs_client deviceid cache */
+static __be32 pnfs_devicenotify_client(struct nfs_client *clp,
+				       struct cb_pnfs_devicenotifyargs *args)
+{
+	uint32_t type;
+	int i;
+
+	dprintk("%s: --> clp %p\n", __func__, clp);
+
+	for (i = 0; i < args->ndevs; i++) {
+		struct cb_pnfs_devicenotifyitem *dev = &args->devs[i];
+		type = dev->cbd_notify_type;
+		if (type == NOTIFY_DEVICEID4_DELETE && clp->cl_devid_cache)
+			nfs4_delete_device(clp->cl_devid_cache,
+					   &dev->cbd_dev_id);
+		else if (type == NOTIFY_DEVICEID4_CHANGE)
+			printk(KERN_ERR "%s: NOTIFY_DEVICEID4_CHANGE "
+					"not supported\n", __func__);
+	}
+	return 0;
+}
+
+__be32 pnfs_cb_devicenotify(struct cb_pnfs_devicenotifyargs *args,
+			    void *dummy)
+{
+	struct nfs_client *clp;
+	__be32 res = 0;
+	unsigned int num_client = 0;
+
+	dprintk("%s: -->\n", __func__);
+
+	res = __constant_htonl(NFS4ERR_INVAL);
+	clp = nfs_find_client(args->addr, 4);
+	if (clp == NULL) {
+		dprintk("%s: no client for addr %u.%u.%u.%u\n",
+			__func__, NIPQUAD(args->addr));
+		goto out;
+	}
+
+	do {
+		struct nfs_client *prev = clp;
+		num_client++;
+		res = pnfs_devicenotify_client(clp, args);
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
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 1856181..69a026d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -23,6 +23,7 @@
 
 #if defined(CONFIG_NFS_V4_1)
 #define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_DEVICENOTIFY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
@@ -267,6 +268,94 @@ out:
 	return status;
 }
 
+static
+__be32 decode_pnfs_devicenotify_args(struct svc_rqst *rqstp,
+				     struct xdr_stream *xdr,
+				     struct cb_pnfs_devicenotifyargs *args)
+{
+	__be32 *p;
+	__be32 status = 0;
+	u32 tmp;
+	int n, i;
+	args->ndevs = 0;
+
+	args->addr = svc_addr(rqstp);
+
+	/* Num of device notifications */
+	p = read_buf(xdr, sizeof(uint32_t));
+	if (unlikely(p == NULL)) {
+		status = htonl(NFS4ERR_RESOURCE);
+		goto out;
+	}
+	n = ntohl(*p++);
+	if (n <= 0)
+		goto out;
+
+	/* XXX: need to possibly return error in this case */
+	if (n > NFS4_DEV_NOTIFY_MAXENTRIES) {
+		dprintk("%s: Processing (%d) notifications out of (%d)\n",
+			__func__, NFS4_DEV_NOTIFY_MAXENTRIES, n);
+		n = NFS4_DEV_NOTIFY_MAXENTRIES;
+	}
+
+	/* Decode each dev notification */
+	for (i = 0; i < n; i++) {
+		struct cb_pnfs_devicenotifyitem *dev = &args->devs[i];
+
+		p = read_buf(xdr, (4 * sizeof(uint32_t))
+			     + NFS4_PNFS_DEVICEID4_SIZE);
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_RESOURCE);
+			goto out;
+		}
+
+		tmp = ntohl(*p++);	/* bitmap size */
+		if (tmp != 1) {
+			status = htonl(NFS4ERR_INVAL);
+			goto out;
+		}
+		dev->cbd_notify_type = ntohl(*p++);
+		if (dev->cbd_notify_type != NOTIFY_DEVICEID4_CHANGE &&
+		    dev->cbd_notify_type != NOTIFY_DEVICEID4_DELETE) {
+			status = htonl(NFS4ERR_INVAL);
+			goto out;
+		}
+
+		tmp = ntohl(*p++);	/* opaque size */
+		if (((dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) &&
+		     (tmp != NFS4_PNFS_DEVICEID4_SIZE + 8)) ||
+		    ((dev->cbd_notify_type == NOTIFY_DEVICEID4_DELETE) &&
+		     (tmp != NFS4_PNFS_DEVICEID4_SIZE + 4))) {
+			status = htonl(NFS4ERR_INVAL);
+			goto out;
+		}
+		dev->cbd_layout_type = ntohl(*p++);
+		memcpy(dev->cbd_dev_id.data, p, NFS4_PNFS_DEVICEID4_SIZE);
+		p += XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE);
+
+		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
+			p = read_buf(xdr, sizeof(uint32_t));
+			if (unlikely(p == NULL)) {
+				status = htonl(NFS4ERR_DELAY);
+				goto out;
+			}
+			dev->cbd_immediate = ntohl(*p++);
+		} else {
+			dev->cbd_immediate = 0;
+		}
+
+		args->ndevs++;
+
+		dprintk("%s: type %d layout 0x%x immediate %d\n",
+			__func__, dev->cbd_notify_type, dev->cbd_layout_type,
+			dev->cbd_immediate);
+	}
+out:
+	dprintk("%s: status %d ndevs %d\n",
+		__func__, ntohl(status), args->ndevs);
+	return status;
+}
+
 static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
@@ -622,11 +711,11 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_LAYOUTRECALL:
+	case OP_CB_NOTIFY_DEVICEID:
 		*op = &callback_ops[op_nr];
 		break;
 
 	case OP_CB_NOTIFY:
-	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
@@ -792,6 +881,12 @@ static struct callback_op callback_ops[] = {
 			(callback_decode_arg_t)decode_pnfs_layoutrecall_args,
 		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
 	},
+	[OP_CB_NOTIFY_DEVICEID] = {
+		.process_op = (callback_process_op_t)pnfs_cb_devicenotify,
+		.decode_args =
+			(callback_decode_arg_t)decode_pnfs_devicenotify_args,
+		.res_maxsize = CB_OP_DEVICENOTIFY_RES_MAXSZ,
+	},
 	[OP_CB_SEQUENCE] = {
 		.process_op = (callback_process_op_t)nfs4_callback_sequence,
 		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1560b4d..af6424a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2359,7 +2359,8 @@ nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_deviceid *new)
 EXPORT_SYMBOL(nfs4_add_deviceid);
 
 static int
-nfs4_remove_deviceid(struct nfs4_deviceid_cache *c, long hash)
+nfs4_remove_deviceid(struct nfs4_deviceid_cache *c, long hash,
+		     struct pnfs_deviceid *id)
 {
 	struct nfs4_deviceid *d;
 	struct hlist_node *n;
@@ -2367,6 +2368,8 @@ nfs4_remove_deviceid(struct nfs4_deviceid_cache *c, long hash)
 	dprintk("--> %s hash %ld\n", __func__, hash);
 	spin_lock(&c->dc_lock);
 	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
+		if (id && memcmp(id, &d->de_id, NFS4_PNFS_DEVICEID4_SIZE))
+			continue;
 		hlist_del_rcu(&d->de_node);
 		spin_unlock(&c->dc_lock);
 		synchronize_rcu();
@@ -2379,6 +2382,15 @@ nfs4_remove_deviceid(struct nfs4_deviceid_cache *c, long hash)
 	return 0;
 }
 
+void
+nfs4_delete_device(struct nfs4_deviceid_cache *c, struct pnfs_deviceid *id)
+{
+	long hash = nfs4_deviceid_hash(id);
+
+	nfs4_remove_deviceid(c, hash, id);
+}
+EXPORT_SYMBOL(nfs4_delete_device);
+
 static void
 nfs4_free_deviceid_cache(struct kref *kref)
 {
@@ -2390,7 +2402,7 @@ nfs4_free_deviceid_cache(struct kref *kref)
 	for (i = 0; i < NFS4_DEVICE_ID_HASH_SIZE; i++) {
 		more = 1;
 		while (more)
-			more = nfs4_remove_deviceid(cache, i);
+			more = nfs4_remove_deviceid(cache, i, NULL);
 	}
 	kfree(cache);
 }
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 81701a3..1efea2a 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -304,6 +304,8 @@ extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
 extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
 				struct nfs4_deviceid *,
 				void (*free_callback)(struct kref *));
+extern void nfs4_delete_device(struct nfs4_deviceid_cache *,
+				struct pnfs_deviceid *);
 
 /* pNFS client callback functions.
  * These operations allow the layout driver to access pNFS client
-- 
1.6.6

