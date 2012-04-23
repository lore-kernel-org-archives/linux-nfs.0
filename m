Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab2DWUzH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:55:07 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:55:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/20] NFS: Fix recovery from NFS4ERR_CLID_INUSE
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:55:06 -0400
Message-ID: <20120423205505.11446.28437.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv4 minor version 0, currently the cl_id_uniquifier allows the
Linux client to generate a unique nfs_client_id4 string whenever a
server replies with NFS4ERR_CLID_INUSE.

NFS4ERR_CLID_INUSE actually means that the client has presented this
nfs_client_id4 string with a different authentication flavor in the
past.  Retrying with a different nfs_client_id4 string means the
client orphans NFSv4 state on the server.  This state will take at
least a whole lease period to be purged.

Change recovery to try the identification operation again with a
different auth flavor until it works.  The retry loop is factored
out of nfs4_proc_setclientid() and into the state manager, so that
both mv0 and mv1 client ID establishment is covered by the same
CLID_INUSE recovery logic.

XXX: On further review, I'm not sure how it would be possible to
send an nfs_client_id4 with the wrong authentication flavor, since
the au_name is part of the string itself...

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c         |   75 ++++++++++++++++++++++++++++++---------------
 fs/nfs/nfs4state.c        |   37 ++++++++++++++++++----
 include/linux/nfs_fs_sb.h |    3 +-
 3 files changed, 81 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8bdc6fd..7ec1b68 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3890,6 +3890,37 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
 }
 
+static unsigned int
+nfs4_init_nonuniform_client_string(const struct nfs_client *clp,
+				   char *buf, size_t len)
+{
+	unsigned int result;
+
+	rcu_read_lock();
+	result = scnprintf(buf, len, "%s/%s %s %s non-uniform",
+				clp->cl_ipaddr,
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_ADDR),
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_PROTO),
+				clp->cl_rpcclient->cl_auth->au_ops->au_name);
+	rcu_read_unlock();
+	return result;
+}
+
+/**
+ * nfs4_proc_setclientid - Negotiate client ID
+ * @clp: state data structure
+ * @program: RPC program for NFSv4 callback service
+ * @port: IP port number for NFS4 callback service
+ * @cred: RPC credential to use for this call
+ * @res: where to place the result
+ *
+ * Returns zero or a negative NFS4ERR status code.
+ *
+ * A status of -NFS4ERR_CLID_INUSE means the caller should try
+ * again with a different authentication flavor.
+ */
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		unsigned short port, struct rpc_cred *cred,
 		struct nfs4_setclientid_res *res)
@@ -3906,41 +3937,30 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
-	int loop = 0;
 	int status;
 
+	/* Client ID */
 	nfs4_init_boot_verifier(clp, &sc_verifier);
+	setclientid.sc_name_len = nfs4_init_nonuniform_client_string(clp,
+						setclientid.sc_name,
+						sizeof(setclientid.sc_name));
 
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
+	/* Callback info */
+	rcu_read_lock();
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
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+
+	dprintk("%s: nfs_client_id4 '%.*s' (status %d)\n",
+		__func__, setclientid.sc_name_len, setclientid.sc_name,
+		status);
 	return status;
 }
 
@@ -5008,6 +5028,11 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 /*
  * nfs4_proc_exchange_id()
  *
+ * Returns zero or a negative NFS4ERR status code.
+ *
+ * A status of -NFS4ERR_CLID_INUSE means the caller should try
+ * again with a different authentication flavor.
+ *
  * Since the clientid has expired, all compounds using sessions
  * associated with the stale clientid will be returning
  * NFS4ERR_BADSESSION in the sequence operation, and will therefore
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7f56502..6a1a305 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1576,19 +1576,42 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 	struct rpc_cred *cred;
 	const struct nfs4_state_recovery_ops *ops =
 		clp->cl_mvops->reboot_recovery_ops;
-	int status = -ENOENT;
+	rpc_authflavor_t flavors[NFS_MAX_SECFLAVORS];
+	int i, len, status;
 
+	i = 0;
+	len = gss_mech_list_pseudoflavors(flavors);
+
+again:
+	status = -ENOENT;
 	cred = ops->get_clid_cred(clp);
 	if (cred != NULL) {
 		status = ops->establish_clid(clp, cred);
 		put_rpccred(cred);
-		/* Handle case where the user hasn't set up machine creds */
-		if (status == -EACCES && cred == clp->cl_machine_cred) {
-			nfs4_clear_machine_cred(clp);
-			status = -EAGAIN;
-		}
-		if (status == -NFS4ERR_MINOR_VERS_MISMATCH)
+		switch (status) {
+		case 0:
+			break;
+		case -EACCES:	/* the user hasn't set up machine creds */
+			if (cred == clp->cl_machine_cred) {
+				nfs4_clear_machine_cred(clp);
+				status = -EAGAIN;
+			}
+			break;
+		case -NFS4ERR_CLID_INUSE:
+		case -NFS4ERR_WRONGSEC:
+			/*
+			 * XXX: "flavors" is unordered; the client should
+			 *	prefer krb5p for this transport
+			 */
+			if (i < len && rpcauth_create(flavors[i++],
+						clp->cl_rpcclient) != NULL)
+				goto again;
+			status = -EPERM;
+			break;
+		case -NFS4ERR_MINOR_VERS_MISMATCH:
 			status = -EPROTONOSUPPORT;
+			break;
+		}
 	}
 	return status;
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b246582..1c4c174 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -65,10 +65,9 @@ struct nfs_client {
 	struct idmap *		cl_idmap;
 
 	/* Our own IP address, as a null-terminated string.
-	 * This is used to generate the clientid, and the callback address.
+	 * This is used to generate the mv0 callback address.
 	 */
 	char			cl_ipaddr[48];
-	unsigned char		cl_id_uniquifier;
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 

