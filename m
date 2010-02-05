From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 5/5] nfs4: adjust rpc timeout for nfs_client->rpcclient based on the lease_time
Date: Fri,  5 Feb 2010 03:32:34 -0800
Message-ID: <1265369554-2105-6-git-send-email-batsakis@netapp.com>
References: <1265369554-2105-1-git-send-email-batsakis@netapp.com>
 <1265369554-2105-2-git-send-email-batsakis@netapp.com>
 <1265369554-2105-3-git-send-email-batsakis@netapp.com>
 <1265369554-2105-4-git-send-email-batsakis@netapp.com>
 <1265369554-2105-5-git-send-email-batsakis@netapp.com>
Cc: trond@netapp.com, root <vadmin.root@vadmin (none) >,
	Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58311 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756944Ab0BKUl1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 15:41:27 -0500
In-Reply-To: <1265369554-2105-5-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: root <root@vadmin.(none)>

the timeo mount parameters do not affect the nfs_client's rpc_client as
they are mount-point specific. As the nfs_client mainly deals with the
state management, the duration of its operations should be capped by
the server's lease time.

This patch sets the timeout value for the
nfs_client->rpc_client to be equal to the server's lease time. The new value
overrides the xprt->timeout value set in rpc_new_client()

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

