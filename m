Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:48460 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753Ab3EMQZX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 12:25:23 -0400
Received: by mail-ie0-f177.google.com with SMTP id 9so12054889iec.8
        for <linux-nfs@vger.kernel.org>; Mon, 13 May 2013 09:25:22 -0700 (PDT)
Received: from seurat.1015granger.net (adsl-99-26-161-222.dsl.sfldmi.sbcglobal.net. [99.26.161.222])
        by mx.google.com with ESMTPSA id qn10sm18003325igc.6.2013.05.13.09.25.20
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 May 2013 09:25:20 -0700 (PDT)
Subject: [PATCH 1/2] NFS: Revert commit 4edaa308 and follow-on fixes
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 13 May 2013 12:25:19 -0400
Message-ID: <20130513162519.1942.35619.stgit@seurat.1015granger.net>
In-Reply-To: <20130513161515.1942.845.stgit@seurat.1015granger.net>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After applying commit 4edaa308 "NFS: Use "krb5i" to establish
NFSv4 state whenever possible", some report a 15 second delay when
attempting to mount the first NFS export on a server, if their
client does not run rpc.gssd.  This could be onerous for
automounting or following referrals.

The immediate work around is to insist that such clients be
configured to start rpc.gssd.  Some feel that requiring this kind
of change after a kernel upgrade without warning should be
considered a regression.

The desired fix is to avoid the 15 second gssd upcall timeout when
rpc.gssd is not running.  Despite everyone's initial opinion, it
appears that it is impossible to eliminate this timeout securely and
reliably without co-operation from user space.  Either rpc.gssd
changes, or changes to system start up, or both, are required.

To restore previous behavior, revert:

   * commit 79d852bf  NFS: Retry SETCLIENTID with AUTH_SYS instead
                      of AUTH_NONE
   * commit 845cbceb  NFSv4: Don't clear the machine cred when
                      client establish returns EACCES
   * commit 23631227  NFSv4: Fix the fallback to AUTH_NULL if krb5i
                      is not available
   * commit 4edaa308  NFS: Use "krb5i" to establish NFSv4 state
                      whenever possible

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4client.c |    4 +---
 fs/nfs/nfs4state.c  |   53 ++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 947b0c9..fdf519c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -201,9 +201,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	if (clp->cl_minorversion != 0)
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
-	if (error == -EINVAL)
-		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_NULL);
+	error = nfs_create_rpc_client(clp, timeparms, authflavour);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 300d17d..b5137c9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -154,6 +154,18 @@ struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 	return cred;
 }
 
+static void nfs4_clear_machine_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+
+	spin_lock(&clp->cl_lock);
+	cred = clp->cl_machine_cred;
+	clp->cl_machine_cred = NULL;
+	spin_unlock(&clp->cl_lock);
+	if (cred != NULL)
+		put_rpccred(cred);
+}
+
 static struct rpc_cred *
 nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 {
@@ -1767,6 +1779,10 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 		return -EPERM;
 	case -EACCES:
+		if (clp->cl_machine_cred == NULL)
+			return -EACCES;
+		/* Handle case where the user hasn't set up machine creds */
+		nfs4_clear_machine_cred(clp);
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
 	case -EAGAIN:
@@ -1861,13 +1877,26 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 {
 	const struct nfs4_state_recovery_ops *ops =
 				clp->cl_mvops->reboot_recovery_ops;
+	rpc_authflavor_t *flavors, flav, save;
 	struct rpc_clnt *clnt;
 	struct rpc_cred *cred;
-	int i, status;
+	int i, len, status;
 
 	dprintk("NFS: %s: testing '%s'\n", __func__, clp->cl_hostname);
 
+	len = NFS_MAX_SECFLAVORS;
+	flavors = kcalloc(len, sizeof(*flavors), GFP_KERNEL);
+	if (flavors == NULL) {
+		status = -ENOMEM;
+		goto out;
+	}
+	len = rpcauth_list_flavors(flavors, len);
+	if (len < 0) {
+		status = len;
+		goto out_free;
+	}
 	clnt = clp->cl_rpcclient;
+	save = clnt->cl_auth->au_flavor;
 	i = 0;
 
 	mutex_lock(&nfs_clid_init_mutex);
@@ -1882,6 +1911,12 @@ again:
 	switch (status) {
 	case 0:
 		break;
+
+	case -EACCES:
+		if (clp->cl_machine_cred == NULL)
+			break;
+		/* Handle case where the user hasn't set up machine creds */
+		nfs4_clear_machine_cred(clp);
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
 	case -EAGAIN:
@@ -1890,12 +1925,17 @@ again:
 		dprintk("NFS: %s after status %d, retrying\n",
 			__func__, status);
 		goto again;
-	case -EACCES:
-		if (i++)
-			break;
+
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_WRONGSEC:
-		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
+		status = -EPERM;
+		if (i >= len)
+			break;
+
+		flav = flavors[i++];
+		if (flav == save)
+			flav = flavors[i++];
+		clnt = rpc_clone_client_set_auth(clnt, flav);
 		if (IS_ERR(clnt)) {
 			status = PTR_ERR(clnt);
 			break;
@@ -1926,6 +1966,9 @@ again:
 
 out_unlock:
 	mutex_unlock(&nfs_clid_init_mutex);
+out_free:
+	kfree(flavors);
+out:
 	dprintk("NFS: %s: status = %d\n", __func__, status);
 	return status;
 }

