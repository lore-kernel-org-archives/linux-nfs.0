Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57705 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754665Ab0JUQUp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/11] nfsd4: only require krb5 principal for NFSv4.0 callbacks
Date: Thu, 21 Oct 2010 12:20:18 -0400
Message-Id: <1287678018-9266-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In the sessions backchannel case, we don't need a krb5 principal name
for the client; we use the already-created forechannel credentials
instead.

Some cleanup, while we're there: make it clearer which code here is 4.0-
or sessions- specific.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 67bcd2c..143da2e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -481,22 +481,24 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 	};
 	struct rpc_create_args args = {
 		.net		= &init_net,
-		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= (struct sockaddr *) &conn->cb_addr,
 		.addrsize	= conn->cb_addrlen,
 		.timeout	= &timeparms,
 		.program	= &cb_program,
-		.prognumber	= conn->cb_prog,
 		.version	= 0,
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
-		.client_name    = clp->cl_principal,
 	};
 	struct rpc_clnt *client;
 
-	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
-		return -EINVAL;
-	if (clp->cl_minorversion) {
+	if (clp->cl_minorversion == 0) {
+		if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
+			return -EINVAL;
+		args.client_name = clp->cl_principal;
+		args.prognumber	= conn->cb_prog,
+		args.protocol = XPRT_TRANSPORT_TCP;
+		clp->cl_cb_ident = conn->cb_ident;
+	} else {
 		args.bc_xprt = conn->cb_xprt;
 		args.prognumber = clp->cl_cb_session->se_cb_prog;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
@@ -508,7 +510,6 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 			PTR_ERR(client));
 		return PTR_ERR(client);
 	}
-	clp->cl_cb_ident = conn->cb_ident;
 	clp->cl_cb_client = client;
 	return 0;
 
-- 
1.7.1

