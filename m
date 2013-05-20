Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36180 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489Ab3ETRR7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 May 2013 13:17:59 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] NFSv4.1: Use layout credentials for get_deviceinfo calls
Date: Mon, 20 May 2013 13:17:06 -0400
Message-Id: <1369070227-40671-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1369070227-40671-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
 <1369070227-40671-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is not strictly needed, since get_deviceinfo is not allowed to
return NFS4ERR_ACCESS or NFS4ERR_WRONG_CRED, but lets do it anyway
for consistency with other pNFS operations.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |  2 +-
 fs/nfs/nfs4filelayout.c          |  3 ++-
 fs/nfs/nfs4filelayout.h          |  3 ++-
 fs/nfs/nfs4filelayoutdev.c       |  7 +++++--
 fs/nfs/nfs4proc.c                | 11 ++++++++---
 fs/nfs/objlayout/objlayout.c     |  3 ++-
 fs/nfs/pnfs.h                    |  3 ++-
 7 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 434b93e..1e5fdd3 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1091,7 +1091,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 	dev->mincount = 0;
 
 	dprintk("%s: dev_id: %s\n", __func__, dev->dev_id.data);
-	rc = nfs4_proc_getdeviceinfo(server, dev);
+	rc = nfs4_proc_getdeviceinfo(server, dev, NULL);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc) {
 		rv = ERR_PTR(rc);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 22d1062..17ed87e 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -643,7 +643,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode)->pnfs_curr_ld,
 				   NFS_SERVER(lo->plh_inode)->nfs_client, id);
 	if (d == NULL) {
-		dsaddr = filelayout_get_device_info(lo->plh_inode, id, gfp_flags);
+		dsaddr = filelayout_get_device_info(lo->plh_inode, id,
+				lo->plh_lc_cred, gfp_flags);
 		if (dsaddr == NULL)
 			goto out;
 	} else
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 235ff95..cebd20e 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -150,6 +150,7 @@ struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
-filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
+filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id,
+		struct rpc_cred *cred, gfp_t gfp_flags);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 661a0f6..0493dbd 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -668,7 +668,10 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_fl
  * of available devices, and return it.
  */
 struct nfs4_file_layout_dsaddr *
-filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags)
+filelayout_get_device_info(struct inode *inode,
+		struct nfs4_deviceid *dev_id,
+		struct rpc_cred *cred,
+		gfp_t gfp_flags)
 {
 	struct pnfs_device *pdev = NULL;
 	u32 max_resp_sz;
@@ -709,7 +712,7 @@ filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gf
 	pdev->pglen = max_resp_sz;
 	pdev->mincount = 0;
 
-	rc = nfs4_proc_getdeviceinfo(server, pdev);
+	rc = nfs4_proc_getdeviceinfo(server, pdev, cred);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc)
 		goto out_free;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4f42f49..7cdc706 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6547,7 +6547,9 @@ int nfs4_proc_getdevicelist(struct nfs_server *server,
 EXPORT_SYMBOL_GPL(nfs4_proc_getdevicelist);
 
 static int
-_nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
+_nfs4_proc_getdeviceinfo(struct nfs_server *server,
+		struct pnfs_device *pdev,
+		struct rpc_cred *cred)
 {
 	struct nfs4_getdeviceinfo_args args = {
 		.pdev = pdev,
@@ -6559,6 +6561,7 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICEINFO],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
+		.rpc_cred = cred,
 	};
 	int status;
 
@@ -6569,14 +6572,16 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 	return status;
 }
 
-int nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
+int nfs4_proc_getdeviceinfo(struct nfs_server *server,
+		struct pnfs_device *pdev,
+		struct rpc_cred *cred)
 {
 	struct nfs4_exception exception = { };
 	int err;
 
 	do {
 		err = nfs4_handle_exception(server,
-					_nfs4_proc_getdeviceinfo(server, pdev),
+					_nfs4_proc_getdeviceinfo(server, pdev, cred),
 					&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index a9ebd81..1989908 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -614,7 +614,8 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
 	pd.pglen = PAGE_SIZE;
 	pd.mincount = 0;
 
-	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
+	err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd,
+			pnfslay->plh_lc_cred);
 	dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
 	if (err)
 		goto err_out;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f5f8a47..1441dff 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -170,7 +170,8 @@ extern int nfs4_proc_getdevicelist(struct nfs_server *server,
 				   const struct nfs_fh *fh,
 				   struct pnfs_devicelist *devlist);
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
-				   struct pnfs_device *dev);
+				   struct pnfs_device *dev,
+				   struct rpc_cred *cred);
 extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
-- 
1.8.1.4

