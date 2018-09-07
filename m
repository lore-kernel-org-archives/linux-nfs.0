Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46818 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:43:58 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/13] auth_gss.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:39 -0400
Message-Id: <20180907180151.178872-2-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "gd" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index 5959893..289bd5b 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -207,6 +207,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 			rpc_createerr.cf_error.re_errno = ENOMEM;
 			free(auth);
+			free(gd);
 			return (NULL);
 		}
 	}
-- 
2.17.1
