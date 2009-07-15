From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] NFS: Replace nfs_set_port() with rpc_set_port()
Date: Wed, 15 Jul 2009 17:37:38 -0400
Message-ID: <20090715213738.7582.88569.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38870
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753360AbZGOVhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:41 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h      |   19 -------------------
 fs/nfs/nfs4namespace.c |    2 +-
 fs/nfs/super.c         |    6 +++---
 3 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8f8a760..b39e32a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -368,22 +368,3 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 	return ((unsigned long)len + (unsigned long)base +
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
-
-/*
- * Set the port number in an address.  Be agnostic about the address
- * family.
- */
-static inline void nfs_set_port(struct sockaddr *sap, unsigned short port)
-{
-	struct sockaddr_in *ap = (struct sockaddr_in *)sap;
-	struct sockaddr_in6 *ap6 = (struct sockaddr_in6 *)sap;
-
-	switch (sap->sa_family) {
-	case AF_INET:
-		ap->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		ap6->sin6_port = htons(port);
-		break;
-	}
-}
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 43c86b7..ef22ee8 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -125,7 +125,7 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 				mountdata->addr, mountdata->addrlen);
 		if (mountdata->addrlen == 0)
 			continue;
-		nfs_set_port(mountdata->addr, NFS_PORT);
+		rpc_set_port(mountdata->addr, NFS_PORT);
 
 		memcpy(page2, buf->data, buf->len);
 		page2[buf->len] = '\0';
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 354ef4c..5fd5a41 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1415,7 +1415,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	nfs_set_port(request.sap, args->mount_server.port);
+	rpc_set_port(request.sap, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path
@@ -1704,7 +1704,7 @@ static int nfs_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			goto out_no_address;
 
-		nfs_set_port((struct sockaddr *)&args->nfs_server.address,
+		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
 				args->nfs_server.port);
 
 		nfs_set_mount_transport_protocol(args);
@@ -2337,7 +2337,7 @@ static int nfs4_validate_mount_data(void *options,
 						&args->nfs_server.address))
 			return -EINVAL;
 
-		nfs_set_port((struct sockaddr *)&args->nfs_server.address,
+		rpc_set_port((struct sockaddr *)&args->nfs_server.address,
 				args->nfs_server.port);
 
 		nfs_validate_transport_protocol(args);

