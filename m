Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49452 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:02 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/13] rpc_generic.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:45 -0400
Message-Id: <20180907180151.178872-8-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "handle" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpc_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/rpc_generic.c b/src/rpc_generic.c
index 589cbd5..51f36ac 100644
--- a/src/rpc_generic.c
+++ b/src/rpc_generic.c
@@ -319,6 +319,7 @@ __rpc_setconf(nettype)
 		handle->nflag = FALSE;
 		break;
 	default:
+		free(handle);
 		return (NULL);
 	}
 
-- 
2.17.1
