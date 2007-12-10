From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 27/27] NFS: Pull covers off IPv6 address parsing
Date: Mon, 10 Dec 2007 14:59:35 -0500
Message-ID: <20071210195935.2823.54652.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:39867 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756302AbXLJUE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:58 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the needed IPv6 infrastructure is in place, allow the NFS client's
IP address parser to generate AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 379841e..209d9c4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -628,12 +628,23 @@ static void nfs_parse_server_address(char *value,
 				     struct sockaddr *sap,
 				     size_t *len)
 {
-	struct sockaddr_in *ap = (void *)sap;
+	if (strchr(value, ':')) {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+		u8 *addr = (u8 *)&ap->sin6_addr.in6_u;
 
-	ap->sin_family = AF_INET;
-	*len = sizeof(*ap);
-	if (in4_pton(value, -1, (u8 *)&ap->sin_addr.s_addr, '\0', NULL))
-		return;
+		ap->sin6_family = AF_INET6;
+		*len = sizeof(*ap);
+		if (in6_pton(value, -1, addr, '\0', NULL))
+			return;
+	} else {
+		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+		u8 *addr = (u8 *)&ap->sin_addr.s_addr;
+
+		ap->sin_family = AF_INET;
+		*len = sizeof(*ap);
+		if (in4_pton(value, -1, addr, '\0', NULL))
+			return;
+	}
 
 	sap->sa_family = AF_UNSPEC;
 	*len = 0;

