Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31751 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932170Ab2IUUve (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:51:34 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/26] NFSv4.1: pNFS data servers may be temporarily offline
Date: Fri, 21 Sep 2012 16:50:03 -0400
Message-Id: <1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cases where the pNFS data server is just temporarily out of service,
we want to mark it as such, and then try again later. Typically that will
be in cases of network connection errors etc.
This patch allows us to mark the devices as being "unavailable" for such
transient errors, and will make them available for retries after a
2 minute timeout period.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c    | 22 +++++++++++++++++++---
 fs/nfs/nfs4filelayout.h    |  8 ++------
 fs/nfs/nfs4filelayoutdev.c | 15 +++++++--------
 fs/nfs/pnfs.h              |  4 ++++
 fs/nfs/pnfs_dev.c          | 27 +++++++++++++++++++++++++++
 5 files changed, 59 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index af6ee4a..dac2162 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -205,7 +205,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -EPIPE:
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
-		filelayout_mark_devid_invalid(devid);
+		nfs4_mark_deviceid_unavailable(devid);
 		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
 		_pnfs_return_layout(inode);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
@@ -269,6 +269,22 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
 
+bool
+filelayout_test_devid_unavailable(struct nfs4_deviceid_node *node)
+{
+	return filelayout_test_devid_invalid(node) ||
+		nfs4_test_deviceid_unavailable(node);
+}
+
+static bool
+filelayout_reset_to_mds(struct pnfs_layout_segment *lseg)
+{
+	struct nfs4_deviceid_node *node = FILELAYOUT_DEVID_NODE(lseg);
+
+	return filelayout_test_layout_invalid(lseg->pls_layout) ||
+		filelayout_test_devid_unavailable(node);
+}
+
 /*
  * Call ops for the async read/write cases
  * In the case of dense layouts, the offset needs to be reset to its
@@ -613,8 +629,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 			goto out;
 	} else
 		dsaddr = container_of(d, struct nfs4_file_layout_dsaddr, id_node);
-	/* Found deviceid is being reaped */
-	if (test_bit(NFS_DEVICEID_INVALID, &dsaddr->id_node.flags))
+	/* Found deviceid is unavailable */
+	if (filelayout_test_devid_unavailable(&dsaddr->id_node))
 			goto out_put;
 
 	fl->dsaddr = dsaddr;
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 11053c4..10b0f13 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -140,12 +140,8 @@ filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
 	return test_bit(NFS_DEVICEID_INVALID, &node->flags);
 }
 
-static inline bool
-filelayout_reset_to_mds(struct pnfs_layout_segment *lseg)
-{
-	return filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(lseg)) ||
-		filelayout_test_layout_invalid(lseg->pls_layout);
-}
+extern bool
+filelayout_test_devid_unavailable(struct nfs4_deviceid_node *node);
 
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index b85a29d..3336d5e 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -804,13 +804,14 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	struct nfs4_pnfs_ds *ds = dsaddr->ds_list[ds_idx];
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 
-	if (filelayout_test_devid_invalid(devid))
+	if (filelayout_test_devid_unavailable(devid))
 		return NULL;
 
 	if (ds == NULL) {
 		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
-		goto mark_dev_invalid;
+		filelayout_mark_devid_invalid(devid);
+		return NULL;
 	}
 
 	if (!ds->ds_clp) {
@@ -818,14 +819,12 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		int err;
 
 		err = nfs4_ds_connect(s, ds);
-		if (err)
-			goto mark_dev_invalid;
+		if (err) {
+			nfs4_mark_deviceid_unavailable(devid);
+			return NULL;
+		}
 	}
 	return ds;
-
-mark_dev_invalid:
-	filelayout_mark_devid_invalid(devid);
-	return NULL;
 }
 
 module_param(dataserver_retrans, uint, 0644);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bc8e500..9735031 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -234,6 +234,7 @@ struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 /* nfs4_deviceid_flags */
 enum {
 	NFS_DEVICEID_INVALID = 0,       /* set when MDS clientid recalled */
+	NFS_DEVICEID_UNAVAILABLE,	/* device temporarily unavailable */
 };
 
 /* pnfs_dev.c */
@@ -243,6 +244,7 @@ struct nfs4_deviceid_node {
 	const struct pnfs_layoutdriver_type *ld;
 	const struct nfs_client		*nfs_client;
 	unsigned long 			flags;
+	unsigned long			timestamp_unavailable;
 	struct nfs4_deviceid		deviceid;
 	atomic_t			ref;
 };
@@ -255,6 +257,8 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
 			     const struct nfs4_deviceid *);
 struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
+void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
+bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
 
 static inline void
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 73f701f..d35b62e 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -40,6 +40,8 @@
 #define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
 #define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
 
+#define PNFS_DEVICE_RETRY_TIMEOUT (120*HZ)
+
 static struct hlist_head nfs4_deviceid_cache[NFS4_DEVICE_ID_HASH_SIZE];
 static DEFINE_SPINLOCK(nfs4_deviceid_lock);
 
@@ -218,6 +220,30 @@ nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
 }
 EXPORT_SYMBOL_GPL(nfs4_put_deviceid_node);
 
+void
+nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node)
+{
+	node->timestamp_unavailable = jiffies;
+	set_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
+}
+EXPORT_SYMBOL_GPL(nfs4_mark_deviceid_unavailable);
+
+bool
+nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node)
+{
+	if (test_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags)) {
+		unsigned long start, end;
+
+		end = jiffies;
+		start = end - PNFS_DEVICE_RETRY_TIMEOUT;
+		if (time_in_range(node->timestamp_unavailable, start, end))
+			return true;
+		clear_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(nfs4_test_deviceid_unavailable);
+
 static void
 _deviceid_purge_client(const struct nfs_client *clp, long hash)
 {
@@ -276,3 +302,4 @@ nfs4_deviceid_mark_client_invalid(struct nfs_client *clp)
 	}
 	rcu_read_unlock();
 }
+
-- 
1.7.11.4

