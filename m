Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28781 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154Ab1BNTbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:31:39 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] SQUASHME pnfs_submit wave3 general cleanup
Date: Mon, 14 Feb 2011 14:31:48 -0500
Message-Id: <1297711909-27015-2-git-send-email-andros@netapp.com>
In-Reply-To: <1297711909-27015-1-git-send-email-andros@netapp.com>
References: <1297711909-27015-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |   11 ++++++-----
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 fs/nfs/nfs4proc.c          |    2 +-
 fs/nfs/pagelist.c          |    5 +++--
 fs/nfs/pnfs.h              |    1 +
 fs/nfs/read.c              |   20 +++++++-------------
 6 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 17da633..78e6ebe 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -490,11 +490,12 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *nfs_get_client(struct nfs_client_initdata *cl_init,
-					 const struct rpc_timeout *timeparms,
-					 const char *ip_addr,
-					 rpc_authflavor_t authflavour,
-					 int noresvport)
+static struct nfs_client *
+nfs_get_client(const struct nfs_client_initdata *cl_init,
+	       const struct rpc_timeout *timeparms,
+	       const char *ip_addr,
+	       rpc_authflavor_t authflavour,
+	       int noresvport)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index b8c3681..1e1c536 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -586,8 +586,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		struct nfs_server *s = NFS_SERVER(lseg->pls_layout->plh_inode);
 		int err;
 
-		/* Already tried to connect, don't try again */
 		if (dsaddr->deviceid.de_flags & NFS4_DEVICE_ID_NEG_ENTRY) {
+			/* Already tried to connect, don't try again */
 			dprintk("%s Deviceid marked out of use\n", __func__);
 			return NULL;
 		}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aab3efd..0f73db0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3111,7 +3111,7 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 /* Reset the the nfs_read_data to send the read to the MDS. */
 void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 {
-	dprintk("%s Reset task for i/o through \n", __func__);
+	dprintk("%s Reset task for i/o through\n", __func__);
 	/* offsets will differ in the dense stripe case */
 	data->args.offset = data->mds_offset;
 	data->ds_clp = NULL;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f0aa20b..2c793a7 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -257,8 +257,9 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 		return 0;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return 0;
-	/* For non-whole file layouts, need to check that req is inside of
-	 * pgio->pg_test.
+	/*
+	 * Non-whole file layouts need to check that req is inside of
+	 * pgio->pg_lseg.
 	 */
 	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
 		return 0;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d2d708a..a760363 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -194,6 +194,7 @@ void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 
+
 static inline int lo_fail_bit(u32 iomode)
 {
 	return iomode == IOMODE_RW ?
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 896dc4e..9447156 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -22,7 +22,6 @@
 #include <linux/module.h>
 
 #include <asm/system.h>
-#include <linux/module.h>
 #include "pnfs.h"
 
 #include "nfs4_fs.h"
@@ -185,7 +184,8 @@ int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 	/* Set up the initial task struct. */
 	NFS_PROTO(inode)->read_setup(data, &msg);
 
-	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
+	dprintk("NFS: %5u initiated read call (req %s/%lld, %u bytes @ "
+			"offset %llu)\n",
 			data->task.tk_pid,
 			inode->i_sb->s_id,
 			(long long)NFS_FILEID(inode),
@@ -200,16 +200,6 @@ int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL(nfs_initiate_read);
 
-static int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
-		       const struct rpc_call_ops *call_ops)
-{
-	if (data->lseg &&
-	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
-		return 0;
-
-	return nfs_initiate_read(data, clnt, call_ops);
-}
-
 /*
  * Set up the NFS read request struct
  */
@@ -238,7 +228,11 @@ static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	data->res.eof     = 0;
 	nfs_fattr_init(&data->fattr);
 
-	return pnfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
+	if (data->lseg &&
+	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
+		return 0;
+
+	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
 }
 
 static void
-- 
1.6.6

