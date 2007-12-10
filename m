From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/27] NFS: Add support for AF_INET6 addresses in
	nfs_compare_super()
Date: Mon, 10 Dec 2007 14:57:38 -0500
Message-ID: <20071210195738.2823.55264.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:52400 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbXLJUKJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:10:09 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor nfs_compare_super() and add AF_INET6 support.

Replace the generic memcmp() to document explicitly what parts of the
addresses must match in this check, and make the comparison independent
of the lengths of both addresses.

A side benefit is both tests are more computationally efficient than a
memcmp().

Note the "void *" casts are temporary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   43 ++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6b004d8..6f1ed56 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -45,6 +45,8 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
@@ -1302,15 +1304,50 @@ static int nfs_set_super(struct super_block *s, void *data)
 	return ret;
 }
 
+static int nfs_compare_super_address(struct nfs_server *server1,
+				     struct nfs_server *server2)
+{
+	struct sockaddr *sap1, *sap2;
+
+	sap1 = (struct sockaddr *)&server1->nfs_client->cl_addr;
+	sap2 = (struct sockaddr *)&server2->nfs_client->cl_addr;
+
+	if (sap1->sa_family != sap2->sa_family)
+		return 0;
+
+	switch (sap1->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *sin1 = (struct sockaddr_in *)sap1;
+		struct sockaddr_in *sin2 = (struct sockaddr_in *)sap2;
+		if (sin1->sin_addr.s_addr != sin2->sin_addr.s_addr)
+			return 0;
+		if (sin1->sin_port != sin2->sin_port)
+			return 0;
+		break;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *sin1 = (struct sockaddr_in6 *)sap1;
+		struct sockaddr_in6 *sin2 = (struct sockaddr_in6 *)sap2;
+		if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
+			return 0;
+		if (sin1->sin6_port != sin2->sin6_port)
+			return 0;
+		break;
+	}
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
 static int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
 	int mntflags = sb_mntdata->mntflags;
 
-	if (memcmp(&old->nfs_client->cl_addr,
-				&server->nfs_client->cl_addr,
-				sizeof(old->nfs_client->cl_addr)) != 0)
+	if (!nfs_compare_super_address(old, server))
 		return 0;
 	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
 	if (old->flags & NFS_MOUNT_UNSHARED)

