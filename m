Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17814 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755371Ab0H3Qn7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:43:59 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfs-submit: get machince creds for getdeviceinfo
Date: Mon, 30 Aug 2010 19:43:56 +0300
Message-Id: <1283186636-17044-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C7BDD8C.40509@panasas.com>
References: <4C7BDD8C.40509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h  |   13 ++++++++++++-
 fs/nfs/nfs4proc.c |    2 ++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9743326..ced4a20 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -303,13 +303,24 @@ extern void nfs4_kill_renewd(struct nfs_client *);
 extern void nfs4_renew_state(struct work_struct *);
 
 /* nfs4state.c */
+struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
 #if defined(CONFIG_NFS_V4_1)
-struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp);
 struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
 #endif /* CONFIG_NFS_V4_1 */
 
+static inline struct rpc_cred *
+nfs4_get_machine_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+
+	spin_lock(&clp->cl_lock);
+	cred = nfs4_get_machine_cred_locked(clp);
+	spin_unlock(&clp->cl_lock);
+	return cred;
+}
+
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78717a7..33c4057 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5824,11 +5824,13 @@ int nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICEINFO],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
+		.rpc_cred = nfs4_get_machine_cred(server->nfs_client),
 	};
 	int status;
 
 	dprintk("--> %s\n", __func__);
 	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	put_rpccred(msg.rpc_cred);
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	return status;
-- 
1.7.2.2

