Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:35699 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758585AbaDJUaE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:30:04 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so4446669qab.3
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:30:03 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] nfs4: copy acceptor name from context to nfs_client
Date: Thu, 10 Apr 2014 16:29:51 -0400
Message-Id: <1397161791-29144-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
References: <1397161791-29144-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current CB_COMPOUND handling code tries to compare the principal
name of the request with the cl_hostname in the client. This is not
guaranteed to ever work, particularly if the client happened to mount
a CNAME of the server or a non-fqdn.

Fix this by instead comparing the cr_principal string with the acceptor
name that we get from gssd. In the event that gssd didn't send one
down (i.e. it was too old), then we fall back to trying to use the
cl_hostname as we do today.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c         | 12 ++++++++++++
 fs/nfs/client.c           |  1 +
 fs/nfs/nfs4proc.c         | 30 +++++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  1 +
 5 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 073b4cf67ed9..54de482143cc 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -428,6 +428,18 @@ check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
 	if (p == NULL)
 		return 0;
 
+	/*
+	 * Did we get the acceptor from userland during the SETCLIENID
+	 * negotiation?
+	 */
+	if (clp->cl_acceptor)
+		return !strcmp(p, clp->cl_acceptor);
+
+	/*
+	 * Otherwise try to verify it using the cl_hostname. Note that this
+	 * doesn't work if a non-canonical hostname was used in the devname.
+	 */
+
 	/* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */
 
 	if (memcmp(p, "nfs@", 4) != 0)
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1d09289c8f0e..6a461378fcf2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -252,6 +252,7 @@ void nfs_free_client(struct nfs_client *clp)
 	put_net(clp->cl_net);
 	put_nfs_version(clp->cl_nfs_mod);
 	kfree(clp->cl_hostname);
+	kfree(clp->cl_acceptor);
 	kfree(clp);
 
 	dprintk("<-- nfs_free_client()\n");
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 397be39c6dc8..cc6c3fe3e060 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4896,6 +4896,18 @@ nfs4_init_callback_netid(const struct nfs_client *clp, char *buf, size_t len)
 		return scnprintf(buf, len, "tcp");
 }
 
+static void nfs4_setclientid_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_setclientid *sc = calldata;
+
+	if (task->tk_status == 0)
+		*sc->sc_acceptor = rpcauth_stringify_acceptor(task->tk_rqstp->rq_cred);
+}
+
+static const struct rpc_call_ops nfs4_setclientid_ops = {
+	.rpc_call_done = nfs4_setclientid_done,
+};
+
 /**
  * nfs4_proc_setclientid - Negotiate client ID
  * @clp: state data structure
@@ -4915,6 +4927,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.sc_verifier = &sc_verifier,
 		.sc_prog = program,
 		.sc_cb_ident = clp->cl_cb_ident,
+		.sc_acceptor = &clp->cl_acceptor,
 	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID],
@@ -4922,6 +4935,14 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		.rpc_resp = res,
 		.rpc_cred = cred,
 	};
+	struct rpc_task *task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clp->cl_rpcclient,
+		.rpc_message = &msg,
+		.callback_ops = &nfs4_setclientid_ops,
+		.callback_data = &setclientid,
+		.flags = RPC_TASK_TIMEOUT,
+	};
 	int status;
 
 	/* nfs_client_id4 */
@@ -4948,7 +4969,14 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	dprintk("NFS call  setclientid auth=%s, '%.*s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		setclientid.sc_name_len, setclientid.sc_name);
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task)) {
+		status = PTR_ERR(task);
+		goto out;
+	}
+	status = task->tk_status;
+	rpc_put_task(task);
+out:
 	trace_nfs4_setclientid(clp, status);
 	dprintk("NFS reply setclientid: %d\n", status);
 	return status;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1150ea41b626..922be2e050f5 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -45,6 +45,7 @@ struct nfs_client {
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
+	char *			cl_acceptor;	/* GSSAPI acceptor name */
 	struct list_head	cl_share_link;	/* link in global client list */
 	struct list_head	cl_superblocks;	/* List of nfs_server structs */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6fb5b2335b59..5945d88a26e2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1010,6 +1010,7 @@ struct nfs4_setclientid {
 	unsigned int			sc_uaddr_len;
 	char				sc_uaddr[RPCBIND_MAXUADDRLEN + 1];
 	u32				sc_cb_ident;
+	char				**sc_acceptor;
 };
 
 struct nfs4_setclientid_res {
-- 
1.9.0

