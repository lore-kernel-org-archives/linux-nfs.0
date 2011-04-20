Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754048Ab1DTXuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 19:50:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Ensure that clientid and session establishment can time out
Date: Wed, 20 Apr 2011 16:50:05 -0700
Message-Id: <1303343405-5021-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1303343405-5021-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1303343405-5021-1-git-send-email-Trond.Myklebust@netapp.com>
 <1303343405-5021-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patch ensures that we do not get permanently trapped in
the RPC layer when trying to establish a new client id or session.
This again ensures that the state manager can finish in a timely
fashion when the last filesystem to reference the nfs_client exits.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |   13 +++++++------
 fs/nfs/nfs4state.c |    1 +
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2507f1f..afccc9e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3749,7 +3749,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 			sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 			clp->cl_ipaddr, port >> 8, port & 255);
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (status == -NFS4ERR_CLID_INUSE)
 		ssleep(clp->cl_lease_time / HZ + 1);
 	return status;
@@ -3770,7 +3770,7 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 	int status;
 
 	now = jiffies;
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (status == 0) {
 		spin_lock(&clp->cl_lock);
 		clp->cl_lease_time = fsinfo.lease_time * HZ;
@@ -4784,7 +4784,7 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 				init_utsname()->domainname,
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (!status)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 	dprintk("<-- %s status= %d\n", __func__, status);
@@ -4867,7 +4867,8 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 		.rpc_client = clp->cl_rpcclient,
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_get_lease_time_ops,
-		.callback_data = &data
+		.callback_data = &data,
+		.flags = RPC_TASK_TIMEOUT,
 	};
 	int status;
 
@@ -5169,7 +5170,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
 	nfs4_init_channel_attrs(&args);
 	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
 
-	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 
 	if (!status)
 		/* Verify the session's negotiated channel_attrs values */
@@ -5236,7 +5237,7 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 	msg.rpc_argp = session;
 	msg.rpc_resp = NULL;
 	msg.rpc_cred = NULL;
-	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 
 	if (status)
 		printk(KERN_WARNING
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9a7f9df..530b99f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1605,6 +1605,7 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 		break;
 	case -NFS4ERR_DELAY:
+	case -ETIMEDOUT:
 	case -EAGAIN:
 		ssleep(1);
 		break;
-- 
1.7.4.4

