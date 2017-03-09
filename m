Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34851 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754890AbdCIR5H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 12:57:07 -0500
Received: by mail-it0-f68.google.com with SMTP id f203so10818306itf.2
        for <linux-nfs@vger.kernel.org>; Thu, 09 Mar 2017 09:56:53 -0800 (PST)
From: Weston Andros Adamson <dros@monkey.org>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/2] pNFS/flexfiles: never nfs4_mark_deviceid_unavailable
Date: Thu,  9 Mar 2017 12:56:49 -0500
Message-Id: <20170309175649.8914-2-dros@primarydata.com>
In-Reply-To: <20170309175649.8914-1-dros@primarydata.com>
References: <20170309175649.8914-1-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flexfiles layout should never mark a device unavailable.

Move nfs4_mark_deviceid_unavailable out of nfs4_pnfs_ds_connect and call
directly from files layout where it's still needed.

The flexfiles driver still handles marked devices in error paths, but will
now print a rate limited warning.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/filelayout/filelayoutdev.c         |  1 +
 fs/nfs/flexfilelayout/flexfilelayout.h    | 14 +++++++++++++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  2 +-
 fs/nfs/pnfs_nfs.c                         | 24 ++++++++++++++++--------
 4 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 188120626179..d913e818858f 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -282,6 +282,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 			     dataserver_retrans, 4,
 			     s->nfs_client->cl_minorversion);
 	if (status) {
+		nfs4_mark_deviceid_unavailable(devid);
 		ret = NULL;
 		goto out;
 	}
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index f4f39b0ab09b..98b34c9b0564 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -175,7 +175,19 @@ ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 static inline bool
 ff_layout_test_devid_unavailable(struct nfs4_deviceid_node *node)
 {
-	return nfs4_test_deviceid_unavailable(node);
+	/*
+	 * Flexfiles should never mark a DS unavailable, but if it does
+	 * print a (ratelimited) warning as this can affect performance.
+	 */
+	if (nfs4_test_deviceid_unavailable(node)) {
+		u32 *p = (u32 *)node->deviceid.data;
+
+		pr_warn_ratelimited("NFS: flexfiles layout referencing an "
+				"unavailable device [%x%x%x%x]\n",
+				p[0], p[1], p[2], p[3]);
+		return true;
+	}
+	return false;
 }
 
 static inline int
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 544e7725e679..85fde93dff77 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -421,11 +421,11 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			mirror->mirror_ds->ds_versions[0].wsize = max_payload;
 		goto out;
 	}
+out_fail:
 	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				 mirror, lseg->pls_range.offset,
 				 lseg->pls_range.length, NFS4ERR_NXIO,
 				 OP_ILLEGAL, GFP_NOIO);
-out_fail:
 	if (fail_return || !ff_layout_has_available_ds(lseg))
 		pnfs_error_mark_layout_for_return(ino, lseg);
 	ds = NULL;
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index a7691b927af6..7250b95549ec 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -751,9 +751,11 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
 			  unsigned int retrans, u32 version, u32 minor_version)
 {
-	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
-		int err = 0;
+	int err;
 
+again:
+	err = 0;
+	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
 		if (version == 3) {
 			err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo,
 						       retrans);
@@ -766,23 +768,29 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			err = -EPROTONOSUPPORT;
 		}
 
-		if (err)
-			nfs4_mark_deviceid_unavailable(devid);
 		nfs4_clear_ds_conn_bit(ds);
 	} else {
 		nfs4_wait_ds_connect(ds);
+
+		/* what was waited on didn't connect AND didn't mark unavail */
+		if (!ds->ds_clp && !nfs4_test_deviceid_unavailable(devid))
+			goto again;
 	}
 
 	/*
 	 * At this point the ds->ds_clp should be ready, but it might have
 	 * hit an error.
 	 */
-	if (!ds->ds_clp || !nfs_client_init_is_complete(ds->ds_clp)) {
-		WARN_ON_ONCE(1);
-		return -EINVAL;
+	if (!err) {
+		if (!ds->ds_clp || !nfs_client_init_is_complete(ds->ds_clp)) {
+			WARN_ON_ONCE(ds->ds_clp ||
+				!nfs4_test_deviceid_unavailable(devid));
+			return -EINVAL;
+		}
+		err = nfs_client_init_status(ds->ds_clp);
 	}
 
-	return nfs_client_init_status(ds->ds_clp);
+	return err;
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_connect);
 
-- 
2.10.1 (Apple Git-78)

