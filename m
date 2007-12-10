From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/27] NFS: Verify IPv6 addresses properly
Date: Mon, 10 Dec 2007 14:57:45 -0500
Message-ID: <20071210195745.2823.65628.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:33047 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbXLJUCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:02:08 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support to nfs_verify_server_address for recognizing AF_INET6
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6f1ed56..8bbdb85 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -576,16 +576,21 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 }
 
 /*
- * Sanity-check a server address provided by the mount command
+ * Sanity-check a server address provided by the mount command.
+ *
+ * Address family must be initialized, and address must not be
+ * the ANY address for that family.
  */
 static int nfs_verify_server_address(struct sockaddr *addr)
 {
 	switch (addr->sa_family) {
 	case AF_INET: {
-		struct sockaddr_in *sa = (struct sockaddr_in *) addr;
-		if (sa->sin_addr.s_addr != INADDR_ANY)
-			return 1;
-		break;
+		struct sockaddr_in *sa = (struct sockaddr_in *)addr;
+		return sa->sin_addr.s_addr != INADDR_ANY;
+	}
+	case AF_INET6: {
+		struct in6_addr *sa = &((struct sockaddr_in6 *)addr)->sin6_addr;
+		return !ipv6_addr_any(sa);
 	}
 	}
 

