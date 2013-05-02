Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60571 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760882Ab3EBRTd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 13:19:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Don't spam syslog with "Pseudoflavor not found" messages
Date: Thu,  2 May 2013 13:19:28 -0400
Message-Id: <1367515168-11158-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just convert those messages to dprintk()s so that they can be used
when debugging.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 3 +--
 net/sunrpc/clnt.c              | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 51415b0..b5dd692 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -867,8 +867,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	err = -EINVAL;
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
 	if (!gss_auth->mech) {
-		printk(KERN_WARNING "%s: Pseudoflavor %d not found!\n",
-				__func__, flavor);
+		dprintk("RPC:       Pseudoflavor %d not found!\n", flavor);
 		goto err_free;
 	}
 	gss_auth->service = gss_pseudoflavor_to_service(gss_auth->mech, flavor);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d259fa9..e9143ed 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -360,7 +360,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	auth = rpcauth_create(args->authflavor, clnt);
 	if (IS_ERR(auth)) {
-		printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
+		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
 				args->authflavor);
 		err = PTR_ERR(auth);
 		goto out_no_auth;
-- 
1.8.1.4

