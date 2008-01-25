From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 050/112] NFS: Clean up the nfs_find_client function.
Date: Fri, 25 Jan 2008 11:37:39 -0500
Message-ID: <20080125163739.31887.79578.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbYAYQ7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:42 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxcEs010113
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:38 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   52 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d7f6d50..ff778ec 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -208,52 +208,60 @@ void nfs_put_client(struct nfs_client *clp)
 }
 
 /*
- * Find a client by address
- * - caller must hold nfs_client_lock
+ * Find a client by IP address and protocol version
+ * - returns NULL if no such client
  */
-static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr, int nfsversion, int match_port)
+struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
 {
 	struct nfs_client *clp;
 
+	spin_lock(&nfs_client_lock);
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
 		/* Don't match clients that failed to initialise properly */
-		if (clp->cl_cons_state < 0)
+		if (clp->cl_cons_state != NFS_CS_READY)
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
 		if (clp->cl_nfsversion != nfsversion)
 			continue;
 
+		/* Match only the IP address, not the port number */
 		if (clp->cl_addr.sin_addr.s_addr != addr->sin_addr.s_addr)
 			continue;
 
-		if (!match_port || clp->cl_addr.sin_port == addr->sin_port)
-			goto found;
+		atomic_inc(&clp->cl_count);
+		spin_unlock(&nfs_client_lock);
+		return clp;
 	}
-
+	spin_unlock(&nfs_client_lock);
 	return NULL;
-
-found:
-	atomic_inc(&clp->cl_count);
-	return clp;
 }
 
 /*
- * Find a client by IP address and protocol version
- * - returns NULL if no such client
+ * Find an nfs_client on the list that matches the initialisation data
+ * that is supplied.
  */
-struct nfs_client *nfs_find_client(const struct sockaddr_in *addr, int nfsversion)
+static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *data)
 {
 	struct nfs_client *clp;
 
-	spin_lock(&nfs_client_lock);
-	clp = __nfs_find_client(addr, nfsversion, 0);
-	spin_unlock(&nfs_client_lock);
-	if (clp != NULL && clp->cl_cons_state != NFS_CS_READY) {
-		nfs_put_client(clp);
-		clp = NULL;
+	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+		/* Don't match clients that failed to initialise properly */
+		if (clp->cl_cons_state < 0)
+			continue;
+
+		/* Different NFS versions cannot share the same nfs_client */
+		if (clp->cl_nfsversion != data->version)
+			continue;
+
+		/* Match the full socket address */
+		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
+			continue;
+
+		atomic_inc(&clp->cl_count);
+		return clp;
 	}
-	return clp;
+	return NULL;
 }
 
 /*
@@ -273,7 +281,7 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client(cl_init->addr, cl_init->version, 1);
+		clp = nfs_match_client(cl_init);
 		if (clp)
 			goto found_client;
 		if (new)
