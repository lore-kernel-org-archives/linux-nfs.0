From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/27] NFS: Change nfs_get_client() to take sockaddr *
Date: Mon, 10 Dec 2007 14:58:51 -0500
Message-ID: <20071210195851.2823.2139.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:36459 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbXLJUD1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:03:27 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust arguments and callers of nfs_get_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support
non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 48fbacd..6a49ae7 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -286,21 +286,21 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr,
  * - creates a new record if one doesn't yet exist
  */
 static struct nfs_client *nfs_get_client(const char *hostname,
-					 const struct sockaddr_in *addr,
+					 const struct sockaddr *addr,
+					 size_t addrlen,
 					 unsigned int nfsversion)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%u)\n",
-		hostname ?: "", NIPQUAD(addr->sin_addr),
-		addr->sin_port, nfsversion);
+	dprintk("--> nfs_get_client(%s,v%u)\n",
+		hostname ?: "", nfsversion);
 
 	/* see if the client already exists */
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 1);
+		clp = __nfs_find_client(addr, nfsversion, 1);
 		if (clp)
 			goto found_client;
 		if (new)
@@ -308,10 +308,7 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname,
-				       (const struct sockaddr *)addr,
-				       sizeof(*addr),
-				       nfsversion);
+		new = nfs_alloc_client(hostname, addr, addrlen, nfsversion);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);
@@ -587,7 +584,9 @@ static int nfs_init_server(struct nfs_server *server,
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(data->nfs_server.hostname,
-				&data->nfs_server.address, nfsvers);
+			     (struct sockaddr *)&data->nfs_server.address,
+			     sizeof(data->nfs_server.address),
+			     nfsvers);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -924,7 +923,8 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, addr, 4);
+	clp = nfs_get_client(hostname, (struct sockaddr *)addr,
+			     sizeof(*addr), 4);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;

