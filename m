Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58302 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727315AbeIGWoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:05 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/13] svc_generic.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:50 -0400
Message-Id: <20180907180151.178872-13-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "handle" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/svc_generic.c b/src/svc_generic.c
index 52a56c2..20abaa2 100644
--- a/src/svc_generic.c
+++ b/src/svc_generic.c
@@ -113,6 +113,7 @@ svc_create(dispatch, prognum, versnum, nettype)
 				if (l == NULL) {
 					warnx("svc_create: no memory");
 					mutex_unlock(&xprtlist_lock);
+					__rpc_endconf(handle);
 					return (0);
 				}
 				l->xprt = xprt;
-- 
2.17.1
