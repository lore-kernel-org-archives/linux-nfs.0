Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59842 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab1EITh5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:37:57 -0400
Received: by ywj3 with SMTP id 3so1917800ywj.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:37:56 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/16] NFS: Add infrastructure for updating callback data
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:37:54 -0400
Message-ID: <20110509193753.16568.7852.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Currently the NFS client creates the long-form client ID in the XDR
encoder for SETCLIENTID, just before it is sent to the server.

With transparent state migration, the long-form client ID used with
the source server must be sent to the destination server when the
client uses SETCLIENTID to update the destination server with fresh
callback information.  If a new long-form client ID is used here, the
destination server will drop all the NFSv4 state the servers so
carefully migrated for us.

So, the client must preserve the short-form and long-form client ID
that are generated at SETCLIENTID/EXCHANGE_ID time.  When it comes
time to update the callback information, the preserved client IDs
are used so the server doesn't drop state for this client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4proc.c         |   29 ++++++++++++++++++++++++++---
 fs/nfs/nfs4state.c        |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 5 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index bf40649..536b0ba 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -231,6 +231,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 	nfs4_destroy_callback(clp);
 	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
 		nfs_idmap_delete(clp);
+	kfree(clp->cl_cached_clientid);
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4038c5b..1832fd6 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -48,6 +48,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
+	NFS4CLNT_UPDATE_CALLBACK,
 };
 
 enum nfs4_session_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 57b7279..bb6b128 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3736,7 +3736,11 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
 	for(;;) {
 		rcu_read_lock();
-		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
+		if (test_bit(NFS4CLNT_UPDATE_CALLBACK, &clp->cl_state)) {
+			strcpy(setclientid.sc_name, clp->cl_cached_clientid);
+			setclientid.sc_name_len = strlen(setclientid.sc_name);
+		} else {
+			setclientid.sc_name_len = scnprintf(setclientid.sc_name,
 				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
 				clp->cl_ipaddr,
 				rpc_peeraddr2str(clp->cl_rpcclient,
@@ -3745,6 +3749,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 							RPC_DISPLAY_PROTO),
 				clp->cl_rpcclient->cl_auth->au_ops->au_name,
 				clp->cl_id_uniquifier);
+		}
 		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
 				sizeof(setclientid.sc_netid),
 				rpc_peeraddr2str(clp->cl_rpcclient,
@@ -3755,7 +3760,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		rcu_read_unlock();
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
-		if (status != -NFS4ERR_CLID_INUSE)
+		if (clp->cl_cached_clientid != NULL ||
+		    status != -NFS4ERR_CLID_INUSE)
 			break;
 		if (loop != 0) {
 			++clp->cl_id_uniquifier;
@@ -3764,6 +3770,13 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		++loop;
 		ssleep(clp->cl_lease_time / HZ + 1);
 	}
+
+	if (status == 0 &&
+	    !test_bit(NFS4CLNT_UPDATE_CALLBACK, &clp->cl_state)) {
+		kfree(clp->cl_cached_clientid);
+		clp->cl_cached_clientid = kstrdup(setclientid.sc_name,
+								GFP_KERNEL);
+	}
 	return status;
 }
 
@@ -4874,16 +4887,26 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 	args.verifier = &verifier;
 
-	args.id_len = scnprintf(args.id, sizeof(args.id),
+	if (test_bit(NFS4CLNT_UPDATE_CALLBACK, &clp->cl_state)) {
+		strcpy(args.id, clp->cl_cached_clientid);
+		args.id_len = strlen(args.id);
+	} else {
+		args.id_len = scnprintf(args.id, sizeof(args.id),
 				"%s/%s.%s/%u",
 				clp->cl_ipaddr,
 				init_utsname()->nodename,
 				init_utsname()->domainname,
 				clp->cl_rpcclient->cl_auth->au_flavor);
+	}
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (!status)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
+	if (!status &&
+	    !test_bit(NFS4CLNT_UPDATE_CALLBACK, &clp->cl_state)) {
+		kfree(clp->cl_cached_clientid);
+		clp->cl_cached_clientid = kstrdup(args.id, GFP_KERNEL);
+	}
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f6b268f..3285e40 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1646,6 +1646,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 					nfs_mark_client_ready(clp, status);
 				goto out_error;
 			}
+			clear_bit(NFS4CLNT_UPDATE_CALLBACK, &clp->cl_state);
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 			pnfs_destroy_all_layouts(clp);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index aa3a912..d0554c4 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -70,6 +70,7 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
+	char			*cl_cached_clientid;
 	const struct nfs4_minor_version_ops *cl_mvops;
 
 	/* The sequence id to use for the next CREATE_SESSION */

