From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] nfsd4: fix callback program version
Date: Fri, 14 May 2010 18:45:23 -0400
Message-ID: <1273877123-23617-2-git-send-email-bfields@citi.umich.edu>
References: <1273877123-23617-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753697Ab0ENWpX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 18:45:23 -0400
In-Reply-To: <1273877123-23617-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 4.1 rfc actually specifices that the callback program must have
version 4.

As far as I can tell, this was unspecified in rfc 3530.  But it looks to
me like the NFSv4 client only ever accepted version 1!

Newer linux clients allow either 1 or 4, for either minor version.

So, the safest approach seems to be to use version 1 for 4.0 clients,
and version 4 for 4.1 clients.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index b91bdee..bf79031 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -423,13 +423,29 @@ static struct rpc_procinfo     nfs4_cb_procedures[] = {
     PROC(CB_RECALL,    COMPOUND,   enc_cb_recall,      dec_cb_recall),
 };
 
-static struct rpc_version       nfs_cb_version4 = {
+/*
+ * RFC 5661 section 18.36.3 (in the description of csa_cb_program),
+ * requires the callback rpc program version number to be 4.  RFC 3530
+ * leaves this unspecified, however, pre-2.6.33 Linux NFSv4 clients
+ * required the version number to be 1.
+ * Therefore, the safest seems to be use version 1 for 4.0 clients and
+ * version 4 for 4.1 clients.  Therefore, we define both versions:
+ */
+
+static struct rpc_version       nfs_cb_version1 = {
         .number                 = 1,
         .nrprocs                = ARRAY_SIZE(nfs4_cb_procedures),
         .procs                  = nfs4_cb_procedures
 };
 
+static struct rpc_version       nfs_cb_version4 = {
+        .number                 = 4,
+        .nrprocs                = ARRAY_SIZE(nfs4_cb_procedures),
+        .procs                  = nfs4_cb_procedures
+};
+
 static struct rpc_version *	nfs_cb_version[] = {
+	&nfs_cb_version1,
 	&nfs_cb_version4,
 };
 
@@ -470,7 +486,8 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 		.timeout	= &timeparms,
 		.program	= &cb_program,
 		.prognumber	= cb->cb_prog,
-		.version	= 1,
+		/* See the comment before the nfs_cb_version1 definition: */
+		.version	= cb->cb_minorversion ? 1 : 0,
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 		.client_name    = clp->cl_principal,
-- 
1.7.0.4

