Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2516 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727315AbeIGWoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:04 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/13] rtime.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:49 -0400
Message-Id: <20180907180151.178872-12-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Handle variable "s" going out of scope leaks the handle.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rtime.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/rtime.c b/src/rtime.c
index b642840..29fbf0a 100644
--- a/src/rtime.c
+++ b/src/rtime.c
@@ -90,6 +90,7 @@ rtime(addrp, timep, timeout)
 
 	/* TCP and UDP port are the same in this case */
 	if ((serv = getservbyname("time", "tcp")) == NULL) {
+		do_close(s);
 		return(-1);
 	}
 
-- 
2.17.1
