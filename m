From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/27] NFS: Make nfs_alloc_client() take (sockaddr,
	len) instead of sockaddr_in
Date: Mon, 10 Dec 2007 14:58:37 -0500
Message-ID: <20071210195837.2823.69098.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:31679 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187AbXLJUE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:56 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support non-IPv4 addresses, adjust the arguments and callers of
nfs_alloc_client() to pass in a "struct sockaddr *" instead of a
"struct sockaddr_in *".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4da1014..e904e5f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -102,7 +102,8 @@ struct rpc_program		nfsacl_program = {
  * bother putting them in a slab cache...
  */
 static struct nfs_client *nfs_alloc_client(const char *hostname,
-					   const struct sockaddr_in *addr,
+					   const struct sockaddr *addr,
+					   size_t addrlen,
 					   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
@@ -119,8 +120,8 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	memcpy(&clp->cl_addr, addr, sizeof(*addr));
-	clp->cl_addrlen = sizeof(*addr);
+	memcpy(&clp->cl_addr, addr, addrlen);
+	clp->cl_addrlen = addrlen;
 
 	if (hostname) {
 		clp->cl_hostname = kstrdup(hostname, GFP_KERNEL);
@@ -307,7 +308,10 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname, addr, nfsversion);
+		new = nfs_alloc_client(hostname,
+				       (const struct sockaddr *)addr,
+				       sizeof(*addr),
+				       nfsversion);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);

