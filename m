From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] nfs4: minor callback code simplification
Date: Fri, 14 May 2010 18:45:22 -0400
Message-ID: <1273877123-23617-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34183 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331Ab0ENWpX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 18:45:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note the position in the version array doesn't have to match the actual
rpc version number.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 77bc9d3..b91bdee 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -430,7 +430,6 @@ static struct rpc_version       nfs_cb_version4 = {
 };
 
 static struct rpc_version *	nfs_cb_version[] = {
-	NULL,
 	&nfs_cb_version4,
 };
 
@@ -471,7 +470,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 		.timeout	= &timeparms,
 		.program	= &cb_program,
 		.prognumber	= cb->cb_prog,
-		.version	= nfs_cb_version[1]->number,
+		.version	= 1,
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 		.client_name    = clp->cl_principal,
-- 
1.7.0.4

