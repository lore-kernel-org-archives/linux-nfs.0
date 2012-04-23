Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44481 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984Ab2DWUyt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:54:49 -0400
Received: by yhmm54 with SMTP id m54so6471798yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:54:49 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/20] NFS: Refactor nfs_get_client(): add nfs_found_client()
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:54:47 -0400
Message-ID: <20120423205447.11446.14775.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Rationalize the locking in nfs_get_client() for the case
where the target server already appears in the nfs_client_list.

Code that takes and releases nfs_client_lock remains in
nfs_get_client().  The rest of the logic is moved to a separate
function.

No behavior change is expected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |   71 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 3ba6c62..09b3f55 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -504,6 +504,39 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
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
+		dprintk("<-- nfs_get_client error waiting for nfs_client %p "
+			"for %s (%d)\n", clp, cl_init->hostname ?: "", error);
+		nfs_put_client(clp);
+		return ERR_PTR(-ERESTARTSYS);
+	}
+
+	if (clp->cl_cons_state < NFS_CS_READY) {
+		error = clp->cl_cons_state;
+		dprintk("<-- nfs_get_client found nfs_client %p for %s, not "
+			"ready (%d)\n", clp, cl_init->hostname ?: "", error);
+		nfs_put_client(clp);
+		return ERR_PTR(error);
+	}
+
+	BUG_ON(clp->cl_cons_state != NFS_CS_READY);
+
+	dprintk("<-- nfs_get_client found nfs_client %p for %s\n",
+		clp, cl_init->hostname ?: "");
+	return clp;
+}
+
+/*
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
@@ -526,8 +559,12 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
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
 
@@ -536,7 +573,8 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 		new = nfs_alloc_client(cl_init);
 	} while (!IS_ERR(new));
 
-	dprintk("--> nfs_get_client() = %ld [failed]\n", PTR_ERR(new));
+	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
+		cl_init->hostname ?: "", PTR_ERR(new));
 	return new;
 
 	/* install a new client and return with it unready */
@@ -553,33 +591,6 @@ install_client:
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

