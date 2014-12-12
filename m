Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:46991 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbaLLXE5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 18:04:57 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFS: verify the use of RPC_AUTH_GSS pseudoflavors before use
Date: Fri, 12 Dec 2014 17:55:22 -0500
Message-ID: <1418424922-1569-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs_create_rpc_client only creates an rpc_auth, which only checks to see if
rpc.gssd is running to succeed.

Create a gss_context with the proposed pseudoflavor (as in nfs_find_best_sec)
to verify pseudoflavor.

Some servers support RPC_AUTH_GSS_KRB5 but not RPC_AUTH_GSS_KRB5I

Try RPC_AUTH_GSS_KRB5I then RPC_AUTH_GSS_KRB5 for the clientid establishment
rpc client cl_rpcclient.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4client.c | 44 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 43 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ffdb28d..9f8631d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -341,6 +341,47 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 }
 
 /**
+ * Verify the client and server kerberos and gss configurations by obtaining
+ * a gss_context for UID 0 (current_cred()) prior to use in an RPC call.
+ */
+int nfs_create_gss_rpc_client(struct nfs_client *clp,
+			      const struct rpc_timeout *timeparams)
+{
+	struct rpc_cred *cred;
+	int err;
+
+	/* This creates a krb5i rpc_auth if rpc.gssd is running */
+	err = nfs_create_rpc_client(clp, timeparams, RPC_AUTH_GSS_KRB5I);
+	if (err == -EINVAL)
+		return err;
+
+	/* Check that krb5i can be used: cr_init obtains a gss_context */
+	cred = rpcauth_lookupcred(clp->cl_rpcclient->cl_auth, 0);
+	if (IS_ERR(cred)) {
+		struct rpc_clnt *krb5i, *krb5;
+
+		/* Try krb5 */
+		krb5i = clp->cl_rpcclient;
+		krb5 = rpc_clone_client_set_auth(krb5i, RPC_AUTH_GSS_KRB5);
+		rpc_shutdown_client(krb5i);
+		/* Check that krb5 can be used */
+		cred = rpcauth_lookupcred(krb5->cl_auth, 0);
+		if (IS_ERR(cred)) {
+			rpc_shutdown_client(krb5);
+			clp->cl_rpcclient = ERR_PTR(-EINVAL);
+			return -EINVAL;
+		}
+		/* Use krb5 */
+		put_rpccred(cred);
+		clp->cl_rpcclient = krb5;
+		return 0;
+	}
+	/* Use krb5i */
+	put_rpccred(cred);
+	return 0;
+}
+
+/**
  * nfs4_init_client - Initialise an NFS4 client record
  *
  * @clp: nfs_client to initialise
@@ -372,7 +413,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
 
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
+	/* Try RPC_AUTH_GSS_KRB51 then RPC_AUTH_GSS_KRB5 */
+	error = nfs_create_gss_rpc_client(clp, timeparms);
 	if (error == -EINVAL)
 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
 	if (error < 0)
-- 
1.9.3 (Apple Git-50)

