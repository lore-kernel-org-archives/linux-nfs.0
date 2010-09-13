Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59074 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab0IMRWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:22:25 -0400
Received: by gxk23 with SMTP id 23so2101995gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:22:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/12] exportfs: Enable IPv6 support in matchhostname()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:22:22 -0400
Message-ID: <20100913172222.19017.22287.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

To gain IPv6 support in matchhostname(), simply replace the socket
address comparison helpers with the generic versions that can handle
IPv4 and IPv6.

host_addrinfo() (called by matchhostname()) returns IPv6 addresses
only if IPv6 support is enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/exportfs/exportfs.c |   23 ++---------------------
 1 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 8496d82..b78957f 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -26,6 +26,7 @@
 #include <netdb.h>
 #include <errno.h>
 
+#include "sockaddr.h"
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -443,26 +444,6 @@ is_hostname(const char *sp)
 	return true;
 }
 
-static _Bool
-compare_sockaddrs4(const struct sockaddr *sa1, const struct sockaddr *sa2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
-}
-
-static _Bool
-compare_sockaddrs(const struct sockaddr *sa1, const struct sockaddr *sa2)
-{
-	if (sa1->sa_family == sa2->sa_family)
-		switch (sa1->sa_family) {
-		case AF_INET:
-			return compare_sockaddrs4(sa1, sa2);
-		}
-
-	return false;
-}
-
 static int
 matchhostname(const char *hostname1, const char *hostname2)
 {
@@ -493,7 +474,7 @@ matchhostname(const char *hostname1, const char *hostname2)
 
 	for (ai1 = results1; ai1 != NULL; ai1 = ai1->ai_next)
 		for (ai2 = results2; ai2 != NULL; ai2 = ai2->ai_next)
-			if (compare_sockaddrs(ai1->ai_addr, ai2->ai_addr)) {
+			if (nfs_compare_sockaddr(ai1->ai_addr, ai2->ai_addr)) {
 				result = 1;
 				break;
 			}

