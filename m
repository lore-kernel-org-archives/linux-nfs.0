From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 5/6] nfs4: adjust rpc timeout for nfs_client rpc client based on the lease_time
Date: Tue,  2 Feb 2010 16:06:15 -0800
Message-ID: <1265155576-7618-6-git-send-email-batsakis@netapp.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com>
 <1265155576-7618-2-git-send-email-batsakis@netapp.com>
 <1265155576-7618-3-git-send-email-batsakis@netapp.com>
 <1265155576-7618-4-git-send-email-batsakis@netapp.com>
 <1265155576-7618-5-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933338Ab0BDUdM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:33:12 -0500
In-Reply-To: <1265155576-7618-5-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ffc84d4..efa3feb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3490,6 +3490,23 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	return _nfs4_async_handle_error(task, server, server->nfs_client, state);
 }
 
+static void nfs4_set_rpc_timeout(struct nfs_client *clp, __u32 lease_time)
+{
+	struct rpc_timeout to;
+
+	to.to_retries = NFS_DEF_TCP_RETRANS;
+	to.to_initval = lease_time * HZ / (to.to_retries + 1);
+	to.to_increment = to.to_initval;
+	to.to_maxval = to.to_initval + (to.to_increment * to.to_retries);
+	if (to.to_maxval > NFS_MAX_TCP_TIMEOUT)
+		to.to_maxval = NFS_MAX_TCP_TIMEOUT;
+	to.to_exponential = 0;
+
+	memcpy(&clp->cl_rpcclient->cl_timeout_default, &to,
+	       sizeof(clp->cl_rpcclient->cl_timeout_default));
+	clp->cl_rpcclient->cl_timeout = &clp->cl_rpcclient->cl_timeout_default;
+}
+
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short port, struct rpc_cred *cred)
 {
 	nfs4_verifier sc_verifier;
@@ -3560,6 +3577,7 @@ static int _nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cre
 	if (status == 0) {
 		spin_lock(&clp->cl_lock);
 		clp->cl_lease_time = fsinfo.lease_time * HZ;
+		nfs4_set_rpc_timeout(clp, fsinfo.lease_time);
 		clp->cl_last_renewal = now;
 		spin_unlock(&clp->cl_lock);
 	}
@@ -4578,6 +4596,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 		nfs_restart_rpc(task, data->clp);
 		return;
 	}
+	nfs4_set_rpc_timeout(data->clp, data->res->lr_fsinfo->lease_time);
 	dprintk("<-- %s\n", __func__);
 }
 
-- 
1.6.2.5

