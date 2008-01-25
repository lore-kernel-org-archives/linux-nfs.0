From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 062/112] NFS: Add support for AF_INET6 addresses in
	nfs_compare_super()
Date: Fri, 25 Jan 2008 11:37:44 -0500
Message-ID: <20080125163744.31887.77122.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14365 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495AbYAYRAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:01 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlo3019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:59 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Refactor nfs_compare_super() and add AF_INET6 support.

Replace the generic memcmp() to document explicitly what parts of the
addresses must match in this check, and make the comparison independent
of the lengths of both addresses.

A side benefit is both tests are more computationally efficient than a
memcmp().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   43 ++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 75f3cbf..c3d8fcf 100644
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
@@ -1326,15 +1328,50 @@ static int nfs_set_super(struct super_block *s, void *data)
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
