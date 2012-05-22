Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42512 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214Ab2EVCpw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:45:52 -0400
Received: by yenm10 with SMTP id m10so4991681yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:45:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/14] NFS: Refactor nfs_get_client(): add nfs_found_client()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:45:50 -0400
Message-ID: <20120522024550.1787.28617.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Code that takes and releases nfs_client_lock remains in
nfs_get_client().  Logic that handles a pre-existing nfs_client is
moved to a separate function.

No behavior change is expected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |   67 ++++++++++++++++++++++++++++++-------------------------
 1 files changed, 37 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index af9b7e4..5f19f95 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -506,6 +506,35 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 }
 
 /*
+ * Found an existing client.  Make sure it's ready before returning.
+ */
+static struct nfs_client *
+nfs_found_client(const struct nfs_client_initdata *cl_init,
+		 struct nfs_client *clp)
+{
+	int error;
+
+	error = wait_event_killable(nfs_client_active_wq,
+				clp->cl_cons_state < NFS_CS_INITING);
+	if (error < 0) {
+		nfs_put_client(clp);
+		return ERR_PTR(-ERESTARTSYS);
+	}
+
+	if (clp->cl_cons_state < NFS_CS_READY) {
+		error = clp->cl_cons_state;
+		nfs_put_client(clp);
+		return ERR_PTR(error);
+	}
+
+	BUG_ON(clp->cl_cons_state != NFS_CS_READY);
+
+	dprintk("<-- %s found nfs_client %p for %s\n",
+		__func__, clp, cl_init->hostname ?: "");
+	return clp;
+}
+
+/*
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
@@ -528,8 +557,12 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 		spin_lock(&nn->nfs_client_lock);
 
 		clp = nfs_match_client(cl_init);
-		if (clp)
-			goto found_client;
+		if (clp) {
+			spin_unlock(&nn->nfs_client_lock);
+			if (new)
+				nfs_free_client(new);
+			return nfs_found_client(cl_init, clp);
+		}
 		if (new)
 			goto install_client;
 
@@ -538,7 +571,8 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 		new = nfs_alloc_client(cl_init);
 	} while (!IS_ERR(new));
 
-	dprintk("--> nfs_get_client() = %ld [failed]\n", PTR_ERR(new));
+	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
+		cl_init->hostname ?: "", PTR_ERR(new));
 	return new;
 
 	/* install a new client and return with it unready */
@@ -555,33 +589,6 @@ install_client:
 	}
 	dprintk("--> nfs_get_client() = %p [new]\n", clp);
 	return clp;
-
-	/* found an existing client
-	 * - make sure it's ready before returning
-	 */
-found_client:
-	spin_unlock(&nn->nfs_client_lock);
-
-	if (new)
-		nfs_free_client(new);
-
-	error = wait_event_killable(nfs_client_active_wq,
-				clp->cl_cons_state < NFS_CS_INITING);
-	if (error < 0) {
-		nfs_put_client(clp);
-		return ERR_PTR(-ERESTARTSYS);
-	}
-
-	if (clp->cl_cons_state < NFS_CS_READY) {
-		error = clp->cl_cons_state;
-		nfs_put_client(clp);
-		return ERR_PTR(error);
-	}
-
-	BUG_ON(clp->cl_cons_state != NFS_CS_READY);
-
-	dprintk("--> nfs_get_client() = %p [share]\n", clp);
-	return clp;
 }
 
 /*

