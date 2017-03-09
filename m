Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36630 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754884AbdCIR5H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 12:57:07 -0500
Received: by mail-it0-f68.google.com with SMTP id w185so10827264ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Mar 2017 09:56:51 -0800 (PST)
From: Weston Andros Adamson <dros@monkey.org>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 1/2] pNFS: return status from nfs4_pnfs_ds_connect
Date: Thu,  9 Mar 2017 12:56:48 -0500
Message-Id: <20170309175649.8914-1-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs4_pnfs_ds_connect path can call rpc_create which can fail or it
can wait on another context to reach the same failure.

This checks that the rpc_create succeeded and returns the error to the
caller.

When an error is returned, both the files and flexfiles layouts will return
NULL from _prepare_ds(). The flexfiles layout will also return the layout
with the error NFS4ERR_NXIO.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/client.c                           | 25 ++++++++++++++++++++++++-
 fs/nfs/filelayout/filelayoutdev.c         |  7 ++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 ++-
 fs/nfs/internal.h                         |  2 ++
 fs/nfs/pnfs.h                             |  2 +-
 fs/nfs/pnfs_nfs.c                         | 15 +++++++++++++--
 6 files changed, 48 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 91a8d610ba0f..390ada8741bc 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -325,10 +325,33 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 	return NULL;
 }
 
-static bool nfs_client_init_is_complete(const struct nfs_client *clp)
+/*
+ * Return true if @clp is done initializing, false if still working on it.
+ *
+ * Use nfs_client_init_status to check if it was successful.
+ */
+bool nfs_client_init_is_complete(const struct nfs_client *clp)
 {
 	return clp->cl_cons_state <= NFS_CS_READY;
 }
+EXPORT_SYMBOL_GPL(nfs_client_init_is_complete);
+
+/*
+ * Return 0 if @clp was successfully initialized, -errno otherwise.
+ *
+ * This must be called *after* nfs_client_init_is_complete() returns true,
+ * otherwise it will pop WARN_ON_ONCE and return -EINVAL
+ */
+int nfs_client_init_status(const struct nfs_client *clp)
+{
+	/* called without checking nfs_client_init_is_complete */
+	if (clp->cl_cons_state > NFS_CS_READY) {
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+	return clp->cl_cons_state;
+}
+EXPORT_SYMBOL_GPL(nfs_client_init_status);
 
 int nfs_wait_client_init_complete(const struct nfs_client *clp)
 {
diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index f956ca20a8a3..188120626179 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -266,6 +266,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs4_pnfs_ds *ret = ds;
 	struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
+	int status;
 
 	if (ds == NULL) {
 		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
@@ -277,9 +278,13 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	if (ds->ds_clp)
 		goto out_test_devid;
 
-	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
+	status = nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
 			     dataserver_retrans, 4,
 			     s->nfs_client->cl_minorversion);
+	if (status) {
+		ret = NULL;
+		goto out;
+	}
 
 out_test_devid:
 	if (ret->ds_clp == NULL ||
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index e5a6f248697b..544e7725e679 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -384,6 +384,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	struct inode *ino = lseg->pls_layout->plh_inode;
 	struct nfs_server *s = NFS_SERVER(ino);
 	unsigned int max_payload;
+	int status;
 
 	if (!ff_layout_mirror_valid(lseg, mirror, true)) {
 		pr_err_ratelimited("NFS: %s: No data server for offset index %d\n",
@@ -404,7 +405,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	/* FIXME: For now we assume the server sent only one version of NFS
 	 * to use for the DS.
 	 */
-	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
+	status = nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
 			     dataserver_retrans,
 			     mirror->mirror_ds->ds_versions[0].version,
 			     mirror->mirror_ds->ds_versions[0].minor_version);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 09ca5095c04e..7b38fedb7e03 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -186,6 +186,8 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
 					   struct nfs_fattr *,
 					   rpc_authflavor_t);
+extern bool nfs_client_init_is_complete(const struct nfs_client *clp);
+extern int nfs_client_init_status(const struct nfs_client *clp);
 extern int nfs_wait_client_init_complete(const struct nfs_client *clp);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 63f77b49a586..590e1e35781f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -367,7 +367,7 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
 				      gfp_t gfp_flags);
 void nfs4_pnfs_v3_ds_connect_unload(void);
-void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
+int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
 			  unsigned int retrans, u32 version, u32 minor_version);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 9414b492439f..a7691b927af6 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -745,9 +745,9 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 /*
  * Create an rpc connection to the nfs4_pnfs_ds data server.
  * Currently only supports IPv4 and IPv6 addresses.
- * If connection fails, make devid unavailable.
+ * If connection fails, make devid unavailable and return a -errno.
  */
-void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
+int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
 			  unsigned int retrans, u32 version, u32 minor_version)
 {
@@ -772,6 +772,17 @@ void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 	} else {
 		nfs4_wait_ds_connect(ds);
 	}
+
+	/*
+	 * At this point the ds->ds_clp should be ready, but it might have
+	 * hit an error.
+	 */
+	if (!ds->ds_clp || !nfs_client_init_is_complete(ds->ds_clp)) {
+		WARN_ON_ONCE(1);
+		return -EINVAL;
+	}
+
+	return nfs_client_init_status(ds->ds_clp);
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_connect);
 
-- 
2.10.1 (Apple Git-78)

