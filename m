Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44869 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760483Ab1F1SZf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 14:25:35 -0400
Received: by iyb12 with SMTP id 12so373005iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 11:25:34 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFS: Clean up nfs_walk_authlist()
To: linux-nfs@vger.kernel.org
Date: Tue, 28 Jun 2011 14:25:31 -0400
Message-ID: <20110628182530.2866.58433.stgit@seurat.1015granger.net>
In-Reply-To: <20110628181324.2866.98154.stgit@seurat.1015granger.net>
References: <20110628181324.2866.98154.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: Add common exit labels in preparation for the following
patch.  Clarify comments.  Rename variable for clarity.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   45 +++++++++++++++++++++++----------------------
 1 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ce40e5c..4625a4c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1541,15 +1541,19 @@ out_security_failure:
 }
 
 /*
- * Match the requested auth flavors with the list returned by
- * the server.  Returns zero and sets the mount's authentication
- * flavor on success; returns -EACCES if server does not support
- * the requested flavor.
+ * Match the requested auth flavors with the list returned by the
+ * server.  args->auth_flavors contains a list of security flavors
+ * to check for.  The caller has already set up the list of flavors
+ * with the default (usually AUTH_SYS).
+ *
+ * Returns zero on success; the authentication flavor in args->
+ * auth_flavors[0] should be used for this mount.  Otherwise, returns
+ * -EACCES if server does not support the requested flavor.
  */
 static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
-			     struct nfs_mount_request *request)
+			     struct nfs_mount_request *server)
 {
-	unsigned int i, j, server_authlist_len = *(request->auth_flav_len);
+	unsigned int i, j, server_authlist_len = *(server->auth_flav_len);
 
 	/*
 	 * Certain releases of Linux's mountd return an empty
@@ -1559,31 +1563,28 @@ static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
 	 * if the returned flavor list is empty.
 	 */
 	if (server_authlist_len == 0)
-		return 0;
+		goto out;
 
 	/*
-	 * We avoid sophisticated negotiating here, as there are
-	 * plenty of cases where we can get it wrong, providing
-	 * either too little or too much security.
-	 *
-	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
-	 * flavor listed first.  However, some servers list
-	 * AUTH_NULL first.  Our caller plants AUTH_SYS, the
-	 * preferred default, in args->auth_flavors[0] if user
-	 * didn't specify sec= mount option.
+	 * RFC 2623 section 2.7 says "... a NFS client SHOULD use
+	 * the first flavor in the list that it supports, on the
+	 * assumption that the best access is provided by the first
+	 * flavor."
 	 */
 	for (i = 0; i < args->auth_flavor_len; i++)
 		for (j = 0; j < server_authlist_len; j++)
-			if (args->auth_flavors[i] == request->auth_flavs[j]) {
-				dfprintk(MOUNT, "NFS: using auth flavor %d\n",
-					request->auth_flavs[j]);
-				args->auth_flavors[0] = request->auth_flavs[j];
-				return 0;
+			if (args->auth_flavors[i] == server->auth_flavs[j]) {
+				args->auth_flavors[0] = server->auth_flavs[j];
+				goto out;
 			}
 
 	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
-	nfs_umount(request);
+	nfs_umount(server);
 	return -EACCES;
+
+out:
+	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
+	return 0;
 }
 
 /*

