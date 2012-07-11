Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:56583 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab2GKUbB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:31:01 -0400
Received: by ghrr11 with SMTP id r11so1692583ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:31:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/15] NFS: Clean up nfs4_proc_setclientid() and friends
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:30:59 -0400
Message-ID: <20120711203058.3767.63821.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add documenting comments and appropriate debugging messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c  |   45 +++++++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4state.c |    4 ++++
 2 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f5f4e6e..43c678b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4021,6 +4021,16 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 
+/**
+ * nfs4_proc_setclientid - Negotiate client ID
+ * @clp: state data structure
+ * @program: RPC program for NFSv4 callback service
+ * @port: IP port number for NFS4 callback service
+ * @cred: RPC credential to use for this call
+ * @res: where to place the result
+ *
+ * Returns zero, a negative errno, or a negative NFS4ERR status code.
+ */
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		unsigned short port, struct rpc_cred *cred,
 		struct nfs4_setclientid_res *res)
@@ -4037,6 +4047,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
+	int status;
 
 	/* nfs_client_id4 */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
@@ -4058,9 +4069,22 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
 
-	return rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	dprintk("NFS call  setclientid auth=%s, '%.*s'\n",
+		clp->cl_rpcclient->cl_auth->au_ops->au_name,
+		setclientid.sc_name_len, setclientid.sc_name);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	dprintk("NFS reply setclientid: %d\n", status);
+	return status;
 }
 
+/**
+ * nfs4_proc_setclientid_confirm - Confirm client ID
+ * @clp: state data structure
+ * @res: result of a previous SETCLIENTID
+ * @cred: RPC credential to use for this call
+ *
+ * Returns zero, a negative errno, or a negative NFS4ERR status code.
+ */
 int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 		struct nfs4_setclientid_res *arg,
 		struct rpc_cred *cred)
@@ -4075,6 +4099,9 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 	unsigned long now;
 	int status;
 
+	dprintk("NFS call  setclientid_confirm auth=%s, (client ID %llx)\n",
+		clp->cl_rpcclient->cl_auth->au_ops->au_name,
+		clp->cl_clientid);
 	now = jiffies;
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (status == 0) {
@@ -4083,6 +4110,7 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 		clp->cl_last_renewal = now;
 		spin_unlock(&clp->cl_lock);
 	}
+	dprintk("NFS reply setclientid_confirm: %d\n", status);
 	return status;
 }
 
@@ -5226,6 +5254,8 @@ out:
 /*
  * nfs4_proc_exchange_id()
  *
+ * Returns zero, a negative errno, or a negative NFS4ERR status code.
+ *
  * Since the clientid has expired, all compounds using sessions
  * associated with the stale clientid will be returning
  * NFS4ERR_BADSESSION in the sequence operation, and will therefore
@@ -5250,15 +5280,14 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		.rpc_cred = cred,
 	};
 
-	dprintk("--> %s\n", __func__);
-	BUG_ON(clp == NULL);
-
 	nfs4_init_boot_verifier(clp, &verifier);
-
 	args.id_len = scnprintf(args.id, sizeof(args.id),
 				"%s/%s",
 				clp->cl_ipaddr,
 				clp->cl_rpcclient->cl_nodename);
+	dprintk("NFS call  exchange_id auth=%s, '%.*s'\n",
+		clp->cl_rpcclient->cl_auth->au_ops->au_name,
+		args.id_len, args.id);
 
 	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
 					GFP_NOFS);
@@ -5321,12 +5350,12 @@ out_server_scope:
 	kfree(res.server_scope);
 out:
 	if (clp->cl_implid != NULL)
-		dprintk("%s: Server Implementation ID: "
+		dprintk("NFS reply exchange_id: Server Implementation ID: "
 			"domain: %s, name: %s, date: %llu,%u\n",
-			__func__, clp->cl_implid->domain, clp->cl_implid->name,
+			clp->cl_implid->domain, clp->cl_implid->name,
 			clp->cl_implid->date.seconds,
 			clp->cl_implid->date.nseconds);
-	dprintk("<-- %s status= %d\n", __func__, status);
+	dprintk("NFS reply exchange_id: %d\n", status);
 	return status;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b83c66b..0d4c0c6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1647,6 +1647,10 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 	return 0;
 }
 
+/*
+ * Returns zero or a negative errno.  NFS4ERR values are converted
+ * to local errno values.
+ */
 static int nfs4_reclaim_lease(struct nfs_client *clp)
 {
 	struct rpc_cred *cred;

