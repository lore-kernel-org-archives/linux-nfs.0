Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44510 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758210Ab3JQSMT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:19 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICHe1004608
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:18 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICHrk009739
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:17 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/21] SUNRPC: Modify synopsis of rpc_client_register()
Date: Thu, 17 Oct 2013 14:12:17 -0400
Message-Id: <20131017181217.1073.35663.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc_client_register() helper was added in commit e73f4cc0,
"SUNRPC: split client creation routine into setup and registration,"
Mon Jun 24 11:52:52 2013.  In a subsequent patch, I'd like to invoke
rpc_client_register() from a context where a struct rpc_create_args
is not available.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/clnt.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7747960..1aa361b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -272,12 +272,13 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
 }
 
-static int rpc_client_register(const struct rpc_create_args *args,
-			       struct rpc_clnt *clnt)
+static int rpc_client_register(struct rpc_clnt *clnt,
+			       rpc_authflavor_t pseudoflavor,
+			       const char *client_name)
 {
 	struct rpc_auth_create_args auth_args = {
-		.pseudoflavor = args->authflavor,
-		.target_name = args->client_name,
+		.pseudoflavor = pseudoflavor,
+		.target_name = client_name,
 	};
 	struct rpc_auth *auth;
 	struct net *net = rpc_net_ns(clnt);
@@ -298,7 +299,7 @@ static int rpc_client_register(const struct rpc_create_args *args,
 	auth = rpcauth_create(&auth_args, clnt);
 	if (IS_ERR(auth)) {
 		dprintk("RPC:       Couldn't create auth handle (flavor %u)\n",
-				args->authflavor);
+				pseudoflavor);
 		err = PTR_ERR(auth);
 		goto err_auth;
 	}
@@ -398,7 +399,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	/* save the nodename */
 	rpc_clnt_set_nodename(clnt, utsname()->nodename);
 
-	err = rpc_client_register(args, clnt);
+	err = rpc_client_register(clnt, args->authflavor, args->client_name);
 	if (err)
 		goto out_no_path;
 	if (parent)

