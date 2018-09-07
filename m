Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:01 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/13] getnetpath.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:44 -0400
Message-Id: <20180907180151.178872-7-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "np_sessionp" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/getnetpath.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/getnetpath.c b/src/getnetpath.c
index 7c19932..ea1a18c 100644
--- a/src/getnetpath.c
+++ b/src/getnetpath.c
@@ -88,6 +88,7 @@ setnetpath()
     }
     if ((np_sessionp->nc_handlep = setnetconfig()) == NULL) {
 	syslog (LOG_ERR, "rpc: failed to open " NETCONFIG);
+	free(np_sessionp);
 	return (NULL);
     }
     np_sessionp->valid = NP_VALID;
-- 
2.17.1
