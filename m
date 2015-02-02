Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57103 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965042AbbBBWjb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:39:31 -0500
Received: by mail-pa0-f50.google.com with SMTP id rd3so87849082pab.9
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:39:30 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 05/53] nfs41: pull nfs4_ds_connect from file layout to generic pnfs
Date: Mon,  2 Feb 2015 14:38:19 -0800
Message-Id: <1422916747-86649-6-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

It can be reused by flexfiles layout client.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayoutdev.c | 78 +++----------------------------------
 fs/nfs/pnfs.h                     |  3 ++
 fs/nfs/pnfs_nfs.c                 | 81 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 89 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index c7f6041..27bdd8c 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -41,51 +41,6 @@
 static unsigned int dataserver_timeo = NFS4_DEF_DS_TIMEO;
 static unsigned int dataserver_retrans = NFS4_DEF_DS_RETRANS;
 
-/*
- * Create an rpc connection to the nfs4_pnfs_ds data server
- * Currently only supports IPv4 and IPv6 addresses
- */
-static int
-nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
-{
-	struct nfs_client *clp = ERR_PTR(-EIO);
-	struct nfs4_pnfs_ds_addr *da;
-	int status = 0;
-
-	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
-		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
-
-	list_for_each_entry(da, &ds->ds_addrs, da_node) {
-		dprintk("%s: DS %s: trying address %s\n",
-			__func__, ds->ds_remotestr, da->da_remotestr);
-
-		clp = nfs4_set_ds_client(mds_srv->nfs_client,
-					(struct sockaddr *)&da->da_addr,
-					da->da_addrlen, IPPROTO_TCP,
-					dataserver_timeo, dataserver_retrans);
-		if (!IS_ERR(clp))
-			break;
-	}
-
-	if (IS_ERR(clp)) {
-		status = PTR_ERR(clp);
-		goto out;
-	}
-
-	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
-	if (status)
-		goto out_put;
-
-	smp_wmb();
-	ds->ds_clp = clp;
-	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
-out:
-	return status;
-out_put:
-	nfs_put_client(clp);
-	goto out;
-}
-
 void
 nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
 {
@@ -302,22 +257,7 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
 	return flseg->fh_array[i];
 }
 
-static void nfs4_wait_ds_connect(struct nfs4_pnfs_ds *ds)
-{
-	might_sleep();
-	wait_on_bit_action(&ds->ds_state, NFS4DS_CONNECTING,
-			   nfs_wait_bit_killable, TASK_KILLABLE);
-}
-
-static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
-{
-	smp_mb__before_atomic();
-	clear_bit(NFS4DS_CONNECTING, &ds->ds_state);
-	smp_mb__after_atomic();
-	wake_up_bit(&ds->ds_state, NFS4DS_CONNECTING);
-}
-
-
+/* Upon return, either ds is connected, or ds is NULL */
 struct nfs4_pnfs_ds *
 nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 {
@@ -325,6 +265,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	struct nfs4_pnfs_ds *ds = dsaddr->ds_list[ds_idx];
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs4_pnfs_ds *ret = ds;
+	struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 
 	if (ds == NULL) {
 		printk(KERN_ERR "NFS: %s: No data server for offset index %d\n",
@@ -336,18 +277,9 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 	if (ds->ds_clp)
 		goto out_test_devid;
 
-	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
-		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
-		int err;
-
-		err = nfs4_ds_connect(s, ds);
-		if (err)
-			nfs4_mark_deviceid_unavailable(devid);
-		nfs4_clear_ds_conn_bit(ds);
-	} else {
-		/* Either ds is connected, or ds is NULL */
-		nfs4_wait_ds_connect(ds);
-	}
+	nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
+			     dataserver_retrans);
+
 out_test_devid:
 	if (filelayout_test_devid_unavailable(devid))
 		ret = NULL;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 403d7bb..9a8937c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -312,6 +312,9 @@ void pnfs_generic_write_commit_done(struct rpc_task *task, void *data);
 void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
 				      gfp_t gfp_flags);
+void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
+			  struct nfs4_deviceid_node *devid, unsigned int timeo,
+			  unsigned int retrans);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 81ec449..5a92e76 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -11,6 +11,7 @@
 #include <linux/nfs_page.h>
 #include <linux/sunrpc/addr.h>
 
+#include "nfs4session.h"
 #include "internal.h"
 #include "pnfs.h"
 
@@ -534,6 +535,86 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_add);
 
+static void nfs4_wait_ds_connect(struct nfs4_pnfs_ds *ds)
+{
+	might_sleep();
+	wait_on_bit(&ds->ds_state, NFS4DS_CONNECTING,
+			TASK_KILLABLE);
+}
+
+static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
+{
+	smp_mb__before_atomic();
+	clear_bit(NFS4DS_CONNECTING, &ds->ds_state);
+	smp_mb__after_atomic();
+	wake_up_bit(&ds->ds_state, NFS4DS_CONNECTING);
+}
+
+static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
+				 struct nfs4_pnfs_ds *ds,
+				 unsigned int timeo,
+				 unsigned int retrans)
+{
+	struct nfs_client *clp = ERR_PTR(-EIO);
+	struct nfs4_pnfs_ds_addr *da;
+	int status = 0;
+
+	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
+		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
+
+	list_for_each_entry(da, &ds->ds_addrs, da_node) {
+		dprintk("%s: DS %s: trying address %s\n",
+			__func__, ds->ds_remotestr, da->da_remotestr);
+
+		clp = nfs4_set_ds_client(mds_srv->nfs_client,
+					(struct sockaddr *)&da->da_addr,
+					da->da_addrlen, IPPROTO_TCP,
+					timeo, retrans);
+		if (!IS_ERR(clp))
+			break;
+	}
+
+	if (IS_ERR(clp)) {
+		status = PTR_ERR(clp);
+		goto out;
+	}
+
+	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
+	if (status)
+		goto out_put;
+
+	smp_wmb();
+	ds->ds_clp = clp;
+	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
+out:
+	return status;
+out_put:
+	nfs_put_client(clp);
+	goto out;
+}
+
+/*
+ * Create an rpc connection to the nfs4_pnfs_ds data server.
+ * Currently only supports IPv4 and IPv6 addresses.
+ * If connection fails, make devid unavailable.
+ */
+void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
+			  struct nfs4_deviceid_node *devid, unsigned int timeo,
+			  unsigned int retrans)
+{
+	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
+		int err = 0;
+
+		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo, retrans);
+		if (err)
+			nfs4_mark_deviceid_unavailable(devid);
+		nfs4_clear_ds_conn_bit(ds);
+	} else {
+		nfs4_wait_ds_connect(ds);
+	}
+}
+EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_connect);
+
 /*
  * Currently only supports ipv4, ipv6 and one multi-path address.
  */
-- 
1.9.3

