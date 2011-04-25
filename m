Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758825Ab1DYSoo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:44:44 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:44:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/15] NFS: Add infrastructure for updating callback data
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:44:41 -0400
Message-ID: <20110425184441.5669.40015.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
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
index c23bcf1..42b579d 100644
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
index 06b7457..eba7791 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -47,6 +47,7 @@ enum nfs4_client_state {
 	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_UPDATE_CALLBACK,
 };
 
 enum nfs4_session_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 561ffa1..b7f5666 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3708,7 +3708,11 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
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
@@ -3717,6 +3721,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 							RPC_DISPLAY_PROTO),
 				clp->cl_rpcclient->cl_auth->au_ops->au_name,
 				clp->cl_id_uniquifier);
+		}
 		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
 				sizeof(setclientid.sc_netid),
 				rpc_peeraddr2str(clp->cl_rpcclient,
@@ -3727,7 +3732,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		rcu_read_unlock();
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
-		if (status != -NFS4ERR_CLID_INUSE)
+		if (clp->cl_cached_clientid != NULL ||
+		    status != -NFS4ERR_CLID_INUSE)
 			break;
 		if (signalled())
 			break;
@@ -3737,6 +3743,13 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 			if (++clp->cl_id_uniquifier == 0)
 				break;
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
 
@@ -4867,16 +4880,26 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
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
 
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
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
index a6804f7..09181b0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1621,6 +1621,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 					nfs_mark_client_ready(clp, status);
 				goto out_error;
 			}
+			clear_bit(NFS4CLNT_UPDATE_CALLBACK, &clp->cl_state);
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 			pnfs_destroy_all_layouts(clp);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 33b7459..4a4940c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -69,6 +69,7 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
+	char			*cl_cached_clientid;
 	const struct nfs4_minor_version_ops *cl_mvops;
 
 	/* The sequence id to use for the next CREATE_SESSION */

