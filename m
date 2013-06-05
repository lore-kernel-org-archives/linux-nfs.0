Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f181.google.com ([209.85.161.181]:33111 "EHLO
	mail-gg0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307Ab3FEA4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jun 2013 20:56:34 -0400
Received: by mail-gg0-f181.google.com with SMTP id r4so18718ggn.26
        for <linux-nfs@vger.kernel.org>; Tue, 04 Jun 2013 17:56:34 -0700 (PDT)
Subject: [PATCH] NFS: Fix keytabless mounts
To: neilb@suse.de
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 04 Jun 2013 20:56:31 -0400
Message-ID: <20130605004523.14256.24793.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 05f4c350 "NFS: Discover NFSv4 server trunking when mounting"
Fri Sep 14 17:24:32 2012 introduced Uniform Client String support,
which forces our NFS client to establish a client ID immediately
during a mount operation rather than waiting until a user wants to
open a file.

Normally machine credentials (eg. from a keytab) are used to perform
a mount operation that is protected by Kerberos.  Before 05f4c350,
SETCLIENTID uses a machine credential, or falls back to a regular
user's credential if no keytab is available.

05f4c350 seems to have broken the ability to mount with sec=krb5 on
clients that don't have a keytab.  Performing SETCLIENTID early
means there may be no user credential to fall back on, since during
system initialization no regular user has kinit'd yet.

Typically, root is required to kinit in this situation anyway to
make a sec=krb5 mount work.  So, the kernel should try to use root's
credential for lease management if there's no keytab.

The new logic should cause the root credential to be tried only
after both the machine cred and a user cred are found to be
unavailable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Neil-

Here's a wacky idea to continue our conversation.  Tested just
enough to confirm it may do something useful.  Applies to 3.7.
Something similar might work for 3.8 and 3.9.

 fs/nfs/nfs4proc.c  |   15 ++++++++++-----
 fs/nfs/nfs4state.c |   12 ++++--------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 50bf31d..7e4934e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4215,7 +4215,8 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	dprintk("NFS call  setclientid auth=%s, '%.*s'\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		setclientid.sc_name_len, setclientid.sc_name);
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg,
+					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
 	dprintk("NFS reply setclientid: %d\n", status);
 	return status;
 }
@@ -4246,7 +4247,8 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		clp->cl_clientid);
 	now = jiffies;
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg,
+					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
 	if (status == 0) {
 		spin_lock(&clp->cl_lock);
 		clp->cl_lease_time = fsinfo.lease_time * HZ;
@@ -5458,7 +5460,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		goto out_server_scope;
 	}
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg,
+					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
 	if (status == 0)
 		status = nfs4_check_cl_exchange_flags(res.flags);
 
@@ -5518,7 +5521,8 @@ static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
 	};
 	int status;
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg,
+					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
 	if (status)
 		dprintk("NFS: Got error %d from the server %s on "
 			"DESTROY_CLIENTID.", status, clp->cl_hostname);
@@ -5926,7 +5930,8 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	nfs4_init_channel_attrs(&args);
 	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
 
-	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	status = rpc_call_sync(session->clp->cl_rpcclient, &msg,
+					RPC_TASK_TIMEOUT|RPC_TASK_ROOTCREDS);
 
 	if (!status)
 		/* Verify the session's negotiated channel_attrs values */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b1c96e7..2a9bed3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1740,10 +1740,9 @@ static int nfs4_establish_lease(struct nfs_client *clp)
 	int status;
 
 	cred = ops->get_clid_cred(clp);
-	if (cred == NULL)
-		return -ENOENT;
 	status = ops->establish_clid(clp, cred);
-	put_rpccred(cred);
+	if (cred)
+		put_rpccred(cred);
 	if (status != 0)
 		return status;
 	pnfs_destroy_all_layouts(clp);
@@ -1827,11 +1826,9 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	status  = -ENOENT;
 again:
 	cred = ops->get_clid_cred(clp);
-	if (cred == NULL)
-		goto out_unlock;
-
 	status = ops->detect_trunking(clp, result, cred);
-	put_rpccred(cred);
+	if (cred)
+		put_rpccred(cred);
 	switch (status) {
 	case 0:
 		break;
@@ -1878,7 +1875,6 @@ again:
 		status = -EKEYEXPIRED;
 	}
 
-out_unlock:
 	mutex_unlock(&nfs_clid_init_mutex);
 out_free:
 	kfree(flavors);

