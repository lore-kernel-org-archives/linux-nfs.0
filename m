Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24513 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611Ab2D0Vpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:35 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 12/13] NFSv4.1 dereference a disconnected data server client record
Date: Fri, 27 Apr 2012 17:53:52 -0400
Message-Id: <1335563633-7191-13-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When the last DS io is processed, the data server client record will be
freed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c    |    1 +
 fs/nfs/nfs4filelayout.h    |    1 +
 fs/nfs/nfs4filelayoutdev.c |   22 ++++++++++++++++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index eb8eb00..eaaca89 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -196,6 +196,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 			_pnfs_return_layout(state->inode);
 		filelayout_mark_devid_invalid(devid);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
+		nfs4_ds_disconnect(clp);
 		/* fall through */
 	default:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 3259be6..95562ad 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -146,5 +146,6 @@ extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
 get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
+void nfs4_ds_disconnect(struct nfs_client *clp);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index d5a92cf..0d3e35b 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -149,6 +149,28 @@ _data_server_lookup_locked(const struct list_head *dsaddrs)
 }
 
 /*
+ * Lookup DS by nfs_client pointer. Zero data server client pointer
+ */
+void nfs4_ds_disconnect(struct nfs_client *clp)
+{
+	struct nfs4_pnfs_ds *ds;
+	struct nfs_client *found = NULL;
+
+	dprintk("%s clp %p\n", __func__, clp);
+	spin_lock(&nfs4_ds_cache_lock);
+	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node)
+		if (ds->ds_clp && ds->ds_clp == clp) {
+			found = ds->ds_clp;
+			ds->ds_clp = NULL;
+		}
+	spin_unlock(&nfs4_ds_cache_lock);
+	if (found) {
+		set_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state);
+		nfs_put_client(clp);
+	}
+}
+
+/*
  * Create an rpc connection to the nfs4_pnfs_ds data server
  * Currently only supports IPv4 and IPv6 addresses
  */
-- 
1.7.6.4

