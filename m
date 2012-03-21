Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57390 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000Ab2CUTqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:55 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 10/12] NFSv4.1 de reference a disconnected data server client record
Date: Wed, 21 Mar 2012 15:46:22 -0400
Message-Id: <1332359184-1887-11-git-send-email-andros@netapp.com>
In-Reply-To: <1332359184-1887-1-git-send-email-andros@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When the last DS io is processed, the data server client record will be
freed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |    4 ++++
 fs/nfs/nfs4filelayout.h    |    1 +
 fs/nfs/nfs4filelayoutdev.c |   17 +++++++++++++++++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 129b57f..ee0159b 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -209,10 +209,12 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 			reset, data->ds_clp, data->ds_clp->cl_session);
 
 		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
+			struct nfs_client *clp = data->ds_clp;
 			filelayout_reset_read(task, data);
 			if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
 				filelayout_mark_devid_invalid(devid);
 				rpc_wake_up(&tbl->slot_tbl_waitq);
+				nfs4_ds_disconnect(clp);
 			}
 		}
 		rpc_restart_call_prepare(task);
@@ -304,10 +306,12 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 			reset, data->ds_clp, data->ds_clp->cl_session);
 
 		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
+			struct nfs_client *clp = data->ds_clp;
 			filelayout_reset_write(task, data);
 			if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
 				filelayout_mark_devid_invalid(devid);
 				rpc_wake_up(&tbl->slot_tbl_waitq);
+				nfs4_ds_disconnect(clp);
 			}
 		}
 		rpc_restart_call_prepare(task);
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 08b667a..3abf7d9 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -138,5 +138,6 @@ extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
+void nfs4_ds_disconnect(struct nfs_client *clp);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 2b8ae96..0e54cdf 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -145,6 +145,23 @@ _data_server_lookup_locked(const struct list_head *dsaddrs)
 }
 
 /*
+ * Lookup DS by nfs_client pointer. Zero data server client pointer
+ */
+void nfs4_ds_disconnect(struct nfs_client *clp)
+{
+	struct nfs4_pnfs_ds *ds;
+
+	dprintk("%s clp %p\n", __func__, clp);
+	spin_lock(&nfs4_ds_cache_lock);
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
+		if (ds->ds_clp && ds->ds_clp == clp) {
+			nfs_put_client(clp);
+			ds->ds_clp = NULL;
+		}
+	spin_unlock(&nfs4_ds_cache_lock);
+}
+
+/*
  * Create an rpc connection to the nfs4_pnfs_ds data server
  * Currently only supports IPv4 and IPv6 addresses
  */
-- 
1.7.6.4

