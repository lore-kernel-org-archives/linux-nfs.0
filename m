From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 063/112] NFS: Verify IPv6 addresses properly
Date: Fri, 25 Jan 2008 11:37:44 -0500
Message-ID: <20080125163744.31887.6429.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755726AbYAYRAE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:04 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxlo7019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:01 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Add support to nfs_verify_server_address for recognizing AF_INET6
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c3d8fcf..038b20b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -600,16 +600,21 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
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
 
