Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:50181 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab2GKUaw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:30:52 -0400
Received: by gglu4 with SMTP id u4so1698077ggl.19
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:30:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/15] NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:30:50 -0400
Message-ID: <20120711203049.3767.51053.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv4 minor version 0, currently the cl_id_uniquifier allows the
Linux client to generate a unique nfs_client_id4 string whenever a
server replies with NFS4ERR_CLID_INUSE.

This implementation seems to be based on a flawed reading of RFC
3530.  NFS4ERR_CLID_INUSE actually means that the client has presented
this nfs_client_id4 string with a different principal at some time in
the past, and that lease is still in use on the server.

For a Linux client this might be rather difficult to achieve: the
authentication flavor is named right in the nfs_client_id4.id
string.  If we change flavors, we change strings automatically.

So, practically speaking, NFS4ERR_CLID_INUSE means there is some other
client using our string.  There is not much that can be done to
recover automatically.  Let's make it a permanent error.

Remove the recovery logic in nfs4_proc_setclientid(), and remove the
cl_id_uniquifier field from the nfs_client data structure.  And,
remove the authentication flavor from the nfs_client_id4 string.

Keeping the authentication flavor in the nfs_client_id4.id string
means that we could have a separate lease for each authentication
flavor used by mounts on the client.  But we want just one lease for
all the mounts on this client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c         |   47 +++++++++++++++------------------------------
 fs/nfs/nfs4state.c        |    7 ++++++-
 include/linux/nfs_fs_sb.h |    3 +--
 3 files changed, 23 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 997080d..f5f4e6e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4037,42 +4037,28 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
-	int loop = 0;
-	int status;
 
+	/* nfs_client_id4 */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
-
-	for(;;) {
-		rcu_read_lock();
-		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
-				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
-				clp->cl_ipaddr,
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_ADDR),
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_PROTO),
-				clp->cl_rpcclient->cl_auth->au_ops->au_name,
-				clp->cl_id_uniquifier);
-		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
+	rcu_read_lock();
+	setclientid.sc_name_len = scnprintf(setclientid.sc_name,
+			sizeof(setclientid.sc_name), "%s/%s %s",
+			clp->cl_ipaddr,
+			rpc_peeraddr2str(clp->cl_rpcclient,
+						RPC_DISPLAY_ADDR),
+			rpc_peeraddr2str(clp->cl_rpcclient,
+						RPC_DISPLAY_PROTO));
+	/* cb_client4 */
+	setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
 				sizeof(setclientid.sc_netid),
 				rpc_peeraddr2str(clp->cl_rpcclient,
 							RPC_DISPLAY_NETID));
-		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
+	rcu_read_unlock();
+	setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
-		rcu_read_unlock();
 
-		status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
-		if (status != -NFS4ERR_CLID_INUSE)
-			break;
-		if (loop != 0) {
-			++clp->cl_id_uniquifier;
-			break;
-		}
-		++loop;
-		ssleep(clp->cl_lease_time / HZ + 1);
-	}
-	return status;
+	return rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 }
 
 int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
@@ -5270,10 +5256,9 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	nfs4_init_boot_verifier(clp, &verifier);
 
 	args.id_len = scnprintf(args.id, sizeof(args.id),
-				"%s/%s/%u",
+				"%s/%s",
 				clp->cl_ipaddr,
-				clp->cl_rpcclient->cl_nodename,
-				clp->cl_rpcclient->cl_auth->au_flavor);
+				clp->cl_rpcclient->cl_nodename);
 
 	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
 					GFP_NOFS);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f38300e..b83c66b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1606,10 +1606,15 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 			return -ESERVERFAULT;
 		/* Lease confirmation error: retry after purging the lease */
 		ssleep(1);
-	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_STALE_CLIENTID:
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 		break;
+	case -NFS4ERR_CLID_INUSE:
+		pr_err("NFS: Server %s reports our clientid is in use\n",
+			clp->cl_hostname);
+		nfs_mark_client_ready(clp, -EPERM);
+		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		return -EPERM;
 	case -EACCES:
 		if (clp->cl_machine_cred == NULL)
 			return -EACCES;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index f58325a..6532765 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -69,10 +69,9 @@ struct nfs_client {
 	struct idmap *		cl_idmap;
 
 	/* Our own IP address, as a null-terminated string.
-	 * This is used to generate the clientid, and the callback address.
+	 * This is used to generate the mv0 callback address.
 	 */
 	char			cl_ipaddr[48];
-	unsigned char		cl_id_uniquifier;
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 

