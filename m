Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48190 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727652AbeIGWoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:05 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 13/13] svc_simple.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:51 -0400
Message-Id: <20180907180151.178872-14-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "xdrbuf" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_simple.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/svc_simple.c b/src/svc_simple.c
index cb58002..c32fe0a 100644
--- a/src/svc_simple.c
+++ b/src/svc_simple.c
@@ -157,6 +157,7 @@ rpc_reg(prognum, versnum, procnum, progname, inproc, outproc, nettype)
 				((netid = strdup(nconf->nc_netid)) == NULL)) {
 				warnx(rpc_reg_err, rpc_reg_msg, __no_mem_str);
 				SVC_DESTROY(svcxprt);
+				free(xdrbuf);
 				break;
 			}
 			madenow = TRUE;
-- 
2.17.1
