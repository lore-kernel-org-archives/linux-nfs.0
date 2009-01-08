From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] text-based mount command: support AF_INET6 in
	rewrite_mount_options()
Date: Thu, 08 Jan 2009 12:33:04 -0500
Message-ID: <20090108173303.19893.20635.stgit@ingres.1015granger.net>
References: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:48582 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755836AbZAHRe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 12:34:27 -0500
In-Reply-To: <20090108172526.19893.91621.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have an AF_INET6-capable probe_bothports(), we can support
AF_INET6 when rewriting text-based NFS mount options.  This should be
adequate to support NFS transport protocol and version negotiation with
AF_INET6 NFS servers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   74 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 319be71..6d44bb7 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -309,6 +309,37 @@ static int nfs_is_permanent_error(int error)
 	}
 }
 
+/*
+ * Get NFS/mnt server addresses from mount options
+ *
+ * Returns 1 and fills in @nfs_saddr, @nfs_salen, @mnt_saddr, and @mnt_salen
+ * if all goes well; otherwise zero.
+ */
+static int nfs_extract_server_addresses(struct mount_options *options,
+					struct sockaddr *nfs_saddr,
+					socklen_t *nfs_salen,
+					struct sockaddr *mnt_saddr,
+					socklen_t *mnt_salen)
+{
+	char *option;
+
+	option = po_get(options, "addr");
+	if (option == NULL)
+		return 0;
+	if (!nfs_string_to_sockaddr(option, strlen(option),
+						nfs_saddr, nfs_salen))
+		return 0;
+
+	option = po_get(options, "mountaddr");
+	if (option == NULL)
+		memcpy(mnt_saddr, nfs_saddr, *nfs_salen);
+	else if (!nfs_string_to_sockaddr(option, strlen(option),
+						mnt_saddr, mnt_salen))
+		return 0;
+
+	return 1;
+}
+
 static int nfs_construct_new_options(struct mount_options *options,
 				     struct pmap *nfs_pmap,
 				     struct pmap *mnt_pmap)
@@ -400,9 +431,14 @@ static int nfs_construct_new_options(struct mount_options *options,
 static struct mount_options *nfs_rewrite_mount_options(char *str)
 {
 	struct mount_options *options;
-	char *option;
-	clnt_addr_t mnt_server = { };
-	clnt_addr_t nfs_server = { };
+	struct sockaddr_storage nfs_address;
+	struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_address;
+	socklen_t nfs_salen;
+	struct pmap nfs_pmap;
+	struct sockaddr_storage mnt_address;
+	struct sockaddr *mnt_saddr = (struct sockaddr *)&mnt_address;
+	socklen_t mnt_salen;
+	struct pmap mnt_pmap;
 
 	options = po_split(str);
 	if (!options) {
@@ -410,39 +446,27 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 		return NULL;
 	}
 
-	errno = EINVAL;
-	option = po_get(options, "addr");
-	if (option) {
-		nfs_server.saddr.sin_family = AF_INET;
-		if (!inet_aton((const char *)option, &nfs_server.saddr.sin_addr))
-			goto err;
-	} else
+	if (!nfs_extract_server_addresses(options, nfs_saddr, &nfs_salen,
+						mnt_saddr, &mnt_salen)) {
+		errno = EINVAL;
 		goto err;
+	}
 
-	option = po_get(options, "mountaddr");
-	if (option) {
-		mnt_server.saddr.sin_family = AF_INET;
-		if (!inet_aton((const char *)option, &mnt_server.saddr.sin_addr))
-			goto err;
-	} else
-		memcpy(&mnt_server.saddr, &nfs_server.saddr,
-				sizeof(mnt_server.saddr));
-
-	nfs_options2pmap(options, &nfs_server.pmap, &mnt_server.pmap);
+	nfs_options2pmap(options, &nfs_pmap, &mnt_pmap);
 
 	/* The kernel NFS client doesn't support changing the RPC program
 	 * number for these services, so reset these fields before probing
 	 * the server's ports.  */
-	nfs_server.pmap.pm_prog = NFS_PROGRAM;
-	mnt_server.pmap.pm_prog = MOUNTPROG;
+	nfs_pmap.pm_prog = NFS_PROGRAM;
+	mnt_pmap.pm_prog = MOUNTPROG;
 
-	if (!probe_bothports(&mnt_server, &nfs_server)) {
+	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
+				 nfs_saddr, nfs_salen, &nfs_pmap)) {
 		errno = ESPIPE;
 		goto err;
 	}
 
-	if (!nfs_construct_new_options(options,
-					&nfs_server.pmap, &mnt_server.pmap)) {
+	if (!nfs_construct_new_options(options, &nfs_pmap, &mnt_pmap)) {
 		errno = EINVAL;
 		goto err;
 	}

