Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50790 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069Ab1E2STO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:19:14 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Marc Eshel <eshel@almaden.ibm.com>
Subject: [PATCH 06/32] pnfs: CB_NOTIFY_DEVICEID
Date: Sun, 29 May 2011 21:19:02 +0300
Message-Id: <1306693142-7874-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Marc Eshel <eshel@almaden.ibm.com>

Note: This functionlaity is incomplete as all layout segments referring to
the 'to be removed device id' need to be reaped, and all in flight I/O drained.

[use be32 res in nfs4_callback_devicenotify]
[use nfs_client to qualify deviceid for cb_notify_deviceid]
[use global deviceid cache for CB_NOTIFY_DEVICEID]
[refactor device cache _lookup_deviceid]
[refactor device cache _find_get_deviceid]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Bug in new global-device-cache code]
[layout_driver MUST set free_deviceid_node if using dev-cache]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h      |   17 ++++++++
 fs/nfs/callback_proc.c |   47 +++++++++++++++++++++++
 fs/nfs/callback_xdr.c  |   96 +++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h          |    1 +
 fs/nfs/pnfs_dev.c      |   95 ++++++++++++++++++++++++++++++++++++++++-------
 5 files changed, 241 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 46d93ce..b257383 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -167,6 +167,23 @@ extern unsigned nfs4_callback_layoutrecall(
 
 extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
 extern void nfs4_cb_take_slot(struct nfs_client *clp);
+
+struct cb_devicenotifyitem {
+	uint32_t		cbd_notify_type;
+	uint32_t		cbd_layout_type;
+	struct nfs4_deviceid	cbd_dev_id;
+	uint32_t		cbd_immediate;
+};
+
+struct cb_devicenotifyargs {
+	int				 ndevs;
+	struct cb_devicenotifyitem	 *devs;
+};
+
+extern __be32 nfs4_callback_devicenotify(
+	struct cb_devicenotifyargs *args,
+	void *dummy, struct cb_process_state *cps);
+
 #endif /* CONFIG_NFS_V4_1 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2f41dcce..fb5e5b9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -241,6 +241,53 @@ static void pnfs_recall_all_layouts(struct nfs_client *clp)
 	do_callback_layoutrecall(clp, &args);
 }
 
+__be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
+				  void *dummy, struct cb_process_state *cps)
+{
+	int i;
+	__be32 res = 0;
+	struct nfs_client *clp = cps->clp;
+	struct nfs_server *server = NULL;
+
+	dprintk("%s: -->\n", __func__);
+
+	if (!clp) {
+		res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
+		goto out;
+	}
+
+	for (i = 0; i < args->ndevs; i++) {
+		struct cb_devicenotifyitem *dev = &args->devs[i];
+
+		if (!server ||
+		    server->pnfs_curr_ld->id != dev->cbd_layout_type) {
+			rcu_read_lock();
+			list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+				if (server->pnfs_curr_ld &&
+				    server->pnfs_curr_ld->id == dev->cbd_layout_type) {
+					rcu_read_unlock();
+					goto found;
+				}
+			rcu_read_unlock();
+			dprintk("%s: layout type %u not found\n",
+				__func__, dev->cbd_layout_type);
+			continue;
+		}
+
+	found:
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+			dprintk("%s: NOTIFY_DEVICEID4_CHANGE not supported, "
+				"deleting instead\n", __func__);
+		nfs4_delete_deviceid(clp, &dev->cbd_dev_id);
+	}
+
+out:
+	kfree(args->devs);
+	dprintk("%s: exit with status = %u\n",
+		__func__, be32_to_cpu(res));
+	return res;
+}
+
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
 {
 	if (delegation == NULL)
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 00ecf62..c6c86a7 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -25,6 +25,7 @@
 
 #if defined(CONFIG_NFS_V4_1)
 #define CB_OP_LAYOUTRECALL_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
+#define CB_OP_DEVICENOTIFY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #define CB_OP_SEQUENCE_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ + \
 					4 + 1 + 3)
 #define CB_OP_RECALLANY_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
@@ -284,6 +285,93 @@ out:
 	return status;
 }
 
+static
+__be32 decode_devicenotify_args(struct svc_rqst *rqstp,
+				struct xdr_stream *xdr,
+				struct cb_devicenotifyargs *args)
+{
+	__be32 *p;
+	__be32 status = 0;
+	u32 tmp;
+	int n, i;
+	args->ndevs = 0;
+
+	/* Num of device notifications */
+	p = read_buf(xdr, sizeof(uint32_t));
+	if (unlikely(p == NULL)) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
+	n = ntohl(*p++);
+	if (n <= 0)
+		goto out;
+
+	args->devs = kmalloc(n * sizeof(*args->devs), GFP_KERNEL);
+	if (!args->devs) {
+		status = htonl(NFS4ERR_DELAY);
+		goto out;
+	}
+
+	/* Decode each dev notification */
+	for (i = 0; i < n; i++) {
+		struct cb_devicenotifyitem *dev = &args->devs[i];
+
+		p = read_buf(xdr, (4 * sizeof(uint32_t)) + NFS4_DEVICEID4_SIZE);
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_BADXDR);
+			goto err;
+		}
+
+		tmp = ntohl(*p++);	/* bitmap size */
+		if (tmp != 1) {
+			status = htonl(NFS4ERR_INVAL);
+			goto err;
+		}
+		dev->cbd_notify_type = ntohl(*p++);
+		if (dev->cbd_notify_type != NOTIFY_DEVICEID4_CHANGE &&
+		    dev->cbd_notify_type != NOTIFY_DEVICEID4_DELETE) {
+			status = htonl(NFS4ERR_INVAL);
+			goto err;
+		}
+
+		tmp = ntohl(*p++);	/* opaque size */
+		if (((dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) &&
+		     (tmp != NFS4_DEVICEID4_SIZE + 8)) ||
+		    ((dev->cbd_notify_type == NOTIFY_DEVICEID4_DELETE) &&
+		     (tmp != NFS4_DEVICEID4_SIZE + 4))) {
+			status = htonl(NFS4ERR_INVAL);
+			goto err;
+		}
+		dev->cbd_layout_type = ntohl(*p++);
+		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
+		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
+
+		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
+			p = read_buf(xdr, sizeof(uint32_t));
+			if (unlikely(p == NULL)) {
+				status = htonl(NFS4ERR_BADXDR);
+				goto err;
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
+err:
+	kfree(args->devs);
+	goto out;
+}
+
 static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
@@ -639,10 +727,10 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 	case OP_CB_RECALL_ANY:
 	case OP_CB_RECALL_SLOT:
 	case OP_CB_LAYOUTRECALL:
+	case OP_CB_NOTIFY_DEVICEID:
 		*op = &callback_ops[op_nr];
 		break;
 
-	case OP_CB_NOTIFY_DEVICEID:
 	case OP_CB_NOTIFY:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
@@ -849,6 +937,12 @@ static struct callback_op callback_ops[] = {
 			(callback_decode_arg_t)decode_layoutrecall_args,
 		.res_maxsize = CB_OP_LAYOUTRECALL_RES_MAXSZ,
 	},
+	[OP_CB_NOTIFY_DEVICEID] = {
+		.process_op = (callback_process_op_t)nfs4_callback_devicenotify,
+		.decode_args =
+			(callback_decode_arg_t)decode_devicenotify_args,
+		.res_maxsize = CB_OP_DEVICENOTIFY_RES_MAXSZ,
+	},
 	[OP_CB_SEQUENCE] = {
 		.process_op = (callback_process_op_t)nfs4_callback_sequence,
 		.decode_args = (callback_decode_arg_t)decode_cb_sequence_args,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 80a5d0e..fbd3f7c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -173,6 +173,7 @@ struct nfs4_deviceid_node {
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 struct nfs4_deviceid_node *nfs4_unhash_put_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_delete_deviceid(const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
 			     const struct pnfs_layoutdriver_type *,
 			     const struct nfs_client *,
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 64a4b85..8fd3839 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -66,6 +66,23 @@ nfs4_deviceid_hash(const struct nfs4_deviceid *id)
 	return x & NFS4_DEVICE_ID_HASH_MASK;
 }
 
+static struct nfs4_deviceid_node *
+_lookup_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
+		 long hash)
+{
+	struct nfs4_deviceid_node *d;
+	struct hlist_node *n;
+
+	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
+		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
+			if (atomic_read(&d->ref))
+				return d;
+			else
+				continue;
+		}
+	return NULL;
+}
+
 /*
  * Lookup a deviceid in cache and get a reference count on it if found
  *
@@ -73,26 +90,76 @@ nfs4_deviceid_hash(const struct nfs4_deviceid *id)
  * @id deviceid to look up
  */
 struct nfs4_deviceid_node *
+_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id,
+		   long hash)
+{
+	struct nfs4_deviceid_node *d;
+
+	rcu_read_lock();
+	d = _lookup_deviceid(clp, id, hash);
+	if (d && !atomic_inc_not_zero(&d->ref))
+		d = NULL;
+	rcu_read_unlock();
+	return d;
+}
+
+struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
 {
+	return _find_get_deviceid(clp, id, nfs4_deviceid_hash(id));
+}
+EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
+
+/*
+ * Unhash and put deviceid
+ *
+ * @clp nfs_client associated with deviceid
+ * @id the deviceid to unhash
+ *
+ * @ret the unhashed node, if found and dereferenced to zero, NULL otherwise.
+ */
+struct nfs4_deviceid_node *
+nfs4_unhash_put_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+{
 	struct nfs4_deviceid_node *d;
-	struct hlist_node *n;
-	long hash = nfs4_deviceid_hash(id);
 
+	spin_lock(&nfs4_deviceid_lock);
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node) {
-		if (d->nfs_client == clp && !memcmp(&d->deviceid, id, sizeof(*id))) {
-			if (!atomic_inc_not_zero(&d->ref))
-				goto fail;
-			rcu_read_unlock();
-			return d;
-		}
-	}
-fail:
+	d = _lookup_deviceid(clp, id, nfs4_deviceid_hash(id));
 	rcu_read_unlock();
+	if (!d) {
+		spin_unlock(&nfs4_deviceid_lock);
+		return NULL;
+	}
+	hlist_del_init_rcu(&d->node);
+	spin_unlock(&nfs4_deviceid_lock);
+	synchronize_rcu();
+
+	/* balance the initial ref set in pnfs_insert_deviceid */
+	if (atomic_dec_and_test(&d->ref))
+		return d;
+
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
+EXPORT_SYMBOL_GPL(nfs4_unhash_put_deviceid);
+
+/*
+ * Delete a deviceid from cache
+ *
+ * @clp struct nfs_client qualifying the deviceid
+ * @id deviceid to delete
+ */
+void
+nfs4_delete_deviceid(const struct nfs_client *clp, const struct nfs4_deviceid *id)
+{
+	struct nfs4_deviceid_node *d;
+
+	d = nfs4_unhash_put_deviceid(clp, id);
+	if (!d)
+		return;
+	d->ld->free_deviceid_node(d);
+}
+EXPORT_SYMBOL_GPL(nfs4_delete_deviceid);
 
 void
 nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
@@ -126,13 +193,13 @@ nfs4_insert_deviceid_node(struct nfs4_deviceid_node *new)
 	long hash;
 
 	spin_lock(&nfs4_deviceid_lock);
-	d = nfs4_find_get_deviceid(new->nfs_client, &new->deviceid);
+	hash = nfs4_deviceid_hash(&new->deviceid);
+	d = _find_get_deviceid(new->nfs_client, &new->deviceid, hash);
 	if (d) {
 		spin_unlock(&nfs4_deviceid_lock);
 		return d;
 	}
 
-	hash = nfs4_deviceid_hash(&new->deviceid);
 	hlist_add_head_rcu(&new->node, &nfs4_deviceid_cache[hash]);
 	spin_unlock(&nfs4_deviceid_lock);
 
-- 
1.7.2.3

