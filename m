From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/27] NFS: Add support for AF_INET6 addresses in
	__nfs_find_client()
Date: Mon, 10 Dec 2007 14:58:07 -0500
Message-ID: <20071210195807.2823.4778.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:33047 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbXLJUCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:02:08 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce AF_INET6-specific address checking to __nfs_find_client().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |   36 ++++++++++++++++++++++++++++++------
 1 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5ab1ca1..a37f01a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -34,6 +34,8 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 
 #include <asm/system.h>
@@ -207,13 +209,15 @@ void nfs_put_client(struct nfs_client *clp)
  * Find a client by address
  * - caller must hold nfs_client_lock
  */
-static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
+static struct nfs_client *__nfs_find_client(const struct sockaddr *addr,
 					    unsigned int nfsversion,
 					    int match_port)
 {
 	struct nfs_client *clp;
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
+		struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -222,11 +226,31 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr,
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
-		if (clp->cl_addr.sin_addr.s_addr != addr->sin_addr.s_addr)
+		if (clap->sa_family != addr->sa_family)
 			continue;
 
-		if (!match_port || clp->cl_addr.sin_port == addr->sin_port)
-			goto found;
+		switch (addr->sa_family) {
+		case AF_INET: {
+			struct sockaddr_in *sap = (struct sockaddr_in *)clap;
+			struct sockaddr_in *ap = (struct sockaddr_in *)addr;
+			if (sap->sin_addr.s_addr != ap->sin_addr.s_addr)
+				continue;
+			if (!match_port || sap->sin_port == ap->sin_port)
+				goto found;
+			continue;
+		}
+		case AF_INET6: {
+			struct sockaddr_in6 *sap = (struct sockaddr_in6 *)clap;
+			struct sockaddr_in6 *ap = (struct sockaddr_in6 *)addr;
+			if (!ipv6_addr_equal(&sap->sin6_addr, &ap->sin6_addr))
+				continue;
+			if (!match_port || sap->sin6_port == ap->sin6_port)
+				goto found;
+			continue;
+		}
+		default:
+			BUG();
+		}
 	}
 
 	return NULL;
@@ -246,7 +270,7 @@ struct nfs_client *nfs_find_client(const struct sockaddr_in *addr,
 	struct nfs_client *clp;
 
 	spin_lock(&nfs_client_lock);
-	clp = __nfs_find_client(addr, nfsversion, 0);
+	clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 0);
 	spin_unlock(&nfs_client_lock);
 	if (clp != NULL && clp->cl_cons_state != NFS_CS_READY) {
 		nfs_put_client(clp);
@@ -274,7 +298,7 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client(addr, nfsversion, 1);
+		clp = __nfs_find_client((struct sockaddr *)addr, nfsversion, 1);
 		if (clp)
 			goto found_client;
 		if (new)

