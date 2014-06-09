Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54825 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753773AbaFITd2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2014 15:33:28 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/3] NFS test SECINFO RPC_AUTH_GSS pseudoflavors for support
Date: Mon, 9 Jun 2014 15:33:21 -0400
Message-ID: <1402342401-5640-4-git-send-email-andros@netapp.com>
In-Reply-To: <1402342401-5640-1-git-send-email-andros@netapp.com>
References: <1402342401-5640-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The current code returns an RPC_AUTH_GSS pseudoflavor without testing to see
if it is configured properly. If an RPC_AUTH_GSS pseudoflavor fails then the
next SECINFO flavor should be tried.

Create an rpc_auth, rpc_cred, and initialize the cred (e.g. get a GSS Context)
using the short-lived SECINFO rpc client to test if the use of the RPC_AUTH_GSS
pseudoflavor succeeds.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4namespace.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 46 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index fd4dcb6..e0a5491 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -135,6 +135,39 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 }
 
 /**
+ * nfs_test_gss - Test client support of pseudoflavor
+ * @server: NFS server struct
+ * @flavor: RPC_AUTH_GSS pseudoflavor
+ */
+
+static int nfs_test_gss_flavor(struct nfs_server *server,
+			       rpc_authflavor_t pseudoflavor)
+{
+	struct rpc_auth_create_args auth_args = {
+		.pseudoflavor = pseudoflavor,
+	};
+	struct rpc_auth *auth;
+	struct rpc_cred *rcred;
+	const struct cred *cred = current_cred();
+	struct auth_cred acred = {
+		.uid = cred->fsuid,
+		.gid = cred->fsgid,
+		.group_info = get_group_info(((struct cred *)cred)->group_info),
+	};
+
+	auth = rpcauth_create(&auth_args, server->client);
+	if (IS_ERR(auth))
+		return -EACCES;
+
+	/* This will call cr_init to create a gss context */
+	rcred = rpcauth_lookup_credcache(auth, &acred, 0);
+	if (IS_ERR(cred))
+		return -EACCES;
+
+	return 0;
+}
+
+/**
  * nfs_find_best_sec - Find a security mechanism supported locally
  * @server: NFS server struct
  * @flavors: List of security tuples returned by SECINFO procedure
@@ -152,21 +185,32 @@ static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
 	rpc_authflavor_t pseudoflavor;
 	struct nfs4_secinfo4 *secinfo;
 	unsigned int i;
+	int err = 0;
 
 	for (i = 0; i < flavors->num_flavors; i++) {
+		bool gss = false;
+
 		secinfo = &flavors->flavors[i];
 
 		switch (secinfo->flavor) {
+		case RPC_AUTH_GSS:
+			gss = true;
 		case RPC_AUTH_NULL:
 		case RPC_AUTH_UNIX:
-		case RPC_AUTH_GSS:
 			pseudoflavor = rpcauth_get_pseudoflavor(secinfo->flavor,
 							&secinfo->flavor_info);
 			/* make sure pseudoflavor matches sec= mount opt */
 			if (pseudoflavor != RPC_AUTH_MAXFLAVOR &&
 			    nfs_auth_info_match(&server->auth_info,
-						pseudoflavor))
+						pseudoflavor)) {
+				if (gss) {
+					err = nfs_test_gss_flavor(server,
+								  pseudoflavor);
+					if (err) /* try the next flavor */
+						continue;
+				}
 				return pseudoflavor;
+			}
 			break;
 		}
 	}
-- 
1.8.3.1

