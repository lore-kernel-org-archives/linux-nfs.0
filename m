Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:02 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/13] rpc_soc.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:46 -0400
Message-Id: <20180907180151.178872-9-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "localhandle" going out of scope leaks the storage it points to.
Returning without closing handle "sock" leaks it.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpc_soc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index 5a6eeb7..59e0882 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -663,8 +663,10 @@ svcunix_create(sock, sendsize, recvsize, path)
 		    strcmp(nconf->nc_protofmly, NC_LOOPBACK) == 0)
 			break;
 	}
-	if (nconf == NULL)
+	if (nconf == NULL) {
+		endnetconfig(localhandle);
 		return(xprt);
+	}
 
 	if ((sock = __rpc_nconf2fd(nconf)) < 0)
 		goto done;
@@ -692,6 +694,8 @@ svcunix_create(sock, sendsize, recvsize, path)
 	}
 
 	xprt = (SVCXPRT *)svc_tli_create(sock, nconf, &taddr, sendsize, recvsize);
+	if (xprt == NULL)
+		close(sock);
 
 done:
 	endnetconfig(localhandle);
-- 
2.17.1
