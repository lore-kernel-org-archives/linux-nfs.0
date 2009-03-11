From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 13/14] nfsd4: fix do_probe_callback errors
Date: Tue, 10 Mar 2009 20:27:01 -0400
Message-ID: <1236731222-3294-14-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
 <1236731222-3294-7-git-send-email-bfields@fieldses.org>
 <1236731222-3294-8-git-send-email-bfields@fieldses.org>
 <1236731222-3294-9-git-send-email-bfields@fieldses.org>
 <1236731222-3294-10-git-send-email-bfields@fieldses.org>
 <1236731222-3294-11-git-send-email-bfields@fieldses.org>
 <1236731222-3294-12-git-send-email-bfields@fieldses.org>
 <1236731222-3294-13-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44054 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-13-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The errors returned aren't used.  Just return 0 and make them available
to a dprintk().  Also, consistently use -ERRNO errors instead of nfs
errors.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5dcd38e..c979af7 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -389,12 +389,10 @@ static int do_probe_callback(void *data)
 		.rpc_argp       = clp,
 	};
 	struct rpc_clnt *client;
-	int status;
+	int status = -EINVAL;
 
-	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5)) {
-		status = nfserr_cb_path_down;
+	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
 		goto out_err;
-	}
 
 	/* Initialize address */
 	memset(&addr, 0, sizeof(addr));
@@ -405,7 +403,8 @@ static int do_probe_callback(void *data)
 	/* Create RPC client */
 	client = rpc_create(&args);
 	if (IS_ERR(client)) {
-		dprintk("NFSD: couldn't create callback client\n");
+		dprintk("NFSD: couldn't create callback client: %d\n",
+			PTR_ERR(client));
 		status = PTR_ERR(client);
 		goto out_err;
 	}
@@ -422,10 +421,10 @@ static int do_probe_callback(void *data)
 out_release_client:
 	rpc_shutdown_client(client);
 out_err:
-	dprintk("NFSD: warning: no callback path to client %.*s\n",
-		(int)clp->cl_name.len, clp->cl_name.data);
+	dprintk("NFSD: warning: no callback path to client %.*: error %ds\n",
+		(int)clp->cl_name.len, clp->cl_name.data, status);
 	put_nfs4_client(clp);
-	return status;
+	return 0;
 }
 
 /*
-- 
1.6.0.4

