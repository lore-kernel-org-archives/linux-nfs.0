Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:29097 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab3IZTjm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 15:39:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>, <jlayton@redhat.com>
Subject: [PATCH 2/3] NFSv4.1: nfs4_fl_prepare_ds - fix bugs when the connect attempt fails
Date: Thu, 26 Sep 2013 15:39:26 -0400
Message-ID: <1380224367-10939-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380224367-10939-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1380224367-10939-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Fix an Oops when nfs4_ds_connect() returns an error.
- Always check the device status after waiting for a connect to complete.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 95604f6..ea2b2bf 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -801,6 +801,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	struct nfs4_file_layout_dsaddr *dsaddr = FILELAYOUT_LSEG(lseg)->dsaddr;
 	struct nfs4_pnfs_ds *ds = dsaddr->ds_list[ds_idx];
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
+	struct nfs4_pnfs_ds *ret = ds;
 
 	if (filelayout_test_devid_unavailable(devid))
 		return NULL;
@@ -809,26 +810,27 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
 		filelayout_mark_devid_invalid(devid);
-		return NULL;
+		goto out;
 	}
 	if (ds->ds_clp)
-		return ds;
+		goto out;
 
 	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 		int err;
 
 		err = nfs4_ds_connect(s, ds);
-		if (err) {
+		if (err)
 			nfs4_mark_deviceid_unavailable(devid);
-			ds = NULL;
-		}
 		nfs4_clear_ds_conn_bit(ds);
 	} else {
 		/* Either ds is connected, or ds is NULL */
 		nfs4_wait_ds_connect(ds);
 	}
-	return ds;
+	if (filelayout_test_devid_unavailable(devid))
+		ret = NULL;
+out:
+	return ret;
 }
 
 module_param(dataserver_retrans, uint, 0644);
-- 
1.8.3.1

