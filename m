Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f180.google.com ([209.85.210.180]:51179 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612Ab3CPT4W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:56:22 -0400
Received: by mail-ia0-f180.google.com with SMTP id f27so4125770iae.25
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:56:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 15/15] NFS: Use "krb5i" to establish NFSv4 state whenever
 possible
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:56:20 -0400
Message-ID: <20130316195620.27329.83818.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently our client uses AUTH_UNIX for state management on Kerberos
NFS mounts in some cases.  For example, if the first mount of a
server specifies "sec=sys," the SETCLIENTID operation is performed
with AUTH_UNIX.  Subsequent mounts using stronger security flavors
can not change the flavor used for lease establishment.  This might
be less security than an administrator was expecting.

Dave Noveck's migration issues draft recommends the use of an
integrity-protecting security flavor for the SETCLIENTID operation.
Let's ignore the mount's sec= setting and use krb5i as the default
security flavor for SETCLIENTID.

If our client can't establish a GSS context (eg. because it doesn't
have a keytab or the server doesn't support Kerberos) we fall back
to using AUTH_NULL.  For an operation that requires a
machine credential (which never represents a particular user)
AUTH_NULL is as secure as AUTH_UNIX.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4client.c |    2 +-
 fs/nfs/nfs4state.c  |   37 +++++--------------------------------
 2 files changed, 6 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ac4fc9a..0194cab 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -199,7 +199,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	clp->rpc_ops = &nfs_v4_clientops;
 
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
-	error = nfs_create_rpc_client(clp, timeparms, authflavour);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6ace365..3e30e85 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1823,26 +1823,13 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 {
 	const struct nfs4_state_recovery_ops *ops =
 				clp->cl_mvops->reboot_recovery_ops;
-	rpc_authflavor_t *flavors, flav, save;
 	struct rpc_clnt *clnt;
 	struct rpc_cred *cred;
-	int i, len, status;
+	int i, status;
 
 	dprintk("NFS: %s: testing '%s'\n", __func__, clp->cl_hostname);
 
-	len = NFS_MAX_SECFLAVORS;
-	flavors = kcalloc(len, sizeof(*flavors), GFP_KERNEL);
-	if (flavors == NULL) {
-		status = -ENOMEM;
-		goto out;
-	}
-	len = rpcauth_list_flavors(flavors, len);
-	if (len < 0) {
-		status = len;
-		goto out_free;
-	}
 	clnt = clp->cl_rpcclient;
-	save = clnt->cl_auth->au_flavor;
 	i = 0;
 
 	mutex_lock(&nfs_clid_init_mutex);
@@ -1857,12 +1844,6 @@ again:
 	switch (status) {
 	case 0:
 		break;
-
-	case -EACCES:
-		if (clp->cl_machine_cred == NULL)
-			break;
-		/* Handle case where the user hasn't set up machine creds */
-		nfs4_clear_machine_cred(clp);
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
 	case -EAGAIN:
@@ -1871,17 +1852,12 @@ again:
 		dprintk("NFS: %s after status %d, retrying\n",
 			__func__, status);
 		goto again;
-
+	case -EACCES:
+		if (i++)
+			break;
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_WRONGSEC:
-		status = -EPERM;
-		if (i >= len)
-			break;
-
-		flav = flavors[i++];
-		if (flav == save)
-			flav = flavors[i++];
-		clnt = rpc_clone_client_set_auth(clnt, flav);
+		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_NULL);
 		if (IS_ERR(clnt)) {
 			status = PTR_ERR(clnt);
 			break;
@@ -1901,9 +1877,6 @@ again:
 
 out_unlock:
 	mutex_unlock(&nfs_clid_init_mutex);
-out_free:
-	kfree(flavors);
-out:
 	dprintk("NFS: %s: status = %d\n", __func__, status);
 	return status;
 }

