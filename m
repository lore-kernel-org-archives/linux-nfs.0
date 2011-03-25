Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:45717 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab1CYViV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 17:38:21 -0400
Received: by gxk21 with SMTP id 21so620854gxk.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2011 14:38:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] mount.nfs: Don't leak socket in nfs_ca_sockname()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 25 Mar 2011 17:38:06 -0400
Message-ID: <20110325213806.27166.56852.stgit@matisse.1015granger.net>
In-Reply-To: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
References: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ensure the test socket is always closed before nfs_ca_sockname()
returns.  Otherwise it's orphaned.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=197

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 9b6504d..52a5389 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1095,7 +1095,7 @@ static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
 		.sin6_family		= AF_INET6,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
-	int sock;
+	int sock, result = 0;
 
 	sock = socket(sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
 	if (sock < 0)
@@ -1103,28 +1103,26 @@ static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
 
 	switch (sap->sa_family) {
 	case AF_INET:
-		if (bind(sock, SAFE_SOCKADDR(&sin), sizeof(sin)) < 0) {
-			close(sock);
-			return 0;
-		}
+		if (bind(sock, SAFE_SOCKADDR(&sin), sizeof(sin)) < 0)
+			goto out;
 		break;
 	case AF_INET6:
-		if (bind(sock, SAFE_SOCKADDR(&sin6), sizeof(sin6)) < 0) {
-			close(sock);
-			return 0;
-		}
+		if (bind(sock, SAFE_SOCKADDR(&sin6), sizeof(sin6)) < 0)
+			goto out;
 		break;
 	default:
 		errno = EAFNOSUPPORT;
-		return 0;
+		goto out;
 	}
 
-	if (connect(sock, sap, salen) < 0) {
-		close(sock);
-		return 0;
-	}
+	if (connect(sock, sap, salen) < 0)
+		goto out;
 
-	return !getsockname(sock, buf, buflen);
+	result = !getsockname(sock, buf, buflen);
+
+out:
+	close(sock);
+	return result;
 }
 
 /*

