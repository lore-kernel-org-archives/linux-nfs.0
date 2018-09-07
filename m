Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51722 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:03 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/13] rpc_soc.c: buffer_size_warning
Date: Fri,  7 Sep 2018 14:01:47 -0400
Message-Id: <20180907180151.178872-10-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling strncpy with a maximum size argument of 108 bytes on
destination array "sun.sun_path" of size 108 bytes might
leave the destination string unterminated.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpc_soc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index 59e0882..a85cb17 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -673,7 +673,7 @@ svcunix_create(sock, sendsize, recvsize, path)
 
 	memset(&sun, 0, sizeof sun);
 	sun.sun_family = AF_LOCAL;
-	strncpy(sun.sun_path, path, sizeof(sun.sun_path));
+	strncpy(sun.sun_path, path, (sizeof(sun.sun_path)-1));
 	addrlen = sizeof(struct sockaddr_un);
 	sa = (struct sockaddr *)&sun;
 
-- 
2.17.1
