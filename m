From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 03/39] nfs41: Refactor nfs4_{init,destroy}_callback for nfs4.0
Date: Fri,  1 May 2009 02:19:22 +0300
Message-ID: <1241133562-382-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1559 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753457AbZD3XTe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:19:34 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor-out code to bring the callback service up and down.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |   46 +++++++++++++++++++++++++++++++++++++---------
 1 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 3e232bf..d9657d4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -47,6 +47,9 @@
 #include "internal.h"
 #include "fscache.h"
 
+static int nfs4_init_callback(struct nfs_client *);
+static void nfs4_destroy_callback(struct nfs_client *);
+
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 static DEFINE_SPINLOCK(nfs_client_lock);
@@ -121,11 +124,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	clp->rpc_ops = cl_init->rpc_ops;
 
-	if (cl_init->rpc_ops->version == 4) {
-		if (nfs_callback_up() < 0)
-			goto error_2;
-		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
-	}
+	if (nfs4_init_callback(clp) < 0)
+		goto error_2;
 
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
@@ -162,8 +162,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	return clp;
 
 error_3:
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down();
+	nfs4_destroy_callback(clp);
 error_2:
 	kfree(clp);
 error_0:
@@ -184,6 +183,17 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 }
 
 /*
+ * Destroy the NFS4 callback service
+ */
+static void nfs4_destroy_callback(struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4
+	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
+		nfs_callback_down();
+#endif /* CONFIG_NFS_V4 */
+}
+
+/*
  * Clears/puts all minor version specific parts from an nfs_client struct
  * reverting it to minorversion 0.
  */
@@ -215,8 +225,7 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (!IS_ERR(clp->cl_rpcclient))
 		rpc_shutdown_client(clp->cl_rpcclient);
 
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down();
+	nfs4_destroy_callback(clp);
 
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
@@ -1088,6 +1097,25 @@ error:
 
 #ifdef CONFIG_NFS_V4
 /*
+ * Initialize the NFS4 callback service
+ */
+static int nfs4_init_callback(struct nfs_client *clp)
+{
+	int error;
+
+	if (clp->rpc_ops->version == 4) {
+		error = nfs_callback_up();
+		if (error < 0) {
+			dprintk("%s: failed to start callback. Error = %d\n",
+				__func__, error);
+			return error;
+		}
+		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+	}
+	return 0;
+}
+
+/*
  * Initialize the minor version specific parts of an NFS4 client record
  */
 static int nfs4_init_client_minor_version(struct nfs_client *clp)
-- 
1.6.2.1

